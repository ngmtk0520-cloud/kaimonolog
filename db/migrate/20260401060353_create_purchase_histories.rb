class CreatePurchaseHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_histories do |t|
      t.references :item, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.datetime :bought_at, null:false
      t.integer :price

      t.timestamps
    end
  end
end
