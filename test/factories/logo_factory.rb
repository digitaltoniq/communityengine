Factory.define :logo do |u|
  u.uploaded_data do
    DT::FlickrDownloader.for('logo').photo_upload
  end
end
