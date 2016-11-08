# -*- encoding: utf-8 -*-
#- 2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license
require File.join File.dirname(__FILE__), 'lib', 'ri_cal', 'version'
Gem::Specification.new do |gem|
  gem.authors       = ["Jon Phenow, Rick DeNatale"]
  gem.email         = ["jon.phenow@tstmedia.com"]
  gem.description   = %q{A new Ruby implementation of RFC2445 iCalendar.

The existing Ruby iCalendar libraries (e.g. icalendar, vpim) provide for parsing and generating icalendar files,
but do not support important things like enumerating occurrences of repeating events.

This is a clean-slate implementation of RFC2445.

A Google group for discussion of this library has been set up http://groups.google.com/group/rical_gem}
  gem.summary       = %q{a new implementation of RFC2445 in Ruby}
  gem.homepage      = "http://github.com/jphenow/ri_cal"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "ri_cal"
  gem.require_paths = ["lib"]
  gem.version       = RiCal::VERSION

  gem.add_dependency 'tzinfo'

  gem.add_development_dependency 'activesupport', "~> 3.0.15"
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rspec-collection_matchers'
  gem.add_development_dependency 'ZenTest'
  gem.add_development_dependency 'awesome_print'

  if gem.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    gem.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
    else
    end
  else
  end
end

