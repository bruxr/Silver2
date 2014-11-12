class AddHiddenMovies < ActiveRecord::Migration
  def change
    add_column :movies, :is_hidden, :boolean, default: false
  end
end
