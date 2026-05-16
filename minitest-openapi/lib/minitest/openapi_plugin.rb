# frozen_string_literal: true

# Minitest plugin, auto-discovered by minitest. It writes the OpenAPI
# document after the suite finishes, but only when MINITEST_OPENAPI is set —
# the openapi:generate rake task sets it. Ordinary test runs are unaffected
# (response validation still happens; the document is just not written).
module Minitest
  def self.plugin_openapi_init(_options)
    return unless ENV["MINITEST_OPENAPI"]

    require "minitest/openapi"

    Minitest.after_run do
      path = Minitest::OpenAPI.generate!
      warn "openapi: wrote #{path}"
    end
  end
end
