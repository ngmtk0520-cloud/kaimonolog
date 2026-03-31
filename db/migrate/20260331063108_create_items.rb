class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.boolean :is_checked, null: false, default: false
      t.boolean :is_subscription, null: false, default: false
      t.datetime :last_bought_at
      t.integer :cycle_days, null: false, default: 0
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
