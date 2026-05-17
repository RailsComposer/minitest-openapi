# frozen_string_literal: true

namespace :openapi do
  desc "Run the API tests and write the OpenAPI document. Pass test paths to " \
       "scope the run, e.g. openapi:generate[test/integration/api]."
  task :generate, [:paths] do |_task, args|
    paths = [args[:paths], *args.extras].compact
    paths = ["test/integration"] if paths.empty?
    command = ["bin/rails", "test", *paths]
    puts "openapi: #{command.join(" ")}"

    # MINITEST_OPENAPI makes minitest-openapi write the document after the run.
    # PARALLEL_WORKERS=1 keeps every operation in one process / one document.
    env = {"MINITEST_OPENAPI" => "1", "PARALLEL_WORKERS" => "1"}
    abort "openapi: test run failed; document not written" unless system(env, *command)
  end
end
