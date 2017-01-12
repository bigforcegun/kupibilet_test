ENV['RACK_ENV'] = 'test'

require 'faker'
require 'rack/test'
require 'rspec'
require 'sinatra/async/test'
require 'test/unit'

require './config/environment'


require File.expand_path '../../app/url_shortener_api', __FILE__

module RSpecMixin
  #include Rack::Test::Methods
  include Sinatra::Async::Test::Methods
  include Test::Unit::Assertions
  #include EventMachine::SpecHelper

  Test::Unit::AutoRunner.need_auto_run = false if defined?(Test::Unit::AutoRunner)

  def app
    UrlShortenerApi.new
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  #config.include EventMachine::SpecHelper
end
