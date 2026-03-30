markdown
### kaimonolog(カイモノログ)
## データベース設計

### users テーブル
### ログインユーザーを管理します。groupに所属することで共有を可能にします。

| Column             | Type       | Options                   |
| ------------------ | ---------- | ------------------------- |
| nickname           | string     | null: false               |
| email              | string     | null: false, unique: true |
| encrypted_password | string     | null: false               |
| group              | references | foreign_key: true         |


#### Association
- belongs_to :group
- has_many :purchase_histories


### groups テーブル
### 家族やペアの単位です。このIDを介してリストを共有します。

| Column                 | Type    | Options                   |
| ---------------------- | ------- | ------------------------- |
| name                   | string  | null: false               |
| invite_token           | text    | null: false, unique: true |

#### Association
- has_many :users
- has_many :item
- has_many :category


### items テーブル
### 買い物リスト本体です。定期購入フラグでAI学習対象を判別します。

| Column            | Type       | Options                        |
| ----------------- | ---------- | ------------------------------ |
| name              | string     | null: false                    |
| is_checked        | boolean    | null: false, default: false    |
| is_subscription   | boolean    | null: false, default: false    |
| category          | references | null: false, foreign_key: true |
| group             | references | null: false, foreign_key: true |

#### Association
- belongs_to :group
- belongs_to :category
- has_many :purchase_histories



### purchase_histories  テーブル
いつ、いくらで買ったかの記録です。カレンダー表示とAI予測の元データになります。

| Column        | Type       | Options                        |
| ------------- | ---------- | ------------------------------ |
| purchased_at  | datetime   | null: false                    |
| price         | integer    |                                |
| item          | references | null: false, foreign_key: true |
| user          | references | null: false, foreign_key: true |

#### Association
- belongs_to :item
- belongs_to :user


### categories テーブル
グループごとにカスタマイズ可能なカテゴリーです。

| Column                 | Type       | Options                        |
| ---------------------- | ---------- | ------------------------------ |
| name                   | string     | null: false                    |
| group                  | references | null: false, foreign_key: true |

- belongs_to :group
- has_many :item