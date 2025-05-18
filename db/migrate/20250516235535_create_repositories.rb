class CreateRepositories < ActiveRecord::Migration[8.0]
  def change
    create_table :repositories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description
      t.integer :visibility

      t.timestamps
    end
  end
end
