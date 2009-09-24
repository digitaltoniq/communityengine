Factory.define :feature_image do |i|
  i.uploaded_data do
    DT::FlickrDownloader.for('recycling,green').photo_upload
  end
end
