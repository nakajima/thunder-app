require 'yaml'
require 'ostruct'

class User
  def self.cache
    @cache ||= {}
  end

  def self.get(username)
    cache[username] ||= new(username)
  end

  def initialize(username)
    @username = username
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
      YAML.load(load_data).fetch('repositories') \
        .map     { |repo| OpenStruct.new(repo)  } \
        .reject  { |repo| repo.fork } \
        .sort_by { |repo| repo.send(sort) }.reverse
    end
  end

  private

  def load_data
    begin
      open("http://github.com/api/v2/yaml/repos/show/#{@username}").read
    rescue => err
      if throttled?(err)
        User.cache.delete(@username)
        raise(ThrottledError.new)
      else
        [].to_yaml
      end
    end
  end

  def throttled?(err)
    err.is_a?(OpenURI::HTTPError) and err.message == '403 Forbidden'
  end
end
