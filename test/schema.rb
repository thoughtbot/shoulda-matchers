ActiveRecord::Schema.define(:version => 1) do
	create_table :posts do |t|
		t.column :title, :string
		t.column :body, :text
		t.column :user_id, :integer
	end

	create_table :users do |t|
		t.column :name, :string
		t.column :email, :string
		t.column :age, :integer
		t.column :password, :string
		t.column :company_id, :integer
	end

  create_table :taggings do |t|
    t.column :user_id, :integer
    t.column :tag_id, :integer
  end

	create_table :tags do |t|
		t.column :name, :string
	end

end

