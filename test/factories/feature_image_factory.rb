Factory.define :feature_image do |i|
  i.sequence(:uploaded_data) do |n|
    DT::FlickrDownloader.photo_upload(:tags => 'recycling,green', :sequence => n, :size => :small)
  end
end
