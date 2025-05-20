class CreateRepositoryFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :repository_files do |t|
      t.string :name, null: false
      t.text :content
      t.string :path, null: false
      t.string :file_type, null: false
      t.boolean :is_directory, default: false
      t.references :repository, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :repository_files }

      t.timestamps
    end

    add_index :repository_files, [:repository_id, :path], unique: true
    add_index :repository_files, [:repository_id, :parent_id, :name], unique: true
  end
end
