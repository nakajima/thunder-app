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
  
  def name
    @username
  end
  
  def repos(sort='watchers')
    @repos ||= begin
      yaml = YAML.load(open("http://github.com/api/v2/yaml/repos/show/#{@username}").read)['repositories']
      yaml \
        .map     { |repo| OpenStruct.new(repo)  } \
        .reject  { |repo| repo.fork } \
        .sort_by { |repo| repo.send(sort) }.reverse
    end
  end
end