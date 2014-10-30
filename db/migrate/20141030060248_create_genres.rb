class CreateGenres < ActiveRecord::Migration
  def change
    
    create_table :genres do |t|
      t.string :name, null: false
    end
    add_index :genres, :name, unique: true
    
    create_table :genres_movies do |t|
      t.references :genre, null: false
      t.references :movie, null: false
    end
    add_index :genres_movies, [:genre_id, :movie_id]
    add_index :genres_movies, [:movie_id]
    
  end
end
