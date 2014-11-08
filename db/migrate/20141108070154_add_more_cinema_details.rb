class AddMoreCinemaDetails < ActiveRecord::Migration
  def change
    add_column :cinemas, :phone_number, :string
    add_column :cinemas, :website, :text
  end
end
