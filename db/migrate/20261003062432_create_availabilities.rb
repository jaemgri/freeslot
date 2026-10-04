class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :participant, null: false, foreign_key: true
      t.datetime :slot_at

      t.timestamps
    end
  end
end
