# frozen_string_literal: true

require "test_helper"

class DocumentTest < Minitest::Test
  def base
    {"openapi" => "3.0.3", "info" => {"title" => "T", "version" => "1"},
     "components" => {"schemas" => {"Widget" => {"type" => "object"}}}}
  end

  def test_records_an_operation_into_paths
    doc = Minitest::OpenAPI::Document.new(base)
    doc.record(verb: :get, path: "/widgets", status: 200, summary: "List widgets",
      schema: {"type" => "array"})

    result = doc.to_h
    operation = result.dig("paths", "/widgets", "get")
    assert_equal "List widgets", operation["summary"]
    assert_equal "200 response", operation.dig("responses", "200", "description")
    assert_equal({"type" => "array"},
      operation.dig("responses", "200", "content", "application/json", "schema"))
  end

  def test_records_an_operation_id
    doc = Minitest::OpenAPI::Document.new(base)
    doc.record(verb: :get, path: "/widgets", status: 200, operation_id: "listWidgets")

    assert_equal "listWidgets", doc.to_h.dig("paths", "/widgets", "get", "operationId")
  end

  def test_merges_multiple_responses_on_one_operation
    doc = Minitest::OpenAPI::Document.new(base)
    doc.record(verb: :get, path: "/widgets/{id}", status: 200, schema: {"type" => "object"})
    doc.record(verb: :get, path: "/widgets/{id}", status: 404)

    responses = doc.to_h.dig("paths", "/widgets/{id}", "get", "responses")
    assert_equal %w[200 404], responses.keys.sort
  end

  def test_sorts_paths_for_a_stable_document
    doc = Minitest::OpenAPI::Document.new(base)
    doc.record(verb: :get, path: "/zebras", status: 200)
    doc.record(verb: :get, path: "/aardvarks", status: 200)

    assert_equal ["/aardvarks", "/zebras"], doc.to_h["paths"].keys
  end

  def test_preserves_the_base_document
    doc = Minitest::OpenAPI::Document.new(base)
    result = doc.to_h
    assert_equal "3.0.3", result["openapi"]
    assert result.dig("components", "schemas", "Widget")
  end

  def test_exposes_components_for_ref_resolution
    doc = Minitest::OpenAPI::Document.new(base)
    assert doc.components.dig("schemas", "Widget")
  end
end
