require 'action_controller/test_process.rb'

module DT

  # Utility for downloading (and caching) flickr photos, mostly for
  # use within demo data provisioning
  #
  #  # First register the downloader options
  #  DT::FlickrDownloader.register(:tags => 'headshot,portrait', :count => 25, :size => :medium)
  #
  #  # Then retrieve the instance and get local photo path or remote URL
  #  DT::FlickrDownloader.for('headshot,portrait').photo_path #=> "/Users/ryan/dev/app/..."
  #  DT::FlickrDownloader.for('headshot,portrait').photo_url #=> "http://static.flickr.com/adas/..."
  #
  # For getting a photo as though it were part of an http request upload (useful for attachmentf_fu
  # mimicking:
  #
  #  Factory.define :attachment_fu_photo, :class => Photo do |p|
  #    p.uploaded_data do
  #      DT::FlickrDownloader.for('sexy,bitches').photo_upload
  #    end
  #  end
  class FlickrDownloader

    class << self

      # Get the downloader instance for the given options - prefetched and ready
      # for use
      def register(opts)
        key = instance_key(opts[:tags])
        instance = instance_cache[key]
        unless instance
          instance_cache[key] = instance = new(opts)
          instance.prefetch
        end
        !instance.nil?
      end

      # Get the downloader instance for the given tags
      # NOTE: Must first register the tags with:
      #   DT::FlickrDownloader.register(:tags => 'tag1,tag2', :count => 20)
      def for(tags)
        instance_cache[instance_key(tags)]
      end

      def reset!
        instance_cache.clear
        `rm -rf #{base_cache_dir}`
      end

      private

      def instance_cache
        @instance_cache ||= {}
      end

      def instance_key(tags); tags; end

      def base_cache_dir
        "#{Rails.root}/public/system/flickr_cache"
      end

      def flickr_fu_instance
        @flickr_fu_instance ||= Flickr.new("#{Rails.root}/config/flickr.yml")
      end

      def flickr_fu_options; { :safe_search => 1, :media => 'photo', :page => 1 }; end

    end

    #--- Instance methods --#
    
    attr_accessor :tags, :count, :size

    def initialize(opts = {})
      self.tags = opts[:tags] || 'photo'
      self.count = opts[:count] || 10
      self.size = opts[:size] || :small
    end

    # Prefetch all photos.  Must be run before attempting to use.
    def prefetch

      # What's already cached?
      cached_count = unused_photos.size
      fetch_count = count - cached_count

      if fetch_count > 0

        f_opts = flickr_fu_options.merge(:tags => tags, :per_page => fetch_count)

        # Search
        flickr_fu_instance.photos.search(f_opts).photos.each do |photo|

          begin

            # Download to local cache
            cache_file = photo.save_as("#{cache_dir}/#{ActiveSupport::SecureRandom.hex(10)}", size)
            puts "#{photo.url(size)} => #{cache_file}"
            cache_photo(photo, cache_file)
          rescue Exception => e
            puts e.message
            # Swallow timeouts etc...
          end
        end
      end
    end

    # Get a local photo path for the next unused photo.
    #  downloader.photo_path #=> /Users/ryan/dev/project/public/system...
    def photo_path
      next_photo[:file]
    end

    # Get only the URL for the next unused photo
    def photo_url
      next_photo[:url]
    end
    
    def photo_upload
      file = photo_path
      mimetype = `file -b --mime #{file}`.gsub(/\n/,"")
      ActionController::TestUploadedFile.new(file, mimetype)
    end

    def reset!
      photo_index.each { |props| props[:used] = false }
    end

    def clear_cache!
      `rm -rf #{cache_dir}`
    end

    private

    # Get the next unused photo attributes
    def next_photo
      photo = photo_index.detect { |props| props[:used] = true if !props[:used] }
      photo ? photo :
              raise("Could not find any unused photos for #{tags}.  Increase :count argument to prime_cache or call reset! to reset photo usage tracking.")
    end

    def unused_photos
      photo_index.select { |props| !props[:used] }
    end

    def used_photos
      photo_index.select { |props| props[:used] }
    end

    # Set this photo data in the index
    def cache_photo(photo, cached_file)
      photo_index << { :url => photo.url(size), :file => cached_file, :used => false }
      flush_photo_index
    end

    def photo_index
      @photo_index ||= YAML.load_file(photo_index_file)
      @photo_index = [] unless @photo_index
      @photo_index
    end

    def flush_photo_index
      File.open(photo_index_file, 'w') do |out|
        YAML.dump(photo_index, out)
      end
    end

    def photo_index_file
      file_name = "#{cache_dir}/index.yml"
      FileUtils.touch(file_name)
      file_name
    end

    # The dir to place photos for this instance
    def cache_dir
      tag_dir = tags.gsub(',', '').gsub(' ', '')
      dir = "#{base_cache_dir}/#{tag_dir}"
      `mkdir -p #{dir}`
      dir
    end

    # Convenience accessors to corresponding class-level methods
    # TODO: better way?
    [:base_cache_dir, :flickr_fu_instance, :flickr_fu_options].each do |meth|
      class_eval <<-EOV
        def #{meth}; self.class.send(:#{meth}); end
      EOV
    end
  end
end
