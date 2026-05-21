# frozen_string_literal: true

Minitest::OpenAPI::UI::Engine.routes.draw do
  get "/" => Minitest::OpenAPI::UI::PageEndpoint.new, :as => :ui
end
