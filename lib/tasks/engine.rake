namespace :engine do

  desc 'Make this engine ready to run as an app, including any gem dependencies'
  task :appify => [:links, 'gems:install']

  desc 'Do all the linking necessary to get this engine into a Rails app structure'
  task :links do

    # Can't use rails_root since can't have dependency on :environment, have to deduce for ourselves
    rails_root = "#{File.dirname(__FILE__)}/../.."
    `ln -nfs #{rails_root}/plugins #{rails_root}/vendor/plugins`
    `mkdir -p #{rails_root}/public/plugin_assets/`
    `ln -nfs #{rails_root}/public #{rails_root}/public/plugin_assets/community_engine`
#    `rsync -rqc #{rails_root}/public/plugin_assets/community_engine/* #{rails_root}/public/`
  end
end
