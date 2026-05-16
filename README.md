# minitest-openapi

Generate an [OpenAPI](https://www.openapis.org/) 3.0 document from your Rails
**minitest** API tests — an rswag-style workflow for teams that use minitest
instead of RSpec.

Your integration tests declare each operation and the schema of its response.
As the suite runs, every response body is validated against the schema it
claims to return, and the `openapi:generate` rake task writes the assembled
document. The tests are the single source of truth: if a response stops
matching the contract, the suite goes red.

This repository contains three gems, mirroring rswag's split:

| Gem | Purpose |
| --- | --- |
| [`minitest-openapi`](minitest-openapi) | The test DSLs, response validation, and the `openapi:generate` rake task. |
| [`minitest-openapi-api`](minitest-openapi-api) | A mountable engine that serves the generated document. |
| [`minitest-openapi-ui`](minitest-openapi-ui) | A mountable engine that renders Swagger UI. |

## Installation

```ruby
# Gemfile
group :test do
  gem "minitest-openapi"
end

# These two are only needed if you want to serve the doc / UI from the app:
gem "minitest-openapi-api"
gem "minitest-openapi-ui"
```

## Configure

In `test/test_helper.rb`:

```ruby
require "minitest/openapi"

Minitest::OpenAPI.configure do |config|
  config.output_path = "openapi/v1/openapi.json"   # where openapi:generate writes
  config.test_paths  = ["test/integration/api"]    # what openapi:generate runs
  config.validate_responses = true                 # validate as the suite runs

  # The base document — everything not derived from tests. A Hash, or a path
  # to a JSON/YAML file. Test-recorded operations are merged into `paths`.
  config.base = "openapi/base.json"
end
```

The base document supplies `info`, `servers`, security schemes, and reusable
`components/schemas`. Operations recorded by tests are merged into `paths`.

## Writing tests

Two interchangeable DSLs sit on the same engine — use either, or both in the
same suite. Both validate the live response against the declared schema and
record the operation into the document.

### Helper methods (classic minitest)

```ruby
require "test_helper"

class MediaEntriesApiTest < ActionDispatch::IntegrationTest
  include Minitest::OpenAPI::DSL

  test "lists media entries" do
    openapi_get "/api/v1/media_entries",
      summary: "List media entries",
      tags: ["Media entries"],
      response: {
        status: 200,
        schema: {"$ref" => "#/components/schemas/MediaEntriesPage"}
      }
    assert_response :success
  end

  test "shows a media entry" do
    entry = media_entries(:published)
    openapi_get "/api/v1/media_entries/#{entry.id}",
      doc_path: "/api/v1/media_entries/{id}",
      summary: "Get a media entry",
      response: {status: 200, schema: {"$ref" => "#/components/schemas/MediaEntry"}}
    assert_response :success
  end
end
```

`openapi_get` / `openapi_post` / `openapi_patch` / `openapi_put` /
`openapi_delete` perform the request, validate, record, and return the
response so you can keep asserting. Pass `doc_path:` when the request URL is
concrete but the documented path is templated.

### Block DSL (minitest/spec)

```ruby
require "test_helper"

class MediaEntriesApiTest < ActionDispatch::IntegrationTest
  extend Minitest::OpenAPI::Spec

  api_path "/api/v1/media_entries" do
    api_operation :get, summary: "List media entries" do
      api_response 200, schema: {"$ref" => "#/components/schemas/MediaEntriesPage"} do
        run_api_test!
      end
    end
  end

  api_path "/api/v1/media_entries/{id}" do
    api_operation :get, summary: "Get a media entry" do
      api_response 200, schema: {"$ref" => "#/components/schemas/MediaEntry"} do
        run_api_test! { {path: "/api/v1/media_entries/#{media_entries(:published).id}"} }
      end
    end
  end
end
```

`run_api_test!` defines the test. Its optional block runs in the test instance
and returns request overrides — `{path:, params:, headers:, body:}` — so a
templated path can be turned into a concrete URL from records the test sets up.

## Generating the document

```bash
bin/rails openapi:generate
```

This runs your API tests with the document writer enabled and writes
`config.output_path`. Run it in CI and diff the result to catch a contract
that changed without the spec being regenerated. Ordinary `bin/rails test`
runs are unaffected — they still validate responses, they just don't write the
file.

## Serving the document and UI

```ruby
# config/routes.rb
mount Minitest::OpenAPI::Api::Engine => "/api-docs"
mount Minitest::OpenAPI::UI::Engine  => "/api-docs/ui"
```

```ruby
# config/initializers/minitest_openapi.rb
Minitest::OpenAPI::Api.configure { |c| c.document_path = "openapi/v1/openapi.json" }
Minitest::OpenAPI::UI.configure  { |c| c.openapi_url = "/api-docs" }
```

`/api-docs` serves the JSON; `/api-docs/ui` renders Swagger UI against it.

## License

MIT — see [LICENSE.txt](LICENSE.txt).
