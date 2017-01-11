class UrlRepository

  def initialize(config)

  end

  # @param [String] url_key
  # @return [String|nil]
  def load_long_url_by_key(url_key)
    raise('Must be implemented on sub-class')
  end


  # @param [String] url
  # @return [String|nil]
  def create_new_short_url(url)
    raise('Must be implemented on sub-class')
  end

  def clear_urls

  end

end