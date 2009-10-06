class CreateActivitiesTable < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.belongs_to :actor, :polymorphic => true
      t.belongs_to :item, :polymorphic => true
      t.belongs_to :about, :polymorphic => true
      t.belongs_to :parent
      t.column :action, :string
      t.column :created_at, :datetime
    end

    add_index :activities, [:actor_id, :actor_type]
    add_index :activities, [:item_id, :item_type]
    add_index :activities, [:about_id, :about_type]
    add_index :activities, :parent_id
  end

  def self.down
    drop_table :activities
  end
end
