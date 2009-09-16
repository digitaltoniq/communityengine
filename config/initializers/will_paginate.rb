ActiveRecord::Base.class_eval do
  def self.per_page; 15; end
end
