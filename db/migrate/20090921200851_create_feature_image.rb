class CreateFeatureImage < ActiveRecord::Migration
  def self.up
    create_table :feature_images do |t|
      t.belongs_to :post
      t.belongs_to :user
      t.string  :filename
      t.string  :content_type
      t.integer :parent_id
      t.string  :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height
      t.timestamps
    end
    add_index :feature_images, :post_id
    add_index :feature_images, :user_id
  end

  def self.down
    drop_table :feature_images
  end
end
