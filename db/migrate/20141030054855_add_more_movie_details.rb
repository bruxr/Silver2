class AddMoreMovieDetails < ActiveRecord::Migration
  def change
    
    add_column(:movies, :website, :text)
    add_column(:movies, :tagline, :string)
    add_column(:movies, :release_date, :date)
    
  end
end
