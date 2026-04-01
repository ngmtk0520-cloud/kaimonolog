class CreatePurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_histories do |t|
      t.references :item, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.datetime :bought_at

      t.timestamps
    end
  end
end
