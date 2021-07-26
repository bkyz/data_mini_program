require_relative "lib/mini_program/version"

Gem::Specification.new do |spec|
  spec.name        = "mini_program"
  spec.version     = MiniProgram::VERSION
  spec.authors     = ["ian"]
  spec.email       = ["ianlynxk@gmail.com"]
  spec.homepage    = "https://github.com/otorain"
  spec.summary     = "小程序api开发工具"
  spec.description = "登录授权，发送订阅消息"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/otorain/mini_program"
  spec.metadata["changelog_uri"] = "https://github.com/otorain/mini_program/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.4"
  spec.add_dependency "redis"
end
