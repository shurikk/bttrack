ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'fileutils'
require './bttrack'

CONF[:db_dir] = 'tmp/test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

# For RSpec 2.x
RSpec.configure do |c|
  c.include RSpecMixin

  c.before(:each) { FileStore.purge! }
  c.after(:suite) { FileStore.purge! }
end
