Factory.define :representative do |u|
  u.association :user
  u.title { ["CEO", "Executive VP", "Director of Product Development", "User Experience Engineer"].rand }
  u.linked_in_url { "http://linkedin.com/profile/#{rand(10000)}.html" }
  u.association :company
  u.representative_role { RepresentativeRole[:representative] }
end
