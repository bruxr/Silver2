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
  c.allow_http_connections_when_no_cassette = true
end

# Mock Fog uploads
Fog.mock!
fog_config = YAML.load(ERB.new(File.read(Rails.root.join('config', 'fog.yml'))).result)
fog_config = fog_config['default'].symbolize_keys
connection = Fog::Storage.new(fog_config)
connection.directories.create(key: 'silver.bruxromuar.com')