# frozen_string_literal: true

require "test_helper"

# Exercises the helper-method DSL. The test class itself plays the part of the
# integration test: it includes the DSL and provides the request verbs.
class DSLTest < Minitest::Test
  include Minitest::OpenAPI::DSL

  def setup
    super
    @fake = FakeApi.new(
      [:get, "/widgets"] => FakeApi::Response.new(200, '[{"id":1}]'),
      [:post, "/widgets"] => FakeApi::Response.new(201, '{"id":2}')
    )
  end

  # Route the DSL's request verbs + response through the FakeApi.
  %i[get post patch put delete].each do |verb|
    define_method(verb) { |path, **opts| @fake.public_send(verb, path, **opts) }
  end

  def response
    @fake.response
  end

  def test_openapi_get_records_and_returns_the_response
    schema = {"type" => "array", "items" => {"type" => "object"}}
    result = openapi_get "/widgets", summary: "List widgets", response: {status: 200, schema: schema}

    assert_equal 200, result.status
    operation = Minitest::OpenAPI.document.to_h.dig("paths", "/widgets", "get")
    assert_equal "List widgets", operation["summary"]
  end

  def test_openapi_post_records_a_create
    openapi_post "/widgets", summary: "Create a widget", body: {name: "x"},
      response: {status: 201, schema: {"type" => "object"}}

    operation = Minitest::OpenAPI.document.to_h.dig("paths", "/widgets", "post")
    assert operation.dig("responses", "201")
  end

  def test_openapi_get_records_an_operation_id
    openapi_get "/widgets", operation_id: "listWidgets", response: 200

    operation = Minitest::OpenAPI.document.to_h.dig("paths", "/widgets", "get")
    assert_equal "listWidgets", operation["operationId"]
  end

  def test_response_with_only_a_status_records_no_schema
    openapi_get "/widgets", response: 200

    entry = Minitest::OpenAPI.document.to_h.dig("paths", "/widgets", "get", "responses", "200")
    assert_nil entry["content"]
  end
end
