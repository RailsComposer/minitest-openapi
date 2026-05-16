# frozen_string_literal: true

require "test_helper"

class RecorderTest < Minitest::Test
  def setup
    super
    Minitest::OpenAPI.configure do |c|
      c.base = {
        "openapi" => "3.0.3",
        "info" => {"title" => "T", "version" => "1"},
        "components" => {
          "schemas" => {
            "Widget" => {
              "type" => "object", "additionalProperties" => false,
              "required" => ["id"], "properties" => {"id" => {"type" => "integer"}}
            }
          }
        }
      }
    end
  end

  def test_performs_the_request_and_records_the_operation
    api = FakeApi.new([:get, "/widgets"] => FakeApi::Response.new(200, '[{"id":1}]'))

    Minitest::OpenAPI::Recorder.run(
      test: api, verb: :get, request_path: "/widgets", summary: "List widgets",
      response: {status: 200, schema: {"type" => "array", "items" => {"$ref" => "#/components/schemas/Widget"}}}
    )

    assert_equal 1, api.calls.size
    operation = Minitest::OpenAPI.document.to_h.dig("paths", "/widgets", "get")
    assert_equal "List widgets", operation["summary"]
    assert operation.dig("responses", "200", "content", "application/json", "schema")
  end

  def test_validates_the_response_body_against_the_schema
    api = FakeApi.new([:get, "/widgets"] => FakeApi::Response.new(200, '[{"id":"oops"}]'))

    assert_raises(Minitest::OpenAPI::Validator::ResponseMismatch) do
      Minitest::OpenAPI::Recorder.run(
        test: api, verb: :get, request_path: "/widgets",
        response: {status: 200, schema: {"type" => "array", "items" => {"$ref" => "#/components/schemas/Widget"}}}
      )
    end
  end

  def test_uses_doc_path_distinct_from_request_path
    api = FakeApi.new([:get, "/widgets/1"] => FakeApi::Response.new(200, '{"id":1}'))

    Minitest::OpenAPI::Recorder.run(
      test: api, verb: :get, request_path: "/widgets/1", doc_path: "/widgets/{id}",
      response: {status: 200, schema: {"$ref" => "#/components/schemas/Widget"}}
    )

    paths = Minitest::OpenAPI.document.to_h["paths"]
    assert paths.key?("/widgets/{id}")
    refute paths.key?("/widgets/1")
  end

  def test_assert_status_fails_on_a_status_mismatch
    api = FakeApi.new([:get, "/widgets"] => FakeApi::Response.new(500, "{}"))

    assert_raises(Minitest::Assertion) do
      Minitest::OpenAPI::Recorder.run(
        test: api, verb: :get, request_path: "/widgets",
        response: {status: 200}, assert_status: true
      )
    end
  end

  def test_skips_validation_when_disabled
    Minitest::OpenAPI.configuration.validate_responses = false
    api = FakeApi.new([:get, "/widgets"] => FakeApi::Response.new(200, '[{"id":"oops"}]'))

    Minitest::OpenAPI::Recorder.run(
      test: api, verb: :get, request_path: "/widgets",
      response: {status: 200, schema: {"type" => "array", "items" => {"$ref" => "#/components/schemas/Widget"}}}
    )
  end

  def test_sends_a_json_body
    api = FakeApi.new([:post, "/widgets"] => FakeApi::Response.new(201, '{"id":1}'))

    Minitest::OpenAPI::Recorder.run(
      test: api, verb: :post, request_path: "/widgets", body: {name: "New"},
      response: {status: 201, schema: {"$ref" => "#/components/schemas/Widget"}}
    )

    call = api.calls.first
    assert_equal({name: "New"}, call[:options][:params])
    assert_equal :json, call[:options][:as]
  end
end
