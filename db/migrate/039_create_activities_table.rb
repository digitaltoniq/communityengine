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
  end

  def self.down
    drop_table :activities
  end
end
