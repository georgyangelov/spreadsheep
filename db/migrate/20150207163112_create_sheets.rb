class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets do |t|
      t.belongs_to :directory
      t.belongs_to :user

      t.string :name

      t.timestamps null: false
    end

    create_table :cells, id: false do |t|
      t.belongs_to :sheet

      t.integer :row, null: false
      t.integer :column, null: false

      t.string :content

      t.index :sheet_id
      t.index [:sheet_id, :row, :column], unique: true
    end
  end
end
