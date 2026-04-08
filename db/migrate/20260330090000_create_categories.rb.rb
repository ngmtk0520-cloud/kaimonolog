class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:categories) 
    return if column_exists?(:items, :is_subscription)
    create_table :categories do |t|
      t.string :name
      t.references :group, null: false, foreign_key: true
      

      t.timestamps
    end
  end
end
