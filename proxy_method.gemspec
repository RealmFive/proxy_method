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
    methods you choose to block at either the class or instance level, and
    instead do one of two things: run an alternative block which may or may
    not invoke the original method, or simply raise an error message.

    The error message can be customized. The original method can still be
    called under a different name. The entire object or class can return
    "unproxied" versions of themselves to preserve the original functionality.

    This was originally created to help enforce the use of interactors over
    directly calling ActiveRecord methods like create, save, and update. As
    with any metaprogramming, this gives you plenty of rope to hang yourself
    if you try to get too "clever". Treat this library like salt; use
    sparingly, because over time its cumulative effect will kill you :)
  TURTLES

  spec.license     = "MIT"

  spec.files = Dir["{lib,test}/**/*", "Rakefile", "README.md"]
end
