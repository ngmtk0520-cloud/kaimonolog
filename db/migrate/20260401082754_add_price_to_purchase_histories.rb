class AddPriceToPurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    add_column :purchase_histories, :price, :integer
  end
end
