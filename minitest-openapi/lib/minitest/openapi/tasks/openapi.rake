# frozen_string_literal: true

namespace :openapi do
  desc "Run the API tests and write the OpenAPI document"
  task :generate do
    require "minitest/openapi"

    paths = Array(Minitest::OpenAPI.configuration.test_paths)
    command = ["bin/rails", "test", *paths]
    puts "openapi: #{command.join(" ")}"

    # MINITEST_OPENAPI tells the plugin to write the document after the run.
    # PARALLEL_WORKERS=1 keeps every operation in one process / one document.
    env = {"MINITEST_OPENAPI" => "1", "PARALLEL_WORKERS" => "1"}
    abort "openapi: test run failed; document not written" unless system(env, *command)
  end
end
