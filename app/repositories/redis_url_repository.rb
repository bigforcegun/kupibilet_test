class RedisUrlRepository < UrlRepository

  attr_reader :connection

  # @param [Hash] config
  # @option config [String] :namespace namespace for redis keys
  # @option config [String] :namespace_separator Redis keys namespace seperator
  # @option config [String] :host redis connection host
  # @option config [String] :password redis connection password
  # @option config [String] :port redis connection post
  # @option config [String] :db redis connection DB
  def initialize(config)
    @namespace           = config['namespace'] || 'url'
    @namespace_separator = config['namespace_separator'] || ':'

    @host     = config['host'] || '127.0.0.1'
    @port     = config['port'] || '6379'
    @password = config['password'] || ''
    @db       = config['db'] || '0'

    super
  end

  def find_or_create_short_url(url)
    #pass
  end

  def load_long_url_by_key(url_key)
    create_connection
    get_long_url(url_key).callback do |long_url|
      yield(long_url) if block_given?
    end
  end


  def create_new_short_url(url)
    create_connection
    inc_primary_id.callback do
      get_primary_id.callback do |primary_id|
        url_key = Base62.encode(primary_id.to_i)
        set_short_url(url_key, url).callback do

          yield(url_key) if block_given?
        end
      end
    end
  end

  # @return [EventMachine::Hiredis::Client]
  def clear_db
    create_connection
    self.connection.flushdb
  end

  # @return [nil]
  def close
    connection.close_connection
    connection.pubsub.close_connection
    return nil
  end

  protected

  # @param [String] url_key
  def get_long_url(url_key)
    self.connection.get(build_url_key(url_key))
  end

  # @param [String] key
  # @param [String] url
  # @return [EventMachine::Hiredis::Client]
  def set_short_url(key, url)
    self.connection.set(build_url_key(key), url)
  end

  # @return [EventMachine::Hiredis::Client]
  def get_primary_id
    self.connection.get(build_primary_key)
  end

  # @return [EventMachine::Hiredis::Client]
  def reset_primary_id
    self.connection.set(build_primary_key, 0)
  end

  # @return [EventMachine::Hiredis::Client]
  def inc_primary_id
    self.connection.incr(build_primary_key)
  end


  # @return [String]
  def build_primary_key
    'next' + @namespace_separator + build_redis_key('id')
  end

  # @param [String] key
  def build_url_key(key)
    build_redis_key(key) + @namespace_separator + 'id'
  end

  # @param [String] key
  def build_redis_key(key)
    @namespace + @namespace_separator + key
  end

  # @return [String]
  def build_connection_string
    "redis://#{@password}@#{@host}:#{@port}/#{@db}"
  end


  # @return [EventMachine::Hiredis::Client]

  def create_connection
    if @connection.nil?
      @connection = EM::Hiredis.connect(build_connection_string)
    end
    unless @connection.connected?
      @connection.reconnect_connection
    end
    @connection
  end


end