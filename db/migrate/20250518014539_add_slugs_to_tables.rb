class AddSlugsToTables < ActiveRecord::Migration[8.0]
  def change
    # Add slug to repositories if it doesn't exist
    unless column_exists?(:repositories, :slug)
      add_column :repositories, :slug, :string
      add_index :repositories, :slug, unique: true
    end

    # Add slug to users if it doesn't exist
    unless column_exists?(:users, :slug)
      add_column :users, :slug, :string
      add_index :users, :slug, unique: true
    end
  end
end
