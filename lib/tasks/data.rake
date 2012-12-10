namespace :data do
  desc "Refreshes your local development database and files to the production environment"
  task(:pull => :environment) do
    `bundle exec rake db:pull`
    `cap download_files`
  end
end
