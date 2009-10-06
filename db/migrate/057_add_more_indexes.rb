class AddMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :published_at
    add_index :posts, :published_as
    add_index :polls, :created_at    
    add_index :polls, :post_id
    add_index :activities, :created_at
    add_index :activities, [:actor_id, :actor_type]
    add_index :activities, [:item_id, :item_type]
    add_index :activities, [:about_id, :about_type]
    add_index :activities, :parent_id
  end
  
  def self.down
    remove_index :posts, :published_at
    remove_index :posts, :published_as        
    remove_index :polls, :created_at    
    remove_index :polls, :post_id        
    remove_index :activities, :created_at
    remove_index :activities, [:actor_id, :actor_type]
    remove_index :activities, [:item_id, :item_type]
    remove_index :activities, [:about_id, :about_type]
  end  
end
