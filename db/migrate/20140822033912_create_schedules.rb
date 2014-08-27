class CreateSchedules < ActiveRecord::Migration
  def change
    create_join_table :movies, :cinemas, table_name: :schedules do |t|
      t.datetime :screening_time, null: false, default: '0000-00-00 00:00:00'
      t.string :format, null: false, default: '2D'
      t.text :ticket_url
      t.float :ticket_price
      t.string :room, null: false
      t.timestamps
    end
  end
end
