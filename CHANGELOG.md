# Changelog

## [Unreleased]

### Added
- `minitest-openapi` — generate an OpenAPI 3.0 document from minitest
  integration tests. Two interchangeable DSLs over a shared recorder:
  helper methods (`openapi_get` and friends) for classic class-based tests,
  and a nested block DSL (`api_path` / `api_operation` / `api_response` /
  `run_api_test!`) for minitest/spec. Responses are validated against the
  declared schema as the suite runs; the `openapi:generate` rake task writes
  the document.
- `minitest-openapi-api` — mountable Rails engine serving the generated
  document.
- `minitest-openapi-ui` — mountable Rails engine rendering Swagger UI.
