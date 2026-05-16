# frozen_string_literal: true

Minitest::OpenAPI::Api::Engine.routes.draw do
  get "/" => Minitest::OpenAPI::Api::DocumentEndpoint.new, :as => :document
end
