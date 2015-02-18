class AddAlignmentToCells < ActiveRecord::Migration
  def change
    change_table :cells do |t|
      t.integer :alignment
    end
  end
end
