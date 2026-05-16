# frozen_string_literal: true

module Minitest
  module OpenAPI
    # Shared engine behind both DSLs: performs the HTTP request through the
    # integration test, validates the response body against the declared
    # schema, and records the operation into the document.
    module Recorder
      module_function

      # test         - the ActionDispatch::IntegrationTest instance
      # verb          - :get/:post/:patch/:put/:delete
      # request_path  - the URL to request
      # doc_path      - templated path recorded in the document (default: request_path)
      # response      - an Integer status, or { status:, schema:, description: }
      # assert_status - when true, fails the test if the status differs
      def run(test:, verb:, request_path:, response:, doc_path: nil, summary: nil,
        description: nil, tags: nil, parameters: nil, params: nil, headers: nil,
        body: nil, request_body: nil, assert_status: false)
        spec = normalize_response(response)
        doc_path ||= request_path

        options = {}
        payload = body.nil? ? params : body
        options[:params] = payload unless payload.nil?
        options[:headers] = headers if headers
        options[:as] = :json unless body.nil?
        test.public_send(verb, request_path, **options)

        actual = test.response

        Minitest::OpenAPI.document.record(
          verb: verb, path: doc_path, status: spec[:status], schema: spec[:schema],
          summary: summary, description: description, tags: tags,
          parameters: parameters, request_body: request_body,
          response_description: spec[:description]
        )

        if assert_status
          test.assert_equal spec[:status], actual.status,
            "expected #{verb.to_s.upcase} #{request_path} to respond #{spec[:status]}, " \
            "got #{actual.status}"
        end

        if Minitest::OpenAPI.configuration.validate_responses &&
            spec[:schema] && actual.status == spec[:status]
          Validator.new(Minitest::OpenAPI.components).validate!(
            spec[:schema], parse_body(actual),
            context: "#{verb.to_s.upcase} #{doc_path} -> #{spec[:status]}"
          )
        end

        actual
      end

      def normalize_response(response)
        case response
        when Integer
          {status: response, schema: nil, description: nil}
        when Hash
          {status: Integer(response.fetch(:status)), schema: response[:schema],
           description: response[:description]}
        else
          raise ArgumentError, "response: must be a status Integer or a Hash with :status"
        end
      end

      def parse_body(actual)
        JSON.parse(actual.body)
      rescue JSON::ParserError
        raise Validator::ResponseMismatch,
          "response body was not valid JSON (HTTP #{actual.status})"
      end
    end
  end
end
