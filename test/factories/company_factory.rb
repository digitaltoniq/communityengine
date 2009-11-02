Factory.define :company do |c|
  c.name { Faker::Company.name }
  # TODO c.slogan { Faker::Company.catch_phrase } 
  c.description { Faker::Lorem.sentences(rand(3) + 3).join(' ') }
  c.association :logo
  c.metro_area { MetroArea.all.rand }
  c.url { "http://#{Faker::Internet.domain_name}" }
end
