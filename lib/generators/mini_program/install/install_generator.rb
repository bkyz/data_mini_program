class MiniProgram::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)
  def create_initializer_file
    copy_file "initializer.rb", "config/initializers/mini_program.rb"
  end
end
