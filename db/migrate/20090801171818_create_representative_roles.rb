class CreateRepresentativeRoles < ActiveRecord::Migration
  def self.up
    create_table :representative_roles do |t|
      t.string :name
      t.timestamps
    end
    add_index :representative_roles, :name

    # TODO: Move this to app:bootstrap=like task
    RepresentativeRole.enumeration_model_updates_permitted = true
    RepresentativeRole.create(:name => 'representative')
    RepresentativeRole.enumeration_model_updates_permitted = false

    add_column :representatives, :representative_role_id, :integer
  end

  def self.down
    drop_table :representative_roles
  end
end
