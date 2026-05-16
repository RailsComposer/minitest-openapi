# frozen_string_literal: true

require_relative "api/version"
require_relative "api/configuration"
require_relative "api/document_endpoint"
require_relative "api/engine" if defined?(::Rails::Engine)

module Minitest
  module OpenAPI
    # Serves the OpenAPI document produced by minitest-openapi.
    module Api
      class << self
        def configuration
          @configuration ||= Configuration.new
        end

        def configure
          yield configuration
        end
      end
    end
  end
end
