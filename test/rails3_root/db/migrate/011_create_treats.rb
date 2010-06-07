class CreateTreats < ActiveRecord::Migration
  def self.up
    create_table :treats do |t|
      t.integer :dog_id
      t.timestamps
    end
  end

  def self.down
    drop_table :treats
  end
end