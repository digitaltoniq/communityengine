require 'action_controller/test_process.rb'

# TODO: This is not particularly well-structured.  More of a holding tank for
# our current Flickr needs in a somewhat reusable format (plugin)
#
# TODO: Be more structured with args instead of just passing around opts hash
# like a 14 year phillipino whore
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

      # Get a local photo path for the given opts.  Use :sequence
      # if getting photo as part of larger sequential grab
      #  (1..20).to_a.collect { |i| photo_path(:tags => 'test', :sequence => i) }
      def photo_path(opts)
        sequence = opts[:sequence] || 1
        prime(opts.merge(:count => sequence))
        cached_files(opts)[sequence - 1]
      end

      # Get a photo for the given options as though it were
      # uploaded as part of a post request
      def photo_upload(opts)
        file = photo_path(opts)
        mimetype = `file -b --mime #{file}`.gsub(/\n/,"")
        ActionController::TestUploadedFile.new(file, mimetype)
      end

      # Get only the URL for the requested photo sequence
      def photo_url(opts)
        photo_urls(opts.merge(:start => opts[:sequence])).first
      end

      def clear_cache!
        `rm -rf #{base_cache_dir}`
      end

      private

      # Prime the pump by downloading photos locally to be reused.  Only
      # downloads the minimal necessary
      def prime(opts)
        start = cached_files(opts).size
        needed =  (opts[:count] || 1) - start # requested - actual
        download(opts.merge(:count => needed, :start => start)) if needed > 0
      end

      def download(opts)
        photo_urls(opts).each do |url|
          url_ext = url.from(url.rindex('.') + 1)
          cache_file = File.new("#{cache_dir(opts)}/#{ActiveSupport::SecureRandom.hex(10)}.#{url_ext}", "w+")
          `wget #{url} -O #{cache_file.path}`
          
        end
      end

      # Get flickr-fu photos
      #  photos(:tags => 'naked,chicks', :count => 20)
      def photos(opts)
        start = opts[:start] || 1
        count = opts[:count] || 1

        # Get photos one by one
        (start...(start+count)).to_a.collect do |i|
          f_opts = flickr_fu_options.merge(:tags => opts[:tags], :page => i, :per_page => 1)
          instance.photos.search(f_opts).photos
        end.flatten
      end

      # photos(:tags => 'naked,chicks', :count => 20, :size => :medium)
      def photo_urls(opts)
        photos(opts).collect { |p| p.url(opts[:size] || :medium)}
      end

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

      def cached_files(opts)
        `ls -t #{cache_dir(opts)}`.split("\n").collect { |f| "#{cache_dir(opts)}/#{f}" }
      end

      def flickr_fu_options; { :safe_search => 1, :media => 'photo', :page => 1 }; end

    end
  end
end
