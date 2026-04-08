class ChangeKindTypeInItems < ActiveRecord::Migration[7.1]
  def up
    # 💡 追加：もしすでに kind カラムが integer 型なら、このマイグレーションをスキップする
    return if column_exists?(:items, :kind) && column_spec(:items, :kind).type == :integer

    # 1. まず現在のデフォルト値を削除する
    change_column_default :items, :kind, nil
    
    # 2. 型を integer に変換する
    change_column :items, :kind, 'integer USING CAST(kind AS integer)'
    
    # 3. 改めて整数の 0 をデフォルト値として設定する
    change_column_default :items, :kind, 0
  end

  def down
    change_column_default :items, :kind, nil
    change_column :items, :kind, :string
    change_column_default :items, :kind, "0"
  end

  private

  # カラムの詳細情報を取得するためのヘルパー
  def column_spec(table, column)
    connection.columns(table).find { |c| c.name == column.to_s }
  end
end