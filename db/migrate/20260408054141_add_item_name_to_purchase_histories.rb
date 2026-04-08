class AddItemNameToPurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:categories)
    return if column_exists?(:items, :is_subscription)
    add_column :purchase_histories, :item_name, :string
  end
end
