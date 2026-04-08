class ChangeKindTypeInItems < ActiveRecord::Migration[7.1]
  def up
    # 1. まず現在のデフォルト値を削除する（これがエラーの原因）
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
end