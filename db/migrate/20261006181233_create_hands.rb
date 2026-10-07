class CreateHands < ActiveRecord::Migration[7.2]
  def up
    create_table :hands do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :order_index
      t.float :total_bet_amount
      t.string :status

      t.timestamps

      t.index [:game_id]
      t.index [:game_id, :user_id]
      t.index :order_index
    end
  end

  def down
    drop_table :hands
  end
end
