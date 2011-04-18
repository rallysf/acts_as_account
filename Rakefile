require 'rubygems'
require 'bundler'
require 'rake'
require 'cucumber'
require 'cucumber/rake/task'

Bundler.require(:default, :development) if defined?(Bundler)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "acts_as_account"
    gem.summary = %Q{acts_as_account implements double entry accounting for Rails models}
    gem.description = %Q{acts_as_account implements double entry accounting for Rails models. Your models get accounts and you can do consistent transactions between them. Since the documentation is sparse, see the transfer.feature for usage examples.}
    gem.email = "thieso@gmail.com"
    gem.homepage = "http://github.com/betterplace/acts_as_account"
    gem.authors = ["Thies C. Arntzen, Norman Timmler, Matthias Frick, Phillip Oertel"]
    gem.add_dependency 'active_record'
    gem.add_dependency 'action_pack'
    gem.add_dependency 'database_cleaner'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :features do
  desc "create test database out of db/schema.rb"
  task :create_database do
    require 'active_record'
    access_data = YAML.load_file(File.dirname(__FILE__) + '/db/database.yml')['acts_as_account']
    conn = ActiveRecord::Base.establish_connection(Hash[access_data.select { |k, v| k != 'database'}]).connection
    conn.execute('DROP DATABASE IF EXISTS acts_as_account')
    conn.execute('CREATE DATABASE acts_as_account')
    conn.execute('USE acts_as_account')
    load(File.dirname(__FILE__) + '/db/schema.rb')
  end
  
  Cucumber::Rake::Task.new(:run) do |t|
    t.cucumber_opts = "features --format pretty"
  end
end
