class CreateLikes < ActiveRecord::Migration

  def self.up
    create_table :likes, :force => true do |t|
      t.boolean :like, :default => true, :null => false
      t.belongs_to :likeable, :polymorphic => true, :null => false
      t.belongs_to :user, :null => false
      t.datetime :created_at, :null => false
    end
    add_index :likes, :user_id
    add_index :likes, [:likeable_id, :likeable_type]
  end

  def self.down
    drop_table :likes
  end
end
