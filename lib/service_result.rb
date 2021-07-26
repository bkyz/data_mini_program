module MiniProgram
  class ServiceResult
    attr_accessor :success,
                  :errors,
                  :data,
                  :message,
                  :message_type

    def initialize(success: false,
                   errors: nil,
                   message: nil,
                   message_type: nil,
                   data: nil)
      self.success = success
      self.data = data
      self.errors = errors.is_a?(Enumerable) ? errors : [errors]
      self.message = message
      self.message_type = message_type
    end

    alias success? :success

    def failure?
      !success?
    end

    def on_success
      yield(self) if success?
    end

    def on_failure
      yield(self) if failure?
    end

    def get_message_type
      if message_type.present?
        message_type.to_sym
      elsif success?
        :notice
      else
        :error
      end
    end
  end
end
