Factory.define :following do |f|
  f.association :followee
  f.association :user
end