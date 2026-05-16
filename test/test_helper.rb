# frozen_string_literal: true

require "minitest/autorun"
require "minitest/openapi"
require "minitest/openapi/api"
require "minitest/openapi/ui"

require_relative "support/fake_api"

module ResetMinitestOpenAPI
  def setup
    super
    Minitest::OpenAPI.instance_variable_set(:@configuration, nil)
    Minitest::OpenAPI.reset!
    Minitest::OpenAPI::Api.instance_variable_set(:@configuration, nil)
    Minitest::OpenAPI::UI.instance_variable_set(:@configuration, nil)
  end
end

Minitest::Test.prepend(ResetMinitestOpenAPI)
