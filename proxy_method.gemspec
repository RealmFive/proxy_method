# Maintain your gem's version:
require_relative "./lib/proxy_method/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "proxy_method"
  spec.version     = ProxyMethod::VERSION
  spec.authors     = ["Jaime Bellmyer"]
  spec.email       = ["online@bellmyer.com"]
  spec.homepage    = "https://github.com/Intellifarm/proxy_method"
  spec.summary     = "Prevent running an inherited method directly"

  spec.description = <<-TURTLES
    The purpose of this gem is to prevent directly running the inherited
    methods you choose to block, and instead raise a custom Error message.
    The original method can still be called under a different name.

    This was created to help enforce the use of interactors over directly
    calling ActiveRecord methods like create, save, and update.
  TURTLES

  spec.license     = "MIT"

  spec.files = Dir["{lib,test}/**/*", "Rakefile", "README.md"]
end
