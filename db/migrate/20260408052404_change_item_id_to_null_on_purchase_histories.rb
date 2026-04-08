class ChangeItemIdToNullOnPurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:categories)
    return if column_exists?(:items, :is_subscription)
    change_column_null :purchase_histories, :item_id, true
  end
end