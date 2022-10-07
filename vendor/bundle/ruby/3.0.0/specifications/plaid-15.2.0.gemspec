# -*- encoding: utf-8 -*-
# stub: plaid 15.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "plaid".freeze
  s.version = "15.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Plaid".freeze]
  s.date = "2022-03-31"
  s.description = "Ruby gem wrapper for the Plaid API. Read more at the homepage, the wiki, or in the Plaid documentation.".freeze
  s.email = ["".freeze]
  s.homepage = "https://plaid.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "The Plaid API Ruby Gem".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faraday>.freeze, ["~> 1.0", ">= 1.0.1"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6", ">= 3.6.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.2.9"])
    s.add_development_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_development_dependency(%q<minitest-around>.freeze, ["~> 0.5.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 13.0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.91.0"])
  else
    s.add_dependency(%q<faraday>.freeze, ["~> 1.0", ">= 1.0.1"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.6", ">= 3.6.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.2.9"])
    s.add_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_dependency(%q<minitest-around>.freeze, ["~> 0.5.0"])
    s.add_dependency(%q<rake>.freeze, [">= 13.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.91.0"])
  end
end
