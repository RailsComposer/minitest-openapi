# frozen_string_literal: true

module Minitest
  module OpenAPI
    module Api
      class Configuration
        # Path to the generated document, relative to Rails.root (or absolute).
        attr_accessor :document_path

        def initialize
          @document_path = "openapi/openapi.json"
        end
      end
    end
  end
end
