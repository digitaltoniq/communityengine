Factory.define :logo do |u|
  u.sequence(:uploaded_data) do |n|
    DT::FlickrDownloader.photo_upload(:tags => 'logo', :sequence => n, :size => :small)
  end
end
