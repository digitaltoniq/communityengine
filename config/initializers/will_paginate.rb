ActiveRecord::Base.class_eval do
  def self.per_page; 10; end
end
