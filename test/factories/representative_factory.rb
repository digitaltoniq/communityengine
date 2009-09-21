Factory.define :representative do |u|
  u.association :user
  u.first_name { |r| r.user.email.split('@').first.capitalize }
  u.last_name { Faker::Name.last_name }
  u.title { ["CEO", "Executive VP", "Director of Product Development", "User Experience Engineer"].rand }
  u.linked_in_url { "http://#{Faker::Internet.domain_name}/profile/#{rand(10000)}.html" }
  u.association :company
  u.representative_role { RepresentativeRole[:representative] }
end
