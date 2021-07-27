
require "minitest/autorun"
require "test_helper"

class ClientTest < ActiveSupport::TestCase

  def setup

  end

  test "默认情况下，并且没有对 MiniProgram 进行任何配置, Client 的 appid 和 app_secret 为空" do
    MiniProgram.appid = "appid"
    MiniProgram.app_secret = "app_secret"
    @mp = MiniProgram::Client.new

    assert_equal @mp.appid, "appid"
    assert_equal @mp.app_secret, "app_secret"
  end

  test "在对 MiniProgram 进行配置后，Client 返回的 appid 和 app_secret 为设定的值" do
    MiniProgram.appid = "appid"
    MiniProgram.app_secret = "app_secret"
    @mp = MiniProgram::Client.new

    assert_equal @mp.appid, "appid"
    assert_equal @mp.app_secret, "app_secret"
  end

  test "在有微信支付 Engine ，MiniProgram 没有配置，并且 Engine 已经配置好 appid 和 app_secret 的情况下，Client 使用支付 Engine 的 appid 和 app_secret" do
    Object.const_set("WechatPayment", MiniTest::Mock.new)

    3.times {WechatPayment.expect(:appid, "payment_appid")}
    3.times {WechatPayment.expect(:app_secret, "payment_app_secret")}
    3.times {WechatPayment.expect(:sub_appid, nil)}
    3.times {WechatPayment.expect(:sub_app_secret, nil)}

    MiniProgram.appid = nil
    MiniProgram.app_secret = nil

    @mp = MiniProgram::Client.new

    assert_equal @mp.appid, "payment_appid"
    assert_equal @mp.app_secret, "payment_app_secret"
  end


  test "在有微信支付 Engine，MiniProgram 没有配置，并且 Engine 配置了 appid，app_secret, sub_appid, sub_app_secret 的情况下，Client 使用支付 Engine 的 sub_appid 和 sub_app_secret" do
    Object.const_set("WechatPayment", MiniTest::Mock.new)

    3.times {WechatPayment.expect(:appid, "payment_appid")}
    3.times {WechatPayment.expect(:app_secret, "payment_app_secret")}
    3.times {WechatPayment.expect(:sub_appid, "sub_payment_appid")}
    3.times {WechatPayment.expect(:sub_app_secret, "sub_payment_app_secret")}

    MiniProgram.appid = nil
    MiniProgram.app_secret = nil

    @mp = MiniProgram::Client.new

    assert_equal @mp.appid, "sub_payment_appid"
    assert_equal @mp.app_secret, "sub_payment_app_secret"
  end

end