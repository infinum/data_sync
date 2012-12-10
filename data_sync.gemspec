Gem::Specification.new do |s|
  s.name        = 'data_sync'
  s.version     = '1.0.0'
  s.date        = '2012-12-10'
  s.summary     = "Data sync rake tasks."
  s.description = "Rake tasks to sync data between development and production environments (servers)."
  s.authors     = ["Tomislav Car", "Nikica Kapraljević", "Josip Bišćan"]
  s.email       = ["tomislav@infinum.hr", "nikola@infinum.hr", "josip@infinum.hr"]
  s.homepage    = 'https://github.com/infinum/data_sync'

  s.add_dependency 'capistrano'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
end
