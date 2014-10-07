class CreateSchedules < ActiveRecord::Migration
  def change
    
    reversible do |dir|
      dir.up do
        enable_extension 'hstore'
      end
      dir.down do
        disable_extension 'hstore'
      end
    end

    create_table :schedules do |t|
      t.integer :movie_id, null: false
      t.integer :cinema_id, null: false
      t.datetime :screening_time, null: false
      t.string :format, null: false, default: '2D'
      t.text :ticket_url
      t.hstore :ticket_price
      t.string :room, null: false
      t.timestamps
    end

  end
end
