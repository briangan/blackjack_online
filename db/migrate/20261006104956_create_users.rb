class CreateUsers < ActiveRecord::Migration[7.2]
  def up
    create_table :users do |t|
      t.string :type
      t.string :name
      t.float :balance

      t.timestamps
      t.index :type
      t.index :name
    end
  end

  def down
    # Drop table if exists
    drop_table :users
  end
end
