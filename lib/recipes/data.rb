namespace :data do

  # TODO: Add prevent production switch
  desc 'Setup companies and me demo data THIS IS DESTRUCTIVE'
  task :demo, :roles => :app, :only => { :primary => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake data:demo"
  end

  desc 'Reset dbs THIS IS DESTRUCTIVE'
  task :reset, :roles => :app, :only => { :primary => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake db:revert"
  end

  desc 'Run the default data population task'
  task :default, :roles => :app, :only => { :primary => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake data:default"
  end
end
