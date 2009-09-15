Factory.define :user do |u|
  u.login do
    while User.exists?(:login => (l = Faker::Name.first_name))
    end
    l
  end
  u.email { |u| u.login + "@example.com" }
  u.password 'password'
  u.password_confirmation { |u| u.password }
  u.birthday { (rand(30) + 20).years.ago }
  u.activated_at { (rand(1) + 200).days.ago }
  u.description { Faker::Lorem.sentences(rand(3) + 3).join(' ') }
  u.association :avatar
  u.role { |u| Role[:member] }
end
