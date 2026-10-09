class CreateTables < ActiveRecord::Migration[7.2]
  def up
    create_table :tables do |t|
      t.integer :dealer_id

      t.timestamps
    end

    add_column :games, :table_id, :integer, null: false
    add_index :games, :table_id
  end

  def down
    remove_index :games, :table_id
    remove_column :games, :table_id
    drop_table :tables
  end
end
