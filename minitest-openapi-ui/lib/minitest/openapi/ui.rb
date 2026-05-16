# frozen_string_literal: true

require_relative "ui/version"
require_relative "ui/configuration"
require_relative "ui/page_endpoint"
require_relative "ui/engine" if defined?(::Rails::Engine)

module Minitest
  module OpenAPI
    # Renders Swagger UI for an OpenAPI document.
    module UI
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
