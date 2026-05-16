# frozen_string_literal: true

require "rails/engine"

module Minitest
  module OpenAPI
    module UI
      # Mountable engine. In the host app's routes:
      #
      #   mount Minitest::OpenAPI::UI::Engine => "/api-docs/ui"
      class Engine < ::Rails::Engine
        isolate_namespace Minitest::OpenAPI::UI
      end
    end
  end
end
