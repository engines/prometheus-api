# frozen_string_literal: true

Kernel.load "./lib/loki/api/version.rb"

Gem::Specification.new do |s|
  s.name = "loki-api"
  s.version = Loki::API::VERSION
  s.date = Time.now.strftime("%Y-%m-%d")
  s.summary = "Loki API Client"
  s.email = "rgh@engines.org"
  s.homepage = "http://github.com/engines/prometheus-api"
  s.description = "Loki API Client focusing on safety and ease of use"
  s.required_ruby_version = ">= 2.7.0"

  s.author = "Engines"
  s.licenses = ["MIT"]

  s.metadata = {
    "bug_tracker_uri"   => "#{s.homepage}/issues",
    "changelog_uri"     => "#{s.homepage}/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/loki-api",
    "homepage_uri"      => s.homepage,
    "source_code_uri"   => s.homepage
  }

  s.add_dependency "addressable",  "~> 2.7"
  s.add_dependency "dry-monads",   "~> 1.3"
  s.add_dependency "dry-struct",   "~> 1.0"
  s.add_dependency "dry-types",    "~> 1.2"
  s.add_dependency "faraday",      "~> 1.0"
  s.add_dependency "logging",      "~> 2.3"
  s.add_dependency "multi_json",   "~> 1"

  s.files = `git ls-files -z lib`.split(/\0/)
end
