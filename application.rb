require File.expand_path '../config/environment', __FILE__
#require 'thin'
#require 'eventmachine'


=begin

Итак
ЕВ-Редис может быть законнекчен только в контексте и после запуска евент машины.

Флоу у нас пока такой
Создаем приложение
Пихаем в ивент машину
Обрабатываем
Пихаем в рак внури ивент машины

Вся инициализация настройка и прочая приложения синатры происходит в конструкторе (условно), то есть ДО ЗАПУСКА ивент машины
Значит - мы не можем проинициализировать репозиторий механизмами синатры, если только не перенесем инит приложения внутрь ивент машины

Инстанс приложения синатры инкапсулирован, так что мы не можем дернуть по ходу флоу метод, который бы завел ЕВредис

Решения
- перенос
- Глобальный обьект Евредиса, что не есть хорошо , нафига тогда ебелька с репозиторием?


=end

def run(opts)
  #EM.run do
    web_app = UrlShortenerApi.new
    # define some defaults for our app
    web_app = opts[:app]
    server  = opts[:server] || 'thin'
    host    = opts[:host] || web_app.settings.host
    port    = opts[:port] || web_app.settings.port

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    # default construction
    unless %w(thin hatetepe goliath).include? server
      raise "Need an EM webserver, but #{server} isn't"
    end

    # Start the web server. Note that you are free to run other tasks
    # within your EM instance.
    Rack::Server.start(
        app:     dispatch,
        server:  server,
        Host:    host,
        Port:    port,
        signals: false,
    )
  #end
end

run app: UrlShortenerApi.new