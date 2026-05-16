# frozen_string_literal: true

require "test_helper"
require "tempfile"

class ApiDocumentEndpointTest < Minitest::Test
  def test_serves_the_document_when_present
    Tempfile.create(["openapi", ".json"]) do |file|
      file.write('{"openapi":"3.0.3"}')
      file.flush
      Minitest::OpenAPI::Api.configure { |c| c.document_path = file.path }

      status, headers, body = Minitest::OpenAPI::Api::DocumentEndpoint.new.call({})

      assert_equal 200, status
      assert_match %r{application/json}, headers["content-type"]
      assert_equal '{"openapi":"3.0.3"}', body.join
    end
  end

  def test_returns_404_when_the_document_is_missing
    Minitest::OpenAPI::Api.configure { |c| c.document_path = "/no/such/openapi.json" }

    status, _headers, body = Minitest::OpenAPI::Api::DocumentEndpoint.new.call({})

    assert_equal 404, status
    assert_match(/not found/i, body.join)
  end
end
