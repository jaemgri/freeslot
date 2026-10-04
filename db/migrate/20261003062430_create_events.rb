class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.string :slug
      t.date :start_date
      t.date :end_date
      t.integer :start_hour
      t.integer :end_hour

      t.timestamps
    end
    add_index :events, :slug, unique: true
  end
end
