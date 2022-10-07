# -*- encoding: utf-8 -*-
# stub: pwa 4.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "pwa".freeze
  s.version = "4.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jonas H\u00FCbotter".freeze]
  s.date = "2019-12-22"
  s.description = "Add a service worker and a manifest to your app, for it to be recognized as a PWA and accessed without a network connection.".freeze
  s.email = "me@jonhue.me".freeze
  s.homepage = "https://github.com/jonhue/pwa".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Progressive Web Apps for Rails".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<mozaic>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<mozaic>.freeze, ["~> 2.0"])
    s.add_dependency(%q<railties>.freeze, [">= 5.0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
  end
end
