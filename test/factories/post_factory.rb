Factory.define :post do |u|
  u.title { Faker::Lorem.words(3).join(' ').capitalize }
  u.raw_post do
    <<-POST
      <img align="left" style="padding: 0px 10px 10px 0px;" src="#{flickr_photo_url('recycling,green')}" />
      #{Faker::Lorem.paragraphs(rand(5) + 4).collect { |p| "<p>#{p}</p>" }.join("") }
    POST
  end
  u.association :user
  u.published_at { rand(7).days.ago }
  u.published_as 'live'
end