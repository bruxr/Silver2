class HstoreSchedules < ActiveRecord::Migration
  def up
    
    enable_extension 'hstore'
    
    add_column :schedules, :ticket_price_temp, :text
    Schedule.where.not(ticket_price: nil).each do |s|
      s.ticket_price_temp = s.ticket_price
      s.ticket_price = nil
      s.save!
    end
    
    remove_column :schedules, :ticket_price
    add_column :schedules, :ticket_price, :hstore
    Schedule.where.not(ticket_price: nil).each do |s|
      s.ticket_price = YAML.parse(s.ticket_price_temp).to_ruby
      s.save!
    end
    
    remove_column :schedules, :ticket_price_temp
    
  end
  
  def down
    
    disable_extension 'hstore'

    add_column :schedules, :ticket_price_temp, :text
    Schedule.where.not(ticket_price: nil).each do |s|
      s.ticket_price_temp = s.ticket_price.to_yaml
      s.ticket_price = ''
      s.save!
    end
    
    remove_column :schedules, :ticket_price
    add_column :schedules, :ticket_price, :text
    Schedule.where.not(ticket_price: nil).each do |s|
      s.ticket_price = s.ticket_price_temp
      s.save!
    end
    
    remove_column :schedules, :ticket_price_temp
    
  end
end
