class CreateRepresentativeInvitations < ActiveRecord::Migration
  def self.up
    create_table :representative_invitations do |t|
      t.belongs_to :user, :null => :false
      t.belongs_to :company, :null => :false
      t.string :email_addresses, :message
      t.timestamps
    end
    add_index :representative_invitations, :user_id
    add_index :representative_invitations, :company_id
  end

  def self.down
    drop_table :representative_invitations
  end
end

