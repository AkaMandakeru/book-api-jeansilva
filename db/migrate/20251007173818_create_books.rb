class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.integer :status, default: 0
      t.string :reserved_by
      t.string :author, null: false
      t.date :published_at

      t.timestamps
    end
  end
end
