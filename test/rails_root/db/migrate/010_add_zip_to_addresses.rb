class AddZipToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :zip, :integer
  end

  def self.down
    remove_column :addresses, :zip
  end
end