class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # We'll use real_name instead of name
    add_column :users, :location, :string unless column_exists?(:users, :location)
    add_column :users, :website, :string unless column_exists?(:users, :website)
    # bio already exists
  end
end
