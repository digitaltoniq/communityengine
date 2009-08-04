namespace :data do
  
  desc 'Setup companies and me demo data THIS IS DESTRUCTIVE'
  task :demo, :roles => :app, :only => { :primary => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake data:demo"
  end
end