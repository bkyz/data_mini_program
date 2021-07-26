require "mini_program/version"
require "mini_program/railtie"
require "mini_program/client"
require "mini_program/msg"
require "r_logger"
require "service_result"

module MiniProgram
  # Your code goes here...
  mattr_accessor :appid, :app_secret

  def self.setup
    yield self if block_given?
  end
end
