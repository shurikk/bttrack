
require 'test/environment'
require 'rack/test'
require 'bttrack'

ENV['RACK_ENV'] = 'test'

class AnnounceTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_truth

  end

end
