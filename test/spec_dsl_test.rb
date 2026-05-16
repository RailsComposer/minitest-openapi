# frozen_string_literal: true

require "test_helper"

# A minitest/spec base that behaves like an integration test, backed by a
# FakeApi. Real usage extends ActionDispatch::IntegrationTest instead; the
# Spec module's `extended` hook gives that class the describe/it DSL.
class FakeApiSpec < Minitest::Spec
  def fake
    @fake ||= FakeApi.new(
      [:get, "/widgets"] => FakeApi::Response.new(200, '[{"id":1}]'),
      [:get, "/widgets/1"] => FakeApi::Response.new(200, '{"id":1}')
    )
  end

  %i[get post patch put delete].each do |verb|
    define_method(verb) { |path, **options| fake.public_send(verb, path, **options) }
  end

  def response
    fake.response
  end
end

# Drives the nested block DSL. When the suite runs, the `it` test that
# run_api_test! defines executes — so this file is itself the spec DSL's
# end-to-end test.
class WidgetsSpecTest < FakeApiSpec
  extend Minitest::OpenAPI::Spec

  api_path "/widgets" do
    api_operation :get, summary: "List widgets" do
      api_response 200, schema: {"type" => "array"} do
        run_api_test!
      end
    end
  end

  api_path "/widgets/{id}" do
    api_operation :get, summary: "Get a widget" do
      api_response 200, schema: {"type" => "object"} do
        run_api_test! { {path: "/widgets/1"} }
      end
    end
  end
end

# Confirms the nesting accumulates metadata down the describe chain.
class SpecMetadataTest < Minitest::Test
  def test_metadata_merges_through_the_nesting
    base = Class.new(Minitest::Spec)
    base.extend(Minitest::OpenAPI::Spec)
    captured = nil

    base.api_path "/things" do
      api_operation :get, summary: "List things", operation_id: "listThings" do
        api_response 200, schema: {"type" => "array"} do
          captured = openapi_metadata
        end
      end
    end

    assert_equal "/things", captured[:path]
    assert_equal :get, captured[:verb]
    assert_equal "List things", captured[:summary]
    assert_equal "listThings", captured[:operation_id]
    assert_equal 200, captured[:response_status]
  end
end
