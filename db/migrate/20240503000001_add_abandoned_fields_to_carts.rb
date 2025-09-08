class AddAbandonedFieldsToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, default: false, null: false
    add_column :carts, :last_interaction_at, :datetime
    add_column :carts, :session_id, :string

    add_index :carts, :session_id
    add_index :carts, :abandoned
    add_index :carts, :last_interaction_at
  end
end
