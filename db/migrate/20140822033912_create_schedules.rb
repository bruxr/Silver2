class CreateSchedules < ActiveRecord::Migration
  def change

    create_table :schedules do |t|
      t.integer :movie_id, null: false
      t.integer :cinema_id, null: false
      t.datetime :screening_time, null: false
      t.string :format, null: false, default: '2D'
      t.text :ticket_url
      t.text :ticket_price
      t.string :room, null: false
    end

  end
end
