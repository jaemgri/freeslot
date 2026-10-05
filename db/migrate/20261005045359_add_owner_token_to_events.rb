class AddOwnerTokenToEvents < ActiveRecord::Migration[8.1]
  def up
    add_column :events, :owner_token, :string

    # Existing plans get a token too, so the unique index can be added
    select_values("SELECT id FROM events").each do |id|
      execute "UPDATE events SET owner_token = '#{SecureRandom.base58(24)}' WHERE id = #{id.to_i}"
    end

    add_index :events, :owner_token, unique: true
  end

  def down
    remove_column :events, :owner_token
  end
end
