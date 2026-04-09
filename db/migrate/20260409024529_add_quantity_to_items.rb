class AddQuantityToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :quantity, :integer, default: 1, null: false
  end
end