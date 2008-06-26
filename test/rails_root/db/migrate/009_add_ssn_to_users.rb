class AddSsnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ssn, :string
  end

  def self.down
    remove_column :users, :ssn
  end
end