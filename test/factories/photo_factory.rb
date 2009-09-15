Factory.define :photo do |u|
  u.sequence(:uploaded_data) do |n|
    DT::FlickrDownloader.photo_upload(:tags => 'photo', :sequence => n, :size => :small)
  end
  u.association :user, :avatar => nil
end

Factory.define :avatar, :parent => :photo, :class => 'Photo' do |u|
  u.sequence(:uploaded_data) do |n|
    DT::FlickrDownloader.photo_upload(:tags => 'headshot,portrait', :sequence => n, :size => :small)
  end
  u.user_as_avatar { |u| u.user }
end
