class AddPublicSheets < ActiveRecord::Migration
  def change
    change_table :sheets do |t|
      t.boolean :public, default: false
    end
  end
end
