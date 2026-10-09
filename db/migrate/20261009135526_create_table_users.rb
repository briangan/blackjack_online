class CreateTableUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :table_users do |t|
      t.integer :table_id, null: false
      t.integer :user_id, null: false
      
      t.index :table_id
      t.index :user_id
    end
  end
end
