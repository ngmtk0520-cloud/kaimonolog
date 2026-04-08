class RemoveKindFromItems < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:categories)
    return if column_exists?(:items, :is_subscription)
    remove_column :items, :kind, :integer
  end
end
