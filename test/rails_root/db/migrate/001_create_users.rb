class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string
      t.column :email, :string
      t.column :age, :integer
    end
  end

  def self.down
    drop_table :users
  end
end
