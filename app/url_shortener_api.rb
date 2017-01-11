require_relative '../app/helpers/respond_with_helper'

class UrlShortenerApi < Sinatra::Base

  register Sinatra::ConfigFile
  register Sinatra::Async
  helpers Sinatra::UrlShortenerApi::RespondWithHelper

  config_file '../config/config.yml'

  configure do
    # threaded - False: Will take requests on the reactor thread
    set :threaded, false
    # sinatra way?
    #set :environment, :test

    set :url_repository, RedisUrlRepository.new(settings.repository)
  end

  helpers do
    # Хэлпер доступа, что бы не ходить в репозиторий через миллион обьектов
    # @return [UrlRepository]
    def url_repository
      settings.url_repository
    end

    # Собирает урл для редиректа из ключа и того, что мы написали в config.yml
    # @param [String] url_key
    def build_redirect_url(url_key)
      "http://#{settings.host}:#{settings.port}/#{url_key}"
    end

    # Достает longUrl и проверяет все ли хорошо на пришло
    # @param [Stream] out
    def get_long_url
      request.body.rewind
      request_body = JSON.parse(request.body.read) rescue nil
      if request_body.nil? || !request_body.include?('longUrl')
        respond_with_error('Incorrect input json' )
      end
      long_url = request_body['longUrl']
      if long_url.nil? || long_url.scan(URI.regexp).size == 0
        respond_with_error("Incorrect longUrl parameter '#{long_url}'")
      end
      long_url
    end

  end

  register do
    # pass
  end


  # Использовано через async_sinatra
  # Стрим из коробочной sinatra сначала отдает заголовки , потом начинает асинхронно посылать тело
  # Нам же надо асинхронно сходить в редис, получить данные, и уже потом понимать, отдаем мы заголовки, или же тело с ошибкой
  # А это умеет async_sinatra - не посылать ничего, пока мы не попросим
  # TODO Можно наверное было написать что то свое, что бы не тянуть гем или через милварю?
  aget '/:url_key' do
    begin
      url_key = aparams[:url_key]
      if url_key.nil?
        arespond_with_error("Can't found url or provided key '#{url_key}'")
      end
      self.url_repository.load_long_url_by_key(url_key) do |long_url|
        if long_url.nil?
          arespond_with_error("Can't found url or provided key '#{url_key}'")
        else
          p long_url
          arespond_with_redirect(long_url)
        end
      end
    rescue => e
      arespond_with_error("Error while process request with message  #{e.message}")
    end
  end

  apost '/' do
    content_type 'application/json'
    api_response = {}

    #begin
      long_url = get_long_url

      self.url_repository.create_new_short_url(long_url) do |url_key|
        api_response[:url] = build_redirect_url(url_key)
        respond_with_json(api_response)
      end
    #rescue => e
      #respond_with_json_error("Error while process request with message - #{e.message}")
    #end

  end


  # асинхронность через [Sinatra::Stream]
  # Нам не надо посылать заголовки, так что просто лениво получаем/даем все из редиса
=begin
  post '/' do
    content_type 'application/json'
    api_response = {}
    stream :keep_open do |out|
      begin
        long_url = get_long_url(out)
        self.url_repository.create_new_short_url(long_url) do |url_key|
          api_response[:url] = build_redirect_url(url_key)
          respond_with_json(api_response, out)
        end
      rescue => e
        respond_with_json_error("Error while process request with message - #{e.message}", out)
      end
    end
  end
=end


end
