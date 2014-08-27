class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :movie_id, index: true, null: false
      t.string :external_movie_id, null: false
      t.string :source, index: true, null: false
      t.float :score, null: false, default: 0
      t.text :url
      t.timestamps
    end
  end
end
