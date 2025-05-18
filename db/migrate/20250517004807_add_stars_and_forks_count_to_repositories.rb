class AddStarsAndForksCountToRepositories < ActiveRecord::Migration[8.0]
  def change
    add_column :repositories, :stars_count, :integer, default: 0, null: false
    add_column :repositories, :forks_count, :integer, default: 0, null: false
    
    add_index :repositories, :stars_count
    add_index :repositories, :forks_count
  end
end
