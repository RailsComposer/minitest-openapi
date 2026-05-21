# frozen_string_literal: true

require "json_schemer"

module Minitest
  module OpenAPI
    # Validates a response body against the schema a test declared for it.
    # OpenAPI schemas are JSON Schema with a few divergences; `nullable: true`
    # is normalized to a "null" type so a standard JSON Schema validator can
    # be used. $refs of the form #/components/schemas/X resolve against the
    # base document's components.
    class Validator
      class ResponseMismatch < StandardError; end

      def initialize(components)
        @components = components || {}
      end

      # Raises ResponseMismatch if `body` does not satisfy `schema`.
      def validate!(schema, body, context:)
        return if schema.nil?

        root = {
          "$schema" => "https://json-schema.org/draft/2020-12/schema",
          "allOf" => [normalize(schema)],
          "components" => normalize(@components)
        }
        errors = JSONSchemer.schema(root).validate(body).to_a
        return if errors.empty?

        raise ResponseMismatch, "#{context} response did not match its declared schema:\n" +
          errors.first(8).map { |e| "  #{format_error(e)}" }.join("\n")
      end

      private

      def format_error(error)
        pointer = error["data_pointer"].to_s
        location = pointer.empty? ? "(root)" : pointer
        "#{location}: #{error["type"]}"
      end

      # OpenAPI `nullable: true` has no JSON Schema equivalent. Normalize it:
      # add "null" to `type`, and — since an `enum` is exhaustive — add `nil`
      # to any `enum` so a null value declared nullable is actually allowed.
      def normalize(node)
        case node
        when Hash
          normalized = node.each_with_object({}) { |(k, v), acc| acc[k] = normalize(v) }
          if normalized.delete("nullable")
            if normalized["type"].is_a?(String)
              normalized["type"] = [normalized["type"], "null"]
            end
            if normalized["enum"].is_a?(Array) && !normalized["enum"].include?(nil)
              normalized["enum"] += [nil]
            end
          end
          normalized
        when Array
          node.map { |child| normalize(child) }
        else
          node
        end
      end
    end
  end
end
