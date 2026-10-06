class CreateGames < ActiveRecord::Migration[7.2]
  def up
    create_table :games do |t|
      t.datetime :started_at
      t.string :status
      t.integer :dealer_id

      t.timestamps
      t.index :status
    end
  end

  def down
    drop_table :games
  end
end
