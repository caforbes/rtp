# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  enable_coverage :branch
end
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::Console]
)
SimpleCov::Formatter::Console.missing_len = 20

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
