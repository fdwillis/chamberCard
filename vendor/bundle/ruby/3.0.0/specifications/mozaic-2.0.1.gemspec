# -*- encoding: utf-8 -*-
# stub: mozaic 2.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "mozaic".freeze
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jonas H\u00FCbotter".freeze]
  s.date = "2018-02-17"
  s.description = "Mozaic is an opinionated layout engine for Rails. It simplifies handling numerous layouts and components.".freeze
  s.email = "me@jonhue.me".freeze
  s.homepage = "https://github.com/jonhue/mozaic".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Mozaic is an opinionated layout engine for Rails".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0"])
    s.add_runtime_dependency(%q<nestive-rails>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.52"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 5.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0"])
    s.add_dependency(%q<nestive-rails>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.52"])
  end
end
