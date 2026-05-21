# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "rc-minitest-openapi/lib"
  t.libs << "rc-minitest-openapi-api/lib"
  t.libs << "rc-minitest-openapi-ui/lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

task default: :test
