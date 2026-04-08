class RemoveKindFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :items, :kind, :integer
  end
end
