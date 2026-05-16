# frozen_string_literal: true

module Minitest
  module OpenAPI
    module UI
      class Configuration
        # URL the Swagger UI page loads the OpenAPI document from. Point this
        # at wherever minitest-openapi-api is mounted.
        attr_accessor :openapi_url

        # Page <title>.
        attr_accessor :page_title

        # swagger-ui-dist version loaded from the jsDelivr CDN.
        attr_accessor :swagger_ui_version

        def initialize
          @openapi_url = "/api-docs"
          @page_title = "API documentation"
          @swagger_ui_version = "5.17.14"
        end
      end
    end
  end
end
