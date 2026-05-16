# frozen_string_literal: true

require "rails/engine"

module Minitest
  module OpenAPI
    module Api
      # Mountable engine. In the host app's routes:
      #
      #   mount Minitest::OpenAPI::Api::Engine => "/api-docs"
      #
      # The document is then served at GET /api-docs.
      class Engine < ::Rails::Engine
        isolate_namespace Minitest::OpenAPI::Api
      end
    end
  end
end
