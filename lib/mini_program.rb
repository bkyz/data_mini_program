require "mini_program/version"
require "mini_program/railtie"
require "mini_program/client"
require "mini_program/msg"

module MiniProgram
  # Your code goes here...
  mattr_accessor :appid, :app_secret

  def self.setup
    yield self if block_given?
  end
end
