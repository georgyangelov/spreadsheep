class CreateDirectories < ActiveRecord::Migration
  def change
    create_table :directories do |t|
      t.string :name
      t.string :slug

      t.integer :creator_id, null: false, index: true
      t.integer :parent_id, null: true, default: nil, index: true

      t.timestamps null: false
    end

    create_table :user_shares do |t|
      t.belongs_to :user
      t.belongs_to :directory

      t.timestamps null: false
    end
  end
end
