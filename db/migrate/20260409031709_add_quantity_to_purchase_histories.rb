class AddQuantityToPurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    add_column :purchase_histories, :quantity, :integer, default: 1, null: false
  end
end
