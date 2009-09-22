class FeatureImage < ActiveRecord::Base
  belongs_to :post
  has_attachment prepare_options_for_attachment_fu(AppConfig.feature_image['attachment_fu_options'])

  # From Photo
  validates_presence_of :size
  validates_presence_of :content_type
  validates_presence_of :filename
  # Causes failure in factory demo data
#  validates_presence_of :post, :if => Proc.new{|record| record.parent.nil? }
  validates_inclusion_of :content_type, :in => attachment_options[:content_type], :message => "is not allowed", :allow_nil => true
  validates_inclusion_of :size, :in => attachment_options[:size], :message => " is too large", :allow_nil => true
end
