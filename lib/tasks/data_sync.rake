# encoding: utf-8
namespace :db do
  desc "Refreshes your local development environment to the current production database"
  task :pull do
    `cap remote_db_runner`
    `bundle exec rake db:database_load`
  end

  desc "Refreshes your production database to the current local development database"
  task :push do
   `bundle exec rake db:database_dump`
   `cap local_db_upload`
   `cap remote_db_restore`
  end

  desc "Dump the current database to a MySQL file"
  task :database_dump => :environment do
    databases = YAML::load(File.open(Rails.root.join('config', 'database.yml')))

    if (databases[Rails.env]["adapter"] == 'mysql' || databases[Rails.env]["adapter"] == 'mysql2')
#      ActiveRecord::Base.establish_connection(databases[Rails.env])

      commands = []

      mysql_dump_command = []
      mysql_dump_command << "mysqldump"
      mysql_dump_command << "-h #{databases[Rails.env]["host"].blank? ? 'localhost' : databases[Rails.env]["host"]}"
      mysql_dump_command << "-u #{databases[Rails.env]["username"]}"
      if databases[Rails.env]["password"].present?
        mysql_dump_command << "-p#{databases[Rails.env]["password"]}"
      end
      mysql_dump_command << "#{databases[Rails.env]["database"]}"
      mysql_dump_command << " > #{Rails.root.join('db', 'production_data.sql')}"

      commands << mysql_dump_command.join(' ')
      commands << "cd #{Rails.root.join('db')}"
      commands << "tar -cjf #{Rails.root.join('db', 'production_data.tar.bz2')} production_data.sql"
      commands << "rm -fr #{Rails.root.join('db', 'production_data.sql')}"

      `#{commands.join(' && ')}`
    elsif databases[Rails.env]["adapter"] == 'mongodb'
      port = databases[Rails.env]['port']
      port ||= 27017 # default mongodb port

      commands = []
      commands << "rm -fr #{Rails.root.join('db', 'dump')}"
      commands << "mongodump --host #{databases[Rails.env]['host']} --port #{port} --db #{databases[Rails.env]['database']} --out #{Rails.root.join('db', 'dump')}"
      commands << "cd #{Rails.root.join('db')}"
      commands << "tar -cjf #{Rails.root.join('db', 'production_data.tar.bz2')} dump/#{databases[Rails.env]['database']}"
      commands << "rm -fr #{Rails.root.join('db', 'dump')}"

      `#{commands.join(' && ')}`
    else
      raise "Task doesn't work with '#{databases[Rails.env]['adapter']}'"
    end
  end

  desc "Loads the production data downloaded into db/production_data into your local development database"
  task :database_load => :environment do
    databases = YAML::load(File.open(Rails.root.join('config', 'database.yml')))

    database_folder = Rails.env == 'production' ? databases['development']['database'] : databases['production']['database']

    unless File.exists? Rails.root.join('db', 'production_data.tar.bz2')
      raise 'Unable to find database dump in db/production_data.tar.bz2'
    end

    if databases[Rails.env]["adapter"] == 'mysql' || databases[Rails.env]["adapter"] == 'mysql2'
#     ActiveRecord::Base.establish_connection(databases[Rails.env])
      commands = []
      commands << "cd #{Rails.root.join('db')}"
      commands << "tar -xjf #{Rails.root.join('db', 'production_data.tar.bz2')}"

      mysql_dump_command = []
      mysql_dump_command << "mysql"
      if databases[Rails.env]["host"].present?
        mysql_dump_command << "-h #{databases[Rails.env]["host"]}"
      end
      mysql_dump_command << "-u #{databases[Rails.env]["username"]}"
      if databases[Rails.env]["password"].present?
        mysql_dump_command << "-p#{databases[Rails.env]["password"]}"
      end
      mysql_dump_command << "#{databases[Rails.env]["database"]}"
      mysql_dump_command << " < production_data.sql"
      commands << mysql_dump_command.join(' ')

      commands << "rm -fr #{Rails.root.join('db', 'production_data.tar.bz2')} #{Rails.root.join('db', 'production_data.sql')}"

      `#{commands.join(' && ')}`
    elsif databases[Rails.env]["adapter"] == 'mongodb'
      commands = []
      commands << "cd #{Rails.root.join('db')}"
      commands << "tar -xjvf #{Rails.root.join('db', 'production_data.tar.bz2')}"
      commands << "mongorestore --drop --db #{databases[Rails.env]['database']} #{Rails.root.join('db', 'dump', database_folder)}"
      commands << "rm -fr #{Rails.root.join('db', 'dump')} #{Rails.root.join('db', 'production_data.tar.bz2')}"

      `#{commands.join(' && ')}`
    else
      raise "Task not supported by '#{databases[Rails.env]['adapter']}'"
    end
  end
end

