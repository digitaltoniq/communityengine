Factory.define :user do |u|
  # u.login { n = Faker::Name.first_name.downcase until User.find_by_login(n).nil?; n }   # TODO:why doesn't this work? DJS
  u.login { Faker::Name.first_name.downcase + rand(99).to_s }
  u.email { Faker::Internet.email }
  u.password 'password'
  u.password_confirmation { |u| u.password }
  u.birthday { (rand(30) + 20).years.ago }
  u.activated_at { (rand(1) + 200).days.ago }
  u.description { Faker::Lorem.sentences(rand(3) + 3).join(' ') }
  u.association :avatar
end