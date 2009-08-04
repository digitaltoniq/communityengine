require 'action_controller'
require 'action_controller/test_process.rb'
require File.expand_path(File.dirname(__FILE__) + "/photo_helper")

# {'tempfile' => StringIO.new(img.to_blob), 'content_type' => @photo.content_type, 'filename' => "custom_#{@photo.filename}"}

Factory.define :photo do |u|
  u.uploaded_data { photo_upload("#{Rails.root}/test/files/images/villain.jpg") }
  u.association :user, :avatar => nil
end

Factory.define :avatar, :parent => :photo, :class => 'Photo' do |u|
  u.uploaded_data { photo_upload(flickr_photo("headshot,portrait")) }
  u.user_as_avatar { |u| u.user }
end

