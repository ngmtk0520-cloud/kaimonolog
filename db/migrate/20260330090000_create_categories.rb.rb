class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:categories)
    create_table :categories do |t|
      t.string :name
      t.references :group, null: false, foreign_key: true
      

      t.timestamps
    end
  end
end
