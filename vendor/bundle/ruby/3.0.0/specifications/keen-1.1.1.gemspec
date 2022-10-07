# -*- encoding: utf-8 -*-
# stub: keen 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "keen".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Kleissner".freeze, "Joe Wegner".freeze]
  s.date = "2017-08-07"
  s.description = "Send events and build analytics features into your Ruby applications.".freeze
  s.email = "opensource@keen.io".freeze
  s.homepage = "https://github.com/keenlabs/keen-gem".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Keen IO API Client".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<multi_json>.freeze, ["~> 1.12"])
    s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.5"])
    s.add_development_dependency(%q<guard>.freeze, ["~> 2.14"])
    s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
    s.add_development_dependency(%q<rb-inotify>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<rb-fsevent>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<rb-fchange>.freeze, ["~> 0.0.6"])
    s.add_development_dependency(%q<ruby_gntp>.freeze, ["~> 0.3"])
    s.add_development_dependency(%q<rb-readline>.freeze, ["~> 0.5"])
  else
    s.add_dependency(%q<multi_json>.freeze, ["~> 1.12"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.5"])
    s.add_dependency(%q<guard>.freeze, ["~> 2.14"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
    s.add_dependency(%q<rb-inotify>.freeze, ["~> 0.9"])
    s.add_dependency(%q<rb-fsevent>.freeze, ["~> 0.9"])
    s.add_dependency(%q<rb-fchange>.freeze, ["~> 0.0.6"])
    s.add_dependency(%q<ruby_gntp>.freeze, ["~> 0.3"])
    s.add_dependency(%q<rb-readline>.freeze, ["~> 0.5"])
  end
end
