class CreateCommits < ActiveRecord::Migration[8.0]
  def change
    create_table :commits do |t|
      t.string :sha
      t.text :message
      t.references :repository, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :files_changed

      t.timestamps
    end
  end
end
