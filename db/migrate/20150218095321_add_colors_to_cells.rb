class AddColorsToCells < ActiveRecord::Migration
  def change
    change_table :cells do |t|
      t.string :background_color
      t.string :foreground_color
    end
  end
end
