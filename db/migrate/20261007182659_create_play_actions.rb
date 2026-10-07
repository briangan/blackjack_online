class CreatePlayActions < ActiveRecord::Migration[7.2]
  def up
    create_table :play_actions do |t|
      t.string :type
      t.integer :hand_id
      t.float :amount

      t.timestamps
      t.index :hand_id
    end
  end

  def down
    drop_table :play_actions
  end
end
