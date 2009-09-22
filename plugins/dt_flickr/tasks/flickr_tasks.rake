namespace :flickr do
  desc 'Clear the local flickr cache'
  task :clear_cache => :environment do
    DT::FlickrDownloader.clear_cache!
  end
end
