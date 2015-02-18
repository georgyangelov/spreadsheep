class AddFontSizeToCells < ActiveRecord::Migration
  def change
    change_table :cells do |t|
      t.integer :font_size
    end
  end
end
