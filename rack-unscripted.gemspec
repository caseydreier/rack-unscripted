# -*- encoding: utf-8 -*-
# $:.push File.expand_path("lib", __FILE__)
require File.expand_path('../lib/version.rb', __FILE__)
Gem::Specification.new do |s|
  s.name        = "rack-unscripted"
  s.version     = Rack::Unscripted::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Casey Dreier"]
  s.email       = ["casey.dreier@gmail.com"]
  s.homepage    = "https://github.com/daphonz/rack-unscripted"
  s.summary     = %q{Rack middleware to add a textual warning to your site for users who have Javascript disabled.}
  s.description = %q{Many sites these days absolutely require a user to have Javascript enabled in order to function properly. You may have one yourself. Users that either have JS disabled or only allow trusted sites to execute JS should be given a textual warning that their user experience may be hampered.

This Rack middleware will append a div with a customizable message to the HTTP response body, right after the opening <body> tag. This warning message is then hidden via a CSS command that is written by Javascript.
}

  s.rubyforge_project = "rack-unscripted"
  s.extra_rdoc_files  = ['README.rdoc']
  s.license           = 'MIT'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rack-test')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
  end

end
