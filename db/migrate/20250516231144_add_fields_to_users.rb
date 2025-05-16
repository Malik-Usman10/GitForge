class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true
    add_column :users, :real_name, :string
    add_column :users, :bio, :text
  end
end
