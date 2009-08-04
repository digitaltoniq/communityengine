def flickr_photo_url(tags)
  flickr = Flickr.new("#{Rails.root}/config/flickr.yml")
  photo = nil
  until(!photo.nil?) do
    photos = flickr.photos.search(:tags => tags, :safe_search => 1, :per_page => 1, :page => (rand(200) + 1), :media => 'photo')
    photo = photos.first
  end
  photo.url(:small)
end

def flickr_photo(tags)
  url = flickr_photo_url(tags)
  tmp_file = Tempfile.new(ActiveSupport::SecureRandom.hex(10))
  # puts "Downloading from #{url}"
  `wget #{url} -O #{tmp_file.path}`
  tmp_file.path
end

def photo_upload(file)
  mimetype = `file -b --mime #{file}`.gsub(/\n/,"")
  # puts "Found mimetype of #{file} to be #{mimetype}"
  ActionController::TestUploadedFile.new(file, mimetype)
end
