# minitest-openapi

Generate an OpenAPI 3.0 document from your Rails minitest API tests.

Tests declare each operation and its response schema; responses are validated
against that schema as the suite runs; the `openapi:generate` rake task writes
the document. A helper-method DSL and an rswag-style nested block DSL are both
provided.

See the [repository README](https://github.com/RailsComposer/minitest-openapi)
for full documentation.

## License

MIT
