class AddUniqueSources < ActiveRecord::Migration
  
  def up
  
    conn = ActiveRecord::Base.connection
    
    movies = {}
    conn.execute('SELECT * FROM sources ORDER BY movie_id').each do |res|
      movies[res['movie_id']] = [] if movies[res['movie_id']].nil?
      if movies[res['movie_id']].include? res['name']
        conn.execute('DELETE FROM sources WHERE id=%s' % res['id'])
      else
        movies[res['movie_id']] << res['name']
      end
    end
  
    add_index :sources, [:movie_id, :name], unique: true
  
  end
  
end
