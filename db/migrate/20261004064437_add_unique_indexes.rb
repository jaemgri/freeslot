class AddUniqueIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :availabilities, [ :participant_id, :slot_at ], unique: true, if_not_exists: true
    add_index :participants, [ :event_id, :name ], unique: true, if_not_exists: true
  end
end
