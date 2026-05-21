# frozen_string_literal: true

require "json"
require "yaml"

module Minitest
  module OpenAPI
    # Per-suite settings. Configure in test_helper.rb:
    #
    #   Minitest::OpenAPI.configure do |c|
    #     c.output_path = "openapi/v1/openapi.json"
    #     c.base = "openapi/base.json"   # or a Hash
    #   end
    class Configuration
      # Where openapi:generate writes the document (relative to Rails.root).
      attr_accessor :output_path

      # Validate each response body against its declared schema as tests run.
      attr_accessor :validate_responses

      DEFAULT_BASE = {
        "openapi" => "3.0.3",
        "info" => {"title" => "API", "version" => "1.0.0"},
        "components" => {"schemas" => {}}
      }.freeze

      def initialize
        @output_path = "openapi/openapi.json"
        @validate_responses = true
        @base = deep_dup(DEFAULT_BASE)
      end

      # The base document — everything not derived from tests (info, servers,
      # security schemes, reusable component schemas). A Hash, or a path to a
      # JSON/YAML file. Test-recorded operations are merged into `paths`.
      attr_reader :base

      def base=(value)
        @base =
          case value
          when Hash then value
          when String then load_base_file(value)
          else raise ArgumentError, "base must be a Hash or a file path"
          end
      end

      def base_document
        deep_dup(@base)
      end

      private

      def load_base_file(path)
        resolved = Minitest::OpenAPI.resolve_path(path)
        content = File.read(resolved)
        path.end_with?(".json") ? JSON.parse(content) : YAML.safe_load(content)
      end

      def deep_dup(obj)
        case obj
        when Hash then obj.transform_values { |v| deep_dup(v) }
        when Array then obj.map { |v| deep_dup(v) }
        else obj
        end
      end
    end
  end
end
