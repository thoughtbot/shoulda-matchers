class AddZipToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :zip, :string
  end

  def self.down
    remove_column :addresses, :zip
  end
end
