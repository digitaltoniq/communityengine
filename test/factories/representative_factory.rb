Factory.define :representative do |u|
  u.first_name { Faker::Name.first_name }
  u.last_name { Faker::Name.last_name }
  u.title { "CEO" }
  u.association :company
  u.association :user
  u.representative_role {:representative_role }
end