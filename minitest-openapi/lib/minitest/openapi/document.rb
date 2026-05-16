# frozen_string_literal: true

module Minitest
  module OpenAPI
    # The in-memory OpenAPI document. Tests record operations into it as they
    # run; #to_h merges those operations into the base document's `paths`.
    class Document
      def initialize(base)
        @base = base
        @paths = {}
      end

      # The base document's reusable schemas, used to resolve $refs while
      # validating responses.
      def components
        @base["components"] || {}
      end

      # Records one operation/response pair. Called by the recorder.
      def record(verb:, path:, status:, schema: nil, summary: nil, operation_id: nil,
        description: nil, tags: nil, parameters: nil, request_body: nil,
        response_description: nil, content_type: "application/json")
        operation = ((@paths[path] ||= {})[verb.to_s.downcase] ||= {})
        operation["summary"] ||= summary if summary
        operation["operationId"] ||= operation_id if operation_id
        operation["description"] ||= description if description
        operation["tags"] ||= tags if tags && !tags.empty?
        operation["parameters"] ||= parameters if parameters && !parameters.empty?
        operation["requestBody"] ||= request_body if request_body

        responses = (operation["responses"] ||= {})
        entry = (responses[status.to_s] ||= {})
        entry["description"] ||= response_description || "#{status} response"
        if schema
          entry["content"] ||= {content_type => {"schema" => schema}}
        end
        operation
      end

      # The assembled document: the base with recorded operations merged into
      # `paths`, paths sorted for a stable diff.
      def to_h
        doc = deep_dup(@base)
        paths = doc["paths"] || {}
        @paths.keys.sort.each do |path|
          (paths[path] ||= {}).merge!(@paths[path])
        end
        doc["paths"] = paths
        doc
      end

      def empty?
        @paths.empty?
      end

      private

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
