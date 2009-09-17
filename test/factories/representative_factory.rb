Factory.define :representative do |u|
  u.first_name { Faker::Name.first_name }
  u.last_name { Faker::Name.last_name }
  u.title { ["CEO", "Executive VP", "Director of Product Development", "User Experience Engineer"].rand }
  u.linked_in_url { "http://#{Faker::Internet.domain_name}/profile/#{rand(10000)}.html" }
  u.association :company
  u.association :user
  u.representative_role { RepresentativeRole[:representative] }
end
