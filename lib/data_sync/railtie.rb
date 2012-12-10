require 'data_sync'
require 'rails'

module DataSync
  class Railtie < Rails::Railtie
    railtie_name :data_sync

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each {|task| load task}
    end
  end
end
