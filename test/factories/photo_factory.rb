Factory.define :avatar, :class => 'Photo' do |u|
  u.uploaded_data do
    DT::FlickrDownloader.for('headshot,portrait').photo_upload
  end
  u.association :user, :avatar => nil
  u.user_as_avatar { |u| u.user }
end
