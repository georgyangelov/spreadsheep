class CreateDirectories < ActiveRecord::Migration
  def change
    create_table :directories do |t|
      t.string :name
      t.string :slug

      t.belongs_to :user
      t.integer :parent_id, null: true, default: nil, index: true
    end

    create_table :directories_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :directory
    end
  end
end
