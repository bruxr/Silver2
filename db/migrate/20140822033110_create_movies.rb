class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title, null: false, index: true
      t.string :slug, null: false, unique: true
      t.text :overview
      t.integer :runtime
      t.float :rt_score
      t.float :imdb_score
      t.float :metacritic_score
      t.float :aggregate_score
      t.text :poster
      t.text :trailer
      t.string :mtrcb_rating
      t.integer :tmdb_id
      t.string :status, null: false, default: 'incomplete'
      t.timestamps
    end
  end
end