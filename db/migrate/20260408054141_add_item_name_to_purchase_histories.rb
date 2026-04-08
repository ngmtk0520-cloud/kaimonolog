class AddItemNameToPurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    add_column :purchase_histories, :item_name, :string
  end
end
