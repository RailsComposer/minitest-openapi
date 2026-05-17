# frozen_string_literal: true

module Minitest
  module OpenAPI
    # The in-memory OpenAPI document. Tests record operations into it as they
    # run; #to_h merges those operations into the base document's `paths`.
    class Document
      # Canonical ordering, so the emitted document is identical regardless
      # of the order tests recorded into it (minitest randomizes test order).
      VERB_ORDER = %w[get put post patch delete options head trace].freeze
      OPERATION_KEYS = %w[
        tags summary description operationId parameters requestBody responses
      ].freeze

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
      # `paths`. Paths, verbs, operation keys, and response statuses are all
      # canonically ordered, so the output is stable across test runs.
      def to_h
        doc = deep_dup(@base)
        base_paths = doc["paths"] || {}
        paths = {}
        (base_paths.keys | @paths.keys).sort.each do |path|
          merged = (base_paths[path] || {}).merge(@paths[path] || {})
          paths[path] = canonical_path_item(merged)
        end
        doc["paths"] = paths
        doc
      end

      def empty?
        @paths.empty?
      end

      private

      # Orders the verbs within a path item, and each operation's keys.
      def canonical_path_item(verbs)
        ordered = {}
        (VERB_ORDER & verbs.keys).each { |verb| ordered[verb] = canonical_operation(verbs[verb]) }
        (verbs.keys - VERB_ORDER).sort.each { |key| ordered[key] = verbs[key] }
        ordered
      end

      # Orders an operation's keys and sorts its responses by status code.
      def canonical_operation(operation)
        ordered = {}
        OPERATION_KEYS.each { |key| ordered[key] = operation[key] if operation.key?(key) }
        (operation.keys - OPERATION_KEYS).sort.each { |key| ordered[key] = operation[key] }
        if ordered["responses"].is_a?(Hash)
          ordered["responses"] = ordered["responses"].sort_by { |status, _| status.to_i }.to_h
        end
        ordered
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
