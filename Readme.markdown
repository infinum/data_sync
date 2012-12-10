Data sync
=======

Rails plugin for syncing database and files between production and local development server.

Requirements
============

 * Rails 3
 * Capistrano

Install
=======

To install this gem, add the gem to your Gemfile

    gem 'data_sync'

And then add this line to your Capfile

    require 'data_sync_recipes'

Usage
=====

For pulling the database of the remote server

    rake db:pull

For pushing the local database to the remote server

    rake db:push

For pulling the database and the files of the remote server

    rake data:pull

MongoDB
====

If you're planning to use this with MongoDB your config/database.yml should use mongodb as adapter value.

* development:
*   adapter: mongodb
*   database: surveys-development
*   host: localhost
* ...

And initalizer for MongoDB in config/initializers/mongo.rb
    default_mongodb_port = 27107

    database_configurations = YAML::load(File.read(Rails.root.join('config', 'database.yml')))

    if database_configurations[Rails.env] && database_configurations[Rails.env]['adapter'] == 'mongodb'
        database = database_configurations[Rails.env]
        database['port'] ||= default_mongodb_port

        MongoMapper.connection = Mongo::Connection.new(database['hostname'], database['port'])
        MongoMapper.database = database['database']

        if defined?(PhusionPassenger)
            PhusionPassenger.on_event(:starting_worker_process) do |forked|
                MongoMapper.connection.connect_to_master if forked
            end
        end
    end

TODO
====
* Prompt ("All files will be overwritten..")
* database and files push
* change usage to "push:files", "push:db", "push:data", "pull:files", "pull:db", "pull:files"
* refactor rake task, duplicate code

