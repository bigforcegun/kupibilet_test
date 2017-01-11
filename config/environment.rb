require 'rubygems'
require 'bundler'

Bundler.require(:default) # load all the default gems
Bundler.require(Sinatra::Base.environment) # load all the environment specific gems


require 'sinatra/config_file'
require 'json'
require './lib/base62'
require './app/repositories/url_repository'
require './app/repositories/redis_url_repository'
require './app/url_shortener_api'
