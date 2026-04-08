class ChangeItemIdToNullOnPurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    change_column_null :purchase_histories, :item_id, true
  end
end