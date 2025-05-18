class AddIndexToRepositorySlug < ActiveRecord::Migration[8.0]
  def change
    # Add index to repositories slug if it doesn't exist
    add_index :repositories, :slug, unique: true unless index_exists?(:repositories, :slug)
    
    # Add slug to users if it doesn't exist
    unless column_exists?(:users, :slug)
      add_column :users, :slug, :string
      add_index :users, :slug, unique: true
    end
  end
end 