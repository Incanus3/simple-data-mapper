require 'rspec/collection_matchers'
require 'simplecov'

SimpleCov.start

# require_relative '../app'

ENV['APP_ENV'] = 'test'

# rubocop:disable Style/MethodCallWithArgsParentheses
RSpec.configure do |config|
  config.disable_monkey_patching!

  config.fail_fast = true
  config.run_all_when_everything_filtered = true

  config.filter_run_including :focus
  config.filter_run_excluding :disabled
  config.filter_run_excluding :slow

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?
end
# rubocop:enable Style/MethodCallWithArgsParentheses
