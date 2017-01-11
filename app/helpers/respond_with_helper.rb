module Sinatra
  module UrlShortenerApi
    module RespondWithHelper
      # Создает заголовки для редиректа и пустое body, что бы это все уехало браузер
      # @param [String] url
      def arespond_with_redirect(url)
        headers 'Location' => url
        status 301
        body
      end

      # respond для работы с async_sinatra
      # просто отдает в body строку
      # @param [string] error
      def arespond_with_error(error)
        body error
      end

      # Пишет в body ошибку и закрывает стрим
      # @param [String] error
      # @param [Sinatra::Stream] out
      def respond_with_error(error)
        body error
      end

      # Пишет в body json и закрывает стрим
      # @param [Object] obj
      # @param [Sinatra::Stream] out
      def respond_with_json(obj)
        body JSON.generate(obj)
      end

      # Пишет в body json с ошибкой и закрывает стрим
      # @param [String] error_msg
      # @param [Object] out
      def respond_with_json_error(error_msg)

        response = {
            :error => error_msg
        }
        respond_with_json(response)
      end
    end
  end
end