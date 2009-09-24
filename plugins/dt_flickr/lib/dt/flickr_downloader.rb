require 'action_controller/test_process.rb'

# TODO: This is not particularly well-structured.  More of a holding tank for
# our current Flickr needs in a somewhat reusable format (plugin)
#
# TODO: Be more structured with args instead of just passing around opts hash
# like a 14 year phillipino whore
#
# TODO: Don't make all methods class methods - create an instance which stores
# the opts hash and call instance methods.
module DT

  # Utility for downloading (and caching) flickr photos, mostly for
  # use within demo data provisioning
  #
  #  path = DT::FlickrDownloader.photo_path(:tags => 'deer,mounted', :sequence => n, :size => :medium)
  #
  # For getting a photo as though it were part of an http request upload
  #
  #  Factory.define :attachment_fu_photo, :class => Photo do |p|
  #    p.sequence(:uploaded_data) do |n|
  #      DT::FlickrDownloader.photo_upload(:tags => 'sexy,bitches', :sequence => n, :size => :small)
  #    end
  #  end
  class FlickrDownloader

    class << self

      # NEW

      # prime_cache(:count => 20, :tags => 'naked,chicks', :size => :medium)
      def prime_cache(opts)

        # Setup opts
        count = opts[:count] || 10

        # What's already cached?
        cached_count = index(opts).select { |props| !props[:used] }.size
        count = count - cached_count

        if count > 0

          f_opts = flickr_fu_options.merge(:tags => opts[:tags], :per_page => count)

          # Search
          instance.photos.search(f_opts).photos.each do |photo|

            # Download to local cache
            url = photo.url(opts[:size] || :small)
            url_ext = url.from(url.rindex('.') + 1)
            cache_file = File.new("#{cache_dir(opts)}/#{ActiveSupport::SecureRandom.hex(10)}.#{url_ext}", "w")
            `wget #{url} -O #{cache_file.path}`

            # Store URL in index file
            cache_photo(opts, url, cache_file.path)
          end
        end
      end

      # Get a local photo path for the given opts.  Use :sequence
      # if getting photo as part of larger sequential grab
      #  (1..20).to_a.collect { |i| photo_path(:tags => 'test') }
      def photo_path(opts)
        next_cached_photo(opts)[:file]
      end

      # Get only the URL for the requested photo sequence
      def photo_url(opts)
        next_cached_photo(opts)[:url]
      end

      # Get a photo for the given options as though it were
      # uploaded as part of a post request
      #
      # Factory.define :photo do |p|
      #   p.sequence(:uploaded_data) do |n|
      #     DT::FlickrDownloader.photo_upload(:tags => 'p0orn', :index => n, :size => :small)
      #   end
      # end
      def photo_upload(opts)
        file = photo_path(opts)
        mimetype = `file -b --mime #{file}`.gsub(/\n/,"")
        ActionController::TestUploadedFile.new(file, mimetype)
      end

      def reset!(opts)
        index = index(opts)
        index.each do |props|
          props[:used] = false
        end
        set_index(opts, index)
        true
      end

      def clear_cache!
        `rm -rf #{base_cache_dir}`
      end

      private

      def instance
        @instance ||= Flickr.new("#{Rails.root}/config/flickr.yml")
      end

      def base_cache_dir
        "#{Rails.root}/public/system/flickr_cache"
      end

      # app/tmp/flickr_cache/tag1tag2
      def cache_dir(opts)
        tag_dir = opts[:tags].gsub(',', '').gsub(' ', '')
        dir = "#{base_cache_dir}/#{tag_dir}"
        `mkdir -p #{dir}`
        dir
      end

      def next_cached_photo(opts)
        index = index(opts)
        photo = index.detect do |props|
          props[:used] = true if !props[:used]
        end

        if photo
          set_index(opts, index)
          photo
        else
          raise "Could not find any unused photos for #{opts[:tags]}.  Increase :count argument to prime_cache or call reset! to reset photo usage tracking."
        end
      end

      def photo_index_file (opts)
        file_name = "#{cache_dir(opts)}/index.yml"
        FileUtils.touch(file_name)
        file_name
      end

      def cache_photo(opts, url, file)
        index = index(opts)
        index << { :url => url, :file => file, :used => false }
        set_index(opts, index)
      end

      def cached_urls(opts)
        index(opts).collect { |props| props[:url] }
      end

      def index(opts)
        index = YAML.load_file(photo_index_file(opts))
        index ? index : []
      end

      def set_index(opts, index)
        File.open(photo_index_file(opts), 'w') do |out|
          YAML.dump(index, out)
        end
      end

      def flickr_fu_options; { :safe_search => 1, :media => 'photo', :page => 1 }; end

    end
  end
end
