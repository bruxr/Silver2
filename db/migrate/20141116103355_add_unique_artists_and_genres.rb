class AddUniqueArtistsAndGenres < ActiveRecord::Migration
  
  def up
    
    conn = ActiveRecord::Base.connection
    
    movies = {}
    conn.execute('SELECT * FROM artists_movies ORDER BY movie_id').each do |res|
      movies[res['movie_id']] = [] if movies[res['movie_id']].nil?
      if movies[res['movie_id']].include? res['artist_id']
        conn.execute('DELETE FROM artists_movies WHERE id=%s' % res['id'])
      else
        movies[res['movie_id']] << res['artist_id']
      end
    end
    
    movies = {}
    conn.execute('SELECT * FROM genres_movies ORDER BY movie_id').each do |res|
      movies[res['movie_id']] = [] if movies[res['movie_id']].nil?
      if movies[res['movie_id']].include? res['genre_id']
        conn.execute('DELETE FROM genres_movies WHERE id=%s' % res['id'])
      else
        movies[res['movie_id']] << res['genre_id']
      end
    end
    
    add_index :artists_movies, [:movie_id, :artist_id], unique: true
    add_index :genres_movies, [:movie_id, :genre_id], unique: true
    
  end
  
  def down
    
    remove_index :artists_movies, [:movie_id, :artist_id], unique: true
    remove_index :genres_movies, [:movie_id, :genre_id], unique: true
    
  end
  
end
