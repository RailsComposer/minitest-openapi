# frozen_string_literal: true

require "erb"

module Minitest
  module OpenAPI
    module UI
      # Rack endpoint rendering a Swagger UI page. swagger-ui-dist is loaded
      # from the jsDelivr CDN so the gem ships no vendored assets.
      class PageEndpoint
        HTML_HEADERS = {"content-type" => "text/html; charset=utf-8"}.freeze

        def call(_env)
          [200, HTML_HEADERS.dup, [render]]
        end

        private

        def render
          config = Minitest::OpenAPI::UI.configuration
          base = "https://cdn.jsdelivr.net/npm/swagger-ui-dist@#{config.swagger_ui_version}"

          <<~HTML
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>#{ERB::Util.html_escape(config.page_title)}</title>
              <link rel="stylesheet" href="#{base}/swagger-ui.css">
            </head>
            <body>
              <div id="swagger-ui"></div>
              <script src="#{base}/swagger-ui-bundle.js"></script>
              <script>
                window.ui = SwaggerUIBundle({
                  url: #{config.openapi_url.to_json},
                  dom_id: "#swagger-ui",
                  deepLinking: true
                });
              </script>
            </body>
            </html>
          HTML
        end
      end
    end
  end
end
