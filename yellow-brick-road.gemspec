$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "yellow-brick-road/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "yellow-brick-road"
  s.version     = YellowBrickRoad::VERSION
  s.authors     = ["alitn"]
  s.email       = [""]
  s.homepage    = "https://github.com/alitn/yellow-brick-road"
  s.summary     = "Closure library on rails"
  s.description = <<-FIN
      A set of tools for integrating google closure library into rails, including:
      Automatic dependency generation of a closure library based application,
      using soy templates both as standalone and as part of the closure library,
      and a managed closure library source which can be shared among rails applications.
    FIN

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["Rakefile", "README.rst"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1"

  s.add_development_dependency "sqlite3"
end
