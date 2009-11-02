Factory.define :representative_invitation do |u|
  u.association :user
  u.company { |i| Company.for_user(i.user) || Company.all.rand }
  u.email_addresses do |i|
    (1..(rand(3) + 2)).to_a.collect { Faker::Internet.email }.join(', ')
  end
  u.message { Faker::Lorem.paragraph(4) }
end
