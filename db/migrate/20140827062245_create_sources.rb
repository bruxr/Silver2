class CreateSources < ActiveRecord::Migration
  def change
    
    create_table :sources do |t|
      t.belongs_to :movie, null: false
      t.string :name, null: false
      t.string :external_id, null: false
      t.text :url, null: false
      t.float :score
    end
    
    add_index :sources, :movie_id
    
  end
end
