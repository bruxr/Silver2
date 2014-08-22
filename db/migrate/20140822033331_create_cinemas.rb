class CreateCinemas < ActiveRecord::Migration
  def change
    create_table :cinemas do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, unique: true
      t.decimal :latitude, null: false, precision: 15, scale: 10, default: 0.0
      t.decimal :longitude, null: false, precision: 15, scale: 10, default: 0.0
      t.string :status, null: false, default: 'active'
      t.string :fetcher, null: false
      t.timestamps
    end
  end
end
