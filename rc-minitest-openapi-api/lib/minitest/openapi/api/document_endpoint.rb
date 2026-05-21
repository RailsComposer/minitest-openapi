# frozen_string_literal: true

require "pathname"

module Minitest
  module OpenAPI
    module Api
      # Rack endpoint that serves the generated OpenAPI document.
      class DocumentEndpoint
        JSON_HEADERS = {"content-type" => "application/json; charset=utf-8"}.freeze

        def call(_env)
          path = resolved_path

          if File.file?(path)
            [200, JSON_HEADERS.dup, [File.read(path)]]
          else
            [404, JSON_HEADERS.dup, [not_found_body]]
          end
        end

        private

        def resolved_path
          configured = Minitest::OpenAPI::Api.configuration.document_path
          return configured if Pathname.new(configured).absolute?

          File.join(Rails.root.to_s, configured)
        end

        def not_found_body
          %({"error":"OpenAPI document not found. Run `bin/rails openapi:generate`."})
        end
      end
    end
  end
end
