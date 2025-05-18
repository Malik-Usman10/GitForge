class AddLanguageToRepositories < ActiveRecord::Migration[8.0]
  def change
    add_column :repositories, :language, :string
  end
end
