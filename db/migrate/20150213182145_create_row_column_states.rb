class CreateRowColumnStates < ActiveRecord::Migration
  def change
    create_table :row_column_states do |t|
      t.belongs_to :sheet

      t.integer :index
      t.integer :type

      t.integer :width, null: true

      t.index [:sheet_id, :type, :index], unique: true
    end
  end
end
