# frozen_string_literal: true

# Stands in for an ActionDispatch::IntegrationTest in unit tests: records the
# requests made and returns canned responses, and supplies the assert_equal
# the recorder uses for assert_status.
class FakeApi
  Response = Struct.new(:status, :body)

  attr_reader :calls, :response

  # responses: { [verb, path] => Response }. Anything unmatched returns 200 {}.
  def initialize(responses = {})
    @responses = responses
    @calls = []
  end

  %i[get post patch put delete].each do |verb|
    define_method(verb) do |path, **options|
      @calls << {verb: verb, path: path, options: options}
      @response = @responses.fetch([verb, path]) { Response.new(200, "{}") }
    end
  end

  def assert_equal(expected, actual, message = nil)
    return if expected == actual

    raise Minitest::Assertion, message || "expected #{expected}, got #{actual}"
  end
end
