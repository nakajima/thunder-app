require 'yaml'
require 'ostruct'

class User
  EXPIRY = 3600

  attr_reader :username
  alias_method :name, :username

  def self.api
    @api ||= Class.new { def self.get(uri); open(uri).read end }
  end

  def self.cache
    @cache ||= ENV['RACK_ENV'] == 'production' ?
      MemCache.cache :
      MemCache.new("127.0.0.1:11211")
  end

  def self.get(username)
    new(username)
  end

  def initialize(username)
    @username = username
    enqueue! unless loaded? or pending?
  end

  def perform
    load_data unless loaded?
  end

  def pending?
    not loaded? and cached
  end

  def loaded?
    if cached
      yaml.has_key?('repositories') or yaml.has_key?('unknown')
    end
  end

  def cached
    User.cache.get(@username)
  end

  def exists?
    @exists ||= begin
      uri = URI.parse("http://github.com/#{@username}")
      req = Net::HTTP::Head.new(uri.path)
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
      res.code.to_i != 404
    end
  end

  def repos
    @repos ||= begin
       yaml['repositories'] \
        .map     { |repo| OpenStruct.new(repo)  } \
        .reject  { |repo| repo.fork }
    end
  end

  def enqueue!
    if exists?
      Delayed::Job.enqueue(self)
      User.cache.set(@username, { :pending => true }.to_yaml, 60)
    else
      User.cache.set(@username, { 'unknown' => true }.to_yaml, EXPIRY)
    end
  end

  private

  def yaml
    @yaml ||= cached ? YAML.load(cached) : {}
  end

  def load_data
    begin
      puts "** Fetching repo data for #{@username}"
      data = User.api.get("http://github.com/api/v2/yaml/repos/show/#{@username}")
      puts "** Setting repo cache data for #{@username}:"
      User.cache.set(@username, data, EXPIRY)
    rescue => err
      if throttled?(err)
        User.cache.delete(@username)
        raise(ThrottledError.new)
      end
    end
  end

  def throttled?(err)
    err.is_a?(OpenURI::HTTPError) and err.message == '403 Forbidden'
  end
end
