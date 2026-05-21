# frozen_string_literal: true

require "minitest/spec"

module Minitest
  module OpenAPI
    # Nested block DSL for minitest/spec users. Extend an integration test
    # class with it; api_path / api_operation / api_response build nested
    # describe blocks and run_api_test! defines the test:
    #
    #   class MediaEntriesApiTest < ActionDispatch::IntegrationTest
    #     extend Minitest::OpenAPI::Spec
    #
    #     api_path "/api/v1/media_entries" do
    #       api_operation :get, summary: "List media entries" do
    #         api_response 200, schema: {"$ref" => "#/components/schemas/MediaEntry"} do
    #           run_api_test!
    #         end
    #       end
    #     end
    #   end
    #
    # Metadata accumulates down the nesting; run_api_test! merges the whole
    # chain. Its optional block runs in the test instance and returns request
    # overrides ({ path:, params:, headers:, body: }) — use it to build a
    # concrete URL from records created in the test.
    module Spec
      def self.extended(base)
        base.extend(Minitest::Spec::DSL) unless base.is_a?(Minitest::Spec::DSL)
      end

      # Metadata declared on this describe merged onto its parent's.
      def openapi_metadata
        inherited = superclass.respond_to?(:openapi_metadata) ? superclass.openapi_metadata : {}
        inherited.merge(@openapi_metadata || {})
      end

      def api_path(path, &block)
        describe("path #{path}") do
          @openapi_metadata = {path: path}
          class_eval(&block)
        end
      end

      def api_operation(verb, **meta, &block)
        describe(verb.to_s) do
          @openapi_metadata = {verb: verb}.merge(meta)
          class_eval(&block)
        end
      end

      def api_response(status, **meta, &block)
        describe("#{status} response") do
          @openapi_metadata = {response_status: status}.merge(meta)
          class_eval(&block)
        end
      end

      def run_api_test!(description = nil, &request_block)
        meta = openapi_metadata
        verb = meta.fetch(:verb) { raise Error, "run_api_test! must be nested in api_operation" }
        status = meta.fetch(:response_status) { raise Error, "run_api_test! must be nested in api_response" }
        doc_path = meta.fetch(:path) { raise Error, "run_api_test! must be nested in api_path" }

        it(description || "conforms to the #{status} response") do
          overrides = request_block ? instance_exec(&request_block) : {}
          overrides ||= {}
          Recorder.run(
            test: self,
            verb: verb,
            request_path: overrides[:path] || doc_path,
            doc_path: doc_path,
            response: {status: status, schema: meta[:schema], description: meta[:description]},
            summary: meta[:summary],
            operation_id: meta[:operation_id],
            description: meta[:operation_description],
            tags: meta[:tags],
            parameters: meta[:parameters],
            request_body: meta[:request_body],
            params: overrides[:params],
            headers: overrides[:headers],
            body: overrides[:body],
            assert_status: true
          )
        end
      end
    end
  end
end
