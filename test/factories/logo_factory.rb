require 'action_controller'
require 'action_controller/test_process.rb'
require File.expand_path(File.dirname(__FILE__) + "/photo_helper")

Factory.define :logo do |l|
  l.uploaded_data { photo_upload(flickr_photo("logo")) }
end
