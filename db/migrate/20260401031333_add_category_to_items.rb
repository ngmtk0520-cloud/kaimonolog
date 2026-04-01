class AddCategoryToItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :items, :category, null: true, foreign_key: true
  end
end
