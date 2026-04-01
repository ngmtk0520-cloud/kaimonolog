class AddKindToItems < ActiveRecord::Migration[7.1]
  def change
    # default: 0 (都度購入) を設定
    add_column :items, :kind, :integer, default: 0, null: false
  end
end