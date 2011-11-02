# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ecircle/version"

Gem::Specification.new do |s|
  s.name        = "ecircle"
  s.version     = Ecircle::VERSION
  s.authors     = ["Timo Rößner"]
  s.email       = ["timo.roessner@googlemail.com"]
  s.homepage    = ""
  s.summary     = %q{Ecircle gem}
  s.description = %q{The ecircle gem aims to be a full-fledged client for all ecircle services.}

  s.rubyforge_project = "ecircle"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'
  s.add_dependency 'rake'
  s.add_dependency 'savon', '>=0.9.7'
  s.add_development_dependency 'rspec', '2.6.0'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'ruby-debug19'
end
