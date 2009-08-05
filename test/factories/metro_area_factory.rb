Factory.define :metro_area do |c|
  c.name { :name }
  c.association :state
  c.country { Country.get(:us) }
end
