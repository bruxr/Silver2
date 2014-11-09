class CreateCinemas < ActiveRecord::Migration
  def change
    
    create_table :cinemas do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.decimal :latitude, null: false, precision: 15, scale: 10, default: 0.0
      t.decimal :longitude, null: false, precision: 15, scale: 10, default: 0.0
      t.string :status, null: false, default: 'active'
      t.string :fetcher
      t.string :phone_number
      t.text :website
      t.timestamps
    end
    
    add_index :cinemas, :name
    add_index :cinemas, :slug, unique: true
    
  end
end
