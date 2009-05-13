class CreateCats < ActiveRecord::Migration
  def self.up
    create_table :cats do |t|
      t.column :owner_id, :integer
      t.column :address_id, :integer
    end
  end

  def self.down
    drop_table :cats
  end
end
