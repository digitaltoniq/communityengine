Factory.define :comment do |u|
  u.comment { Faker::Lorem.paragraphs(rand(2) + 1).join("\n") }
  u.association :user
  u.association :commentable, :factory => :post
  u.recipient { |c| c.user }
end