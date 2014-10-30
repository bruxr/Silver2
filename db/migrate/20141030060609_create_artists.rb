class CreateArtists < ActiveRecord::Migration
  def change
    
    create_table :artists do |t|
      t.string :name, null: false
    end
    add_index :artists, :name, unique: true
    
    create_table :artists_movies do |t|
      t.references :artist, null: false
      t.references :movie, null: false
    end
    add_index :artists_movies, [:artist_id, :movie_id]
    add_index :artists_movies, [:movie_id]
    
  end
end
