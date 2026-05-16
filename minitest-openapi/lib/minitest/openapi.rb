# frozen_string_literal: true

require "json"
require "yaml"
require "pathname"
require "fileutils"
require "minitest"

require_relative "openapi/version"
require_relative "openapi/configuration"
require_relative "openapi/document"
require_relative "openapi/validator"
require_relative "openapi/recorder"
require_relative "openapi/dsl"
require_relative "openapi/spec"

require_relative "openapi/railtie" if defined?(Rails::Railtie)

module Minitest
  # Generates an OpenAPI 3.0 document from minitest API tests. Tests declare
  # each operation and its response schema; the live response is validated
  # against that schema as the suite runs; `openapi:generate` writes the doc.
  module OpenAPI
    class Error < StandardError; end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end

      # The document being assembled this run.
      def document
        @document ||= Document.new(configuration.base_document)
      end

      # Component schemas available for $ref resolution during validation.
      def components
        document.components
      end

      # Drops the accumulated document (used between isolated test runs).
      def reset!
        @document = nil
      end

      # Writes the assembled document. Returns the absolute path written.
      def generate!(path = nil)
        target = resolve_path(path || configuration.output_path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, "#{JSON.pretty_generate(document.to_h)}\n")
        target
      end

      # Resolves a path relative to Rails.root when available, else the cwd.
      def resolve_path(path)
        return path.to_s if Pathname.new(path).absolute?

        root = defined?(Rails) && Rails.respond_to?(:root) && Rails.root
        File.join((root || Dir.pwd).to_s, path)
      end
    end
  end
end

# When MINITEST_OPENAPI is set (the openapi:generate rake task sets it), write
# the document once the suite finishes. Registered here, at require time,
# rather than via a minitest plugin file: plugin auto-discovery is unreliable
# under Rails' test runner and with git-sourced gems, whereas test_helper.rb
# requires this file directly. Ordinary test runs leave MINITEST_OPENAPI unset
# and are unaffected (responses are still validated; the file is just not
# written).
if ENV["MINITEST_OPENAPI"]
  Minitest.after_run do
    warn "minitest-openapi: wrote #{Minitest::OpenAPI.generate!}"
  end
end
