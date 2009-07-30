class Logo < ActiveRecord::Base
  belongs_to :company
  
  # TODO: use AppConfig as in Photo
  has_attachment :content_type => :image,
               :storage => :file_system,
               :max_size => 500.kilobytes,
               :resize_to => '320x200>',
               :thumbnails => { :thumb => '100x100>' }

  # TODO: additional validates as in Photo
  validates_as_attachment
end
