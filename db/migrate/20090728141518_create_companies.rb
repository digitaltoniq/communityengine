  class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string  :name,          :limit => 60, :default => "", :null => false
      t.text    :description
      t.integer :logo_id
      t.integer :view_count,    :default => 0
      t.integer :state_id, :country_id, :metro_area_id
      t.boolean :profile_public
      t.string  :zip
      t.string  :url_slug
      t.string  :url
#      t.string  :domains
      t.timestamps
    end
    add_index :companies, :url_slug
  end

  def self.down
    drop_table :companies
  end
end