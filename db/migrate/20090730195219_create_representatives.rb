class CreateRepresentatives < ActiveRecord::Migration
  def self.up
    create_table :representatives do |t|
      t.integer :user_id, :company_id
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :url_slug
      t.string :linked_in_url
      t.timestamps
    end
    add_index :representatives, :user_id
    add_index :representatives, :company_id
  end

  def self.down
    drop_table :representatives
  end
end



