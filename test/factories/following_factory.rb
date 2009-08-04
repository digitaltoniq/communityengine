Factory.define :following do |f|
  f.association :followed
  f.association :user
end