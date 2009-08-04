Factory.define :user do |u|
  u.login { Faker::Name.first_name.downcase }
  u.email { Faker::Internet.email }
  u.password 'password'
  u.password_confirmation { |u| u.password }
  u.birthday { (rand(30) + 20).years.ago }
  u.activated_at Time.now
  u.description { Faker::Lorem.sentences(rand(3) + 3).join(' ') }
  u.association :avatar
end