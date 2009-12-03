namespace :engine do

  desc 'Make this engine ready to run as an app'
  task :appify => [:links, :files]

  desc 'Do all the linking necessary to get this engine into a Rails app structure'
  task :links do
    `ln -nfs #{rails_root}/plugins #{rails_root}/vendor/plugins`
    `mkdir -p #{rails_root}/public/plugin_assets/`
    `ln -nfs #{rails_root}/public #{rails_root}/public/plugin_assets/community_engine`
  end

  desc 'Setup any missing files from an engine'
  task :files do
#    `echo 'module ApplicationHelper; end' > #{rails_root}/app/helpers/application_helper.rb`
  end
end

# Can't use rails_root since can't have dependency on :environment, have to deduce for ourselves
def rails_root
  @rails_root ||= "#{File.dirname(__FILE__)}/../.."
end
