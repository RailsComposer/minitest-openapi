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

- `operation_id:` — both DSLs accept it; it is recorded as the operation's
  `operationId`, which client codegen uses to name generated methods.

### Changed
- The document is written via an `after_run` hook registered when
  `minitest/openapi` is required (gated on `MINITEST_OPENAPI`), replacing the
  minitest plugin file. Plugin auto-discovery did not fire reliably under
  Rails' test runner or with git-sourced gems.

### Fixed
- Response validation now allows `null` for a `nullable` field that also
  declares an `enum`. Previously `nullable: true` added `"null"` to `type`
  but not to the (exhaustive) `enum`, so a null value was rejected.
