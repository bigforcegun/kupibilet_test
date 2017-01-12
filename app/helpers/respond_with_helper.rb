module Sinatra
  module UrlShortenerApi
    module RespondWithHelper
      # Создает заголовки для редиректа и пустое body, что бы это все уехало браузер
      # @param [String] url
      def respond_with_redirect(url)
        headers 'Location' => url
        status 301
        body
      end

      # Пишет в body ошибку и закрывает стрим
      # @param [String] error
      def respond_with_error(error)
        status 400
        body error
      end

      # Пишет в body json и закрывает стрим
      # @param [Object] obj
      def respond_with_json(obj)
        body JSON.generate(obj)
      end

      # Пишет в body json с ошибкой и закрывает стрим
      # @param [String] error_msg
      def respond_with_json_error(error_msg)
        response = {
            :error => error_msg
        }
        respond_with_json(response)
      end
    end
  end
end