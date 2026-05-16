# frozen_string_literal: true

require "test_helper"

class UiPageEndpointTest < Minitest::Test
  def test_renders_a_swagger_ui_page
    Minitest::OpenAPI::UI.configure do |c|
      c.openapi_url = "/api-docs"
      c.swagger_ui_version = "5.17.14"
      c.page_title = "Widgets API"
    end

    status, headers, body = Minitest::OpenAPI::UI::PageEndpoint.new.call({})
    html = body.join

    assert_equal 200, status
    assert_match %r{text/html}, headers["content-type"]
    assert_match "Widgets API", html
    assert_match "swagger-ui-dist@5.17.14", html
    assert_match(/url: "\/api-docs"/, html)
  end

  def test_escapes_the_page_title
    Minitest::OpenAPI::UI.configure { |c| c.page_title = "A & B <evil>" }

    html = Minitest::OpenAPI::UI::PageEndpoint.new.call({}).last.join

    assert_match("<title>A &amp; B &lt;evil&gt;</title>", html)
    refute_match("<evil>", html)
  end
end
