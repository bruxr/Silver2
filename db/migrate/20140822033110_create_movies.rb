class CreateMovies < ActiveRecord::Migration
  def change
    
    create_table :movies do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :tagline
      t.text :overview
      t.integer :runtime
      t.float :aggregate_score
      t.text :poster
      t.text :backdrop
      t.text :trailer
      t.string :mtrcb_rating
      t.string :status, null: false, default: 'incomplete'
      t.text :website
      t.date :release_date
      t.timestamps
    end
    
    add_index :movies, :title, unique: true
    add_index :movies, :slug, unique: true
    
  end
end