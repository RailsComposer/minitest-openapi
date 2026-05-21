# rc-minitest-openapi-ui

A mountable Rails engine that renders Swagger UI for an OpenAPI document,
pairing with [`rc-minitest-openapi`](https://github.com/RailsComposer/minitest-openapi)
and `rc-minitest-openapi-api`.

```ruby
# config/routes.rb
mount Minitest::OpenAPI::UI::Engine => "/api-docs/ui"

# config/initializers/minitest_openapi.rb
Minitest::OpenAPI::UI.configure { |c| c.openapi_url = "/api-docs" }
```

Swagger UI assets are loaded from the jsDelivr CDN; no assets are vendored.

See the [repository README](https://github.com/RailsComposer/minitest-openapi)
for full documentation.

## License

MIT
