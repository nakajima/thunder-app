require 'app'
require File.dirname(__FILE__) + "/vendor/delayed_job/tasks/tasks"
 
namespace :db do
  desc "Create db"
  task :migrate do
    ActiveRecord::Migrator.migrate(
      'db/migrate', 
      ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    )
  end
end
 