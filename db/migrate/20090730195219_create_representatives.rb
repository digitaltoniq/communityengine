class CreateRepresentatives < ActiveRecord::Migration
  def self.up
    create_table :representatives do |t|
      t.integer :user_id, :company_id
      t.string :title, :first_name, :last_name, :full_name_slug   
      t.timestamps
    end
  end

  def self.down
    drop_table :representatives
  end
end



