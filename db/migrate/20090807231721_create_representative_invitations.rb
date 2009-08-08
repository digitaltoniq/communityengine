class CreateRepresentativeInvitations < ActiveRecord::Migration
  def self.up
    create_table :representative_invitations do |t|
      t.string :email_addresses, :message
      t.integer :representative_id
      t.timestamps
    end
  end

  def self.down
    drop_table :representative_invitations
  end
end

