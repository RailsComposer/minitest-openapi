# frozen_string_literal: true

require_relative "lib/minitest/openapi/version"

Gem::Specification.new do |spec|
  spec.name = "minitest-openapi"
  spec.version = Minitest::OpenAPI::VERSION
  spec.authors = ["RailsComposer"]
  spec.summary = "Generate an OpenAPI document from your minitest API tests."
  spec.description = "minitest-openapi turns Rails minitest integration tests into the " \
    "source of truth for an OpenAPI 3.0 document. Tests declare each operation and its " \
    "response schema, the live response is validated against that schema as the suite " \
    "runs, and the openapi:generate rake task writes the document. An rswag-style block " \
    "DSL and plain helper methods are both supported."
  spec.homepage = "https://github.com/RailsComposer/minitest-openapi"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "minitest", ">= 5.0"
  spec.add_dependency "json_schemer", ">= 2.0"
  spec.add_dependency "railties", ">= 7.1"
end
