Factory.define :post do |u|
  u.title { Faker::Lorem.words(3).join(' ').capitalize }
  u.sequence(:raw_post) do |n|
    image_url = DT::FlickrDownloader.photo_url(:tags => 'recycling,green', :sequence => n, :size => :small)
    <<-POST
      #{Faker::Lorem.paragraphs(rand(2) + 1).collect { |p| "<p>#{p}</p>" }.join("") }
      <img align="left" style="padding: 0px 10px 10px 0px;" src="#{image_url}" />
      #{Faker::Lorem.paragraphs(rand(5) + 4).collect { |p| "<p>#{p}</p>" }.join("") }
    POST
  end
  u.association :photo, :factory => :feature_image
  u.association :user
  u.published_at { rand(7).days.ago }
  u.published_as 'live'
  u.view_count { rand(10000) }
end
