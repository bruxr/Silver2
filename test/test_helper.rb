ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Configure VCR for testing web services
VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('test', 'vcr')
  c.hook_into :webmock
end