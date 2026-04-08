class RemoveKindFromItems < ActiveRecord::Migration[7.1]
  def change
    return unless column_exists?(:items, :kind)
    remove_column :items, :kind, :integer
  end
end
