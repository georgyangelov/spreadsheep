class AddIdToCells < ActiveRecord::Migration
  def change
    add_column :cells, :id, :primary_key
  end
end
