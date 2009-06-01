require 'yaml'
require 'ostruct'

class User
  EXPIRY = 3600
  
  def self.api
    @api ||= Class.new { def self.get(uri); open(uri).read end }
  end
  
  def self.cache
    @cache ||= MemCache.respond_to?(:cache) ? MemCache.cache : MemCache.new("127.0.0.1:11211")
  end
  
  def self.get(username)
    new(username)
  end

  def initialize(username)
    @username = username
    Delayed::Job.enqueue self unless loaded?
  end
  
  def perform
    load_data unless loaded?
  end

  def loaded?
    if result = User.cache.get(@username)
      puts "[cache.hit] - #{@username}" ; result
    end
  end

  def exists?
    uri = URI.parse("http://github.com/#{@username}")
    req = Net::HTTP::Head.new(uri.path)
    res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
    ! res['status'].include? "404"
  end

  def name
    @username
  end

  def repos(sort='watchers')
    @repos ||= begin
       yaml \
        .map     { |repo| OpenStruct.new(repo)  } \
        .reject  { |repo| repo.fork } \
        .sort_by { |repo| repo.send(sort) }.reverse
    end
  end

  private

  def yaml
    YAML.load(User.cache.get(@username))['repositories']
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
      else
        raise
      end
    end
  end

  def throttled?(err)
    err.is_a?(OpenURI::HTTPError) and err.message == '403 Forbidden'
  end
end
