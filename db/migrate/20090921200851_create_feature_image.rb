class CreateFeatureImage < ActiveRecord::Migration
  def self.up
    create_table :feature_images do |t|
      t.integer :post_id
      t.string  :filename
      t.string  :content_type
      t.integer :parent_id
      t.string  :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end

  def self.down
    drop_table :feature_images
  end
end
