module MiniProgram
  class Client
    attr_reader :appid, :app_secret

    def initialize(appid: config.appid, app_secret: config.app_secret)
      @appid = appid
      @app_secret = app_secret
    end

    def access_token(cache: false)
      access_token = redis.get("mp-#{appid}-access-token")
      return access_token if access_token.present?

      api = "https://api.weixin.qq.com/cgi-bin/token"
      params = {
        appid: appid,
        secret: app_secret,
        grant_type: :client_credential
      }

      response = get(api, params)

      result = JSON.parse(response)

      if result["errcode"].present?
        logger.error <<~ERROR
        Get access token failed.
        api: #{api} 
        error: #{result}
        ERROR
        raise Exceptions::MiniProgram::GetAccessTokenFailed.new(result["errmsg"])
      end

      redis.setex "mp-#{appid}-access-token",  1.5.hours.to_i, result["access_token"]
      result["access_token"]
    end

    def login(code)
      api = "https://api.weixin.qq.com/sns/jscode2session"
      params = {
        appid: appid,
        secret: app_secret,
        js_code: code,
        grant_type: :authorization_code
      }

      response = get(api, params)

      result = JSON.parse(response)

      if result["errcode"]
        logger.error <<~ERROR
        Get session key failed.
        api: #{api}
        result: #{result}
        ERROR
        return MiniProgram::ServiceResult.new(errors: result, message: result["errmsg"], message_type: :error)
      end

      MiniProgram::ServiceResult.new(success: true, data: result.with_indifferent_access)
    end

    # 发送订阅消息
    # @param [MiniProgram::Msg] msg
    # @param [String] to 用户的open id
    def send_msg(msg, to: )
      open_id = to.try(:open_id) || to

      payload = msg.as_json.merge!(touser: open_id)

      api = "https://api.weixin.qq.com/cgi-bin/message/subscribe/send?access_token=#{access_token}"

      result = post(api, payload)

      msg_logger.info("{params: #{payload}, response: #{result}}")
      result.with_indifferent_access
    end

    # 获取用户手机号
    def get_phone_num(code:, encrypted_data:, iv:)
      login_result = login(code)
      return login_result if login_result.failure?

      open_id = login_result.data[:openid]
      session_key = login_result.data[:session_key]

      data = decrypt_phone_data(encrypted_data, iv, session_key)

      phone_num = JSON.parse(data)["phoneNumber"]

      MiniProgram::ServiceResult.new(success: true, data: {
        open_id: open_id,
        phone_num: phone_num
      }.with_indifferent_access)
    end

    def config
      appid, app_secret = if MiniProgram.appid && MiniProgram.app_secret
                            [MiniProgram.appid, MiniProgram.app_secret]

                          # 如果有挂载 WechatPayment 的 engine 时，使用里边的小程序配置
                          elsif Object.const_defined? "WechatPayment"
                            [WechatPayment.sub_appid || WechatPayment.appid, WechatPayment.app_secret]
                          else
                            [nil, nil]
                          end

      Struct.new(:appid, :app_secret).new(appid, app_secret)
    end

    private

    def get(api, payload = {})
      uri = URI(api)

      if payload.present?
        uri.query = URI.encode_www_form(payload)
      end

      Net::HTTP.get(uri)
    end

    def post(api, payload = {}, options = {})
      uri = URI(api)

      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      options = {
        use_ssl: true
      }.merge(options)

      res = Net::HTTP.start(uri.host, uri.port, **options) do |http|
        http.request(req, payload.to_json)
      end

      JSON.parse(res.body)
    end

    def decrypt_phone_data(encrypted_data, iv, session_key)
      aes = OpenSSL::Cipher::AES.new "128-CBC"
      aes.decrypt
      aes.key = Base64::decode64(session_key)
      aes.iv = Base64.decode64(iv)
      aes.update(Base64::decode64(encrypted_data)) + aes.final
    end

    def logger
      @logger ||= MiniProgram::RLogger.make("mini_program")
    end

    def redis
      @redis ||= Redis.current
    end

    def access_token_store_key
      "mp-#{appid}-access-token"
    end

    def msg_logger
      @msg_logger ||= MiniProgram::RLogger.make("wx_msg")
    end

  end
end