namespace :ce do

  desc 'Make this engine ready to run as an app, including any gem dependencies'
  task :appify => [:links, 'gems:install']

  desc 'Do all the linking necessary to get this engine into a Rails app structure'
  task :links => :environment
end
