# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adrift/version"

Gem::Specification.new do |s|
  s.name        = "adrift"
  s.version     = Adrift::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gabriel Andretta"]
  s.email       = ["ohhgabriel@gmail.com"]
  s.homepage    = ""
  s.summary     = "Simplistic attachment management"
  s.description = "Simplistic attachment management"

  s.rubyforge_project = "adrift"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")

  s.require_paths = ["lib"]

  s.has_rdoc = true

  s.add_dependency 'activesupport', '~>3.0'
  s.add_dependency 'i18n'

  s.add_development_dependency 'rspec', '~>2.4'
  s.add_development_dependency 'cucumber', '~>0.10'
  s.add_development_dependency 'activerecord', '~>3.0'
  s.add_development_dependency 'dm-core', '~>1.0'
  s.add_development_dependency 'dm-migrations'
  s.add_development_dependency 'dm-validations'
  s.add_development_dependency 'dm-sqlite-adapter'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'ZenTest'
  s.add_development_dependency 'rdoc', '~>3.5'
end
