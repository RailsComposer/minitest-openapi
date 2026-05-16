# frozen_string_literal: true

module Minitest
  module OpenAPI
    # Helper-method DSL for classic class-based integration tests:
    #
    #   class MediaEntriesApiTest < ActionDispatch::IntegrationTest
    #     include Minitest::OpenAPI::DSL
    #
    #     test "lists media entries" do
    #       openapi_get "/api/v1/media_entries",
    #         summary: "List media entries",
    #         response: {status: 200, schema: {"$ref" => "#/components/schemas/MediaEntry"}}
    #       assert_response :success
    #     end
    #   end
    #
    # Each openapi_<verb> performs the request, validates the response body
    # against the declared schema, records the operation, and returns the
    # response so further assertions can be made.
    module DSL
      %i[get post patch put delete].each do |verb|
        define_method(:"openapi_#{verb}") do |request_path, response:, doc_path: nil, summary: nil, operation_id: nil, description: nil, tags: nil, parameters: nil, params: nil, headers: nil, body: nil, request_body: nil|
          Recorder.run(
            test: self, verb: verb, request_path: request_path, doc_path: doc_path,
            response: response, summary: summary, operation_id: operation_id,
            description: description, tags: tags, parameters: parameters,
            params: params, headers: headers, body: body, request_body: request_body
          )
        end
      end
    end
  end
end
