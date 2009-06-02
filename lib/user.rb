require 'yaml'
require 'ostruct'

class User < ActiveRecord::Base
  def self.api
    @api ||= Class.new { include Typhoeus }
  end

  def self.get(username)
    find_or_create_by_name(username)
  end
  
  validates_presence_of :name
  
  after_create :enqueue!, :unless => :loaded?

  def perform
    case
    when loaded? then return true
    when exists? then load_data
    else update_attributes!(:body => { 'unknown' => true }.to_yaml)
    end
  end
  
  def fresh?
    expires_in > 0
  end

  def loaded?
    fresh? and yaml.values_at('repositories', 'unknown').any?
  end
  
  def expires_in
    [updated_at.to_i - 1.hour.ago.to_i, 0].max
  end

  def exists?
    @exists ||= begin
      res = User.api.get("http://github.com/#{name}")
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
    Delayed::Job.enqueue(self)
    update_attributes! :body => { :pending => true }.to_yaml
  end

  private

  def yaml
    @yaml ||= body ? YAML.load(body) : {}
  end

  def load_data
    begin
      puts "** Fetching repo data for #{name}"
      data = User.api.get("http://github.com/api/v2/yaml/repos/show/#{name}").body
      update_attributes! :body => data
    rescue => err
      if throttled?(err)
        update_attributes! :body => nil
        raise(ThrottledError.new)
      end
    end
  end

  def throttled?(err)
    err.is_a?(OpenURI::HTTPError) and err.message == '403 Forbidden'
  end
end
