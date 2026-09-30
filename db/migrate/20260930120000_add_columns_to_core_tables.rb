class AddColumnsToCoreTables < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false
    add_column :games, :name, :string, null: false

    add_reference :ratings, :user, null: false, foreign_key: true
    add_reference :ratings, :game, null: false, foreign_key: true
    add_column :ratings, :rating, :float, null: false
    add_index :ratings, [ :user_id, :game_id ], unique: true

    add_reference :backlog_items, :user, null: false, foreign_key: true
    add_reference :backlog_items, :game, null: false, foreign_key: true
    add_column :backlog_items, :status, :string, null: false, default: "pending"
  end
end
