# frozen_string_literal: true

require "test_helper"

class ValidatorTest < Minitest::Test
  Mismatch = Minitest::OpenAPI::Validator::ResponseMismatch

  def components
    {
      "schemas" => {
        "Widget" => {
          "type" => "object",
          "additionalProperties" => false,
          "required" => ["id", "name"],
          "properties" => {
            "id" => {"type" => "integer"},
            "name" => {"type" => "string", "nullable" => true}
          }
        }
      }
    }
  end

  def validator
    Minitest::OpenAPI::Validator.new(components)
  end

  def test_passes_a_conforming_body
    schema = {"$ref" => "#/components/schemas/Widget"}
    validator.validate!(schema, {"id" => 1, "name" => "Sprocket"}, context: "test")
  end

  def test_allows_null_for_a_nullable_field
    schema = {"$ref" => "#/components/schemas/Widget"}
    validator.validate!(schema, {"id" => 1, "name" => nil}, context: "test")
  end

  def test_rejects_a_wrong_type
    schema = {"$ref" => "#/components/schemas/Widget"}
    error = assert_raises(Mismatch) do
      validator.validate!(schema, {"id" => "not-an-integer", "name" => "x"}, context: "GET /widgets")
    end
    assert_match(/GET \/widgets/, error.message)
  end

  def test_rejects_a_missing_required_field
    schema = {"$ref" => "#/components/schemas/Widget"}
    assert_raises(Mismatch) do
      validator.validate!(schema, {"id" => 1}, context: "test")
    end
  end

  def test_rejects_an_unexpected_field_when_additional_properties_false
    schema = {"$ref" => "#/components/schemas/Widget"}
    assert_raises(Mismatch) do
      validator.validate!(schema, {"id" => 1, "name" => "x", "extra" => true}, context: "test")
    end
  end

  def test_validates_arrays_of_a_ref
    schema = {"type" => "array", "items" => {"$ref" => "#/components/schemas/Widget"}}
    validator.validate!(schema, [{"id" => 1, "name" => "a"}, {"id" => 2, "name" => nil}], context: "test")
    assert_raises(Mismatch) do
      validator.validate!(schema, [{"id" => 1}], context: "test")
    end
  end

  def test_nil_schema_is_a_noop
    validator.validate!(nil, {"anything" => true}, context: "test")
  end
end
