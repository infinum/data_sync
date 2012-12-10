Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).each {|recipe| load recipe}
