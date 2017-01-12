module Sinatra
  module UrlShortenerApi
    module UrlHelper
      # Собирает урл для редиректа из ключа и того, что мы написали в config.yml
      # @param [String] url_key
      def build_redirect_url(url_key)
        "http://#{settings.host}:#{settings.port}/#{url_key}"
      end

    end
  end
end