class CreatePlayCards < ActiveRecord::Migration[7.2]
  def up
    create_table :play_cards do |t|
      t.integer :game_id, null: false
      t.integer :order_index, default: 0
      t.integer :given_user_id
      t.string :rank
      t.string :suit

      t.index :game_id
      t.index [:rank, :suit]
      t.index :order_index
      t.index [:game_id, :given_user_id]
    end
  end

  def down
    drop_table :play_cards
  end
end
