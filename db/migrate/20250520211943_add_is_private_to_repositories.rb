class AddIsPrivateToRepositories < ActiveRecord::Migration[8.0]
  def change
    add_column :repositories, :is_private, :boolean, default: false, null: false
  end
end
