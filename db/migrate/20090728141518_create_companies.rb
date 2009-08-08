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
      t.string  :name_slug
      t.string  :domains
      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end