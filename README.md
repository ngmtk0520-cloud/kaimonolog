markdown

## kaimonolog（カイモノログ）

App URL/https://kaimonolog.fly.dev

## アプリの目的概要
モバイル端末での利用を最適化した、家族やパートナー向けの「買い物情報共有・需要予測アプリ」です。日常の買い物を「単なる記録」から「次回の予測」へと繋げ、買い忘れや二重買いを防ぐ体験を提供します。

## 開発背景 / ペルソナ
ターゲット: 家族や恋人と同居し、日用品の買い出しを分担している方。
課題: 「何がいつ切れるか分からない」「相手が既に買ったか不明」という情報の非対称性を解消し、円滑な家計管理を実現するために開発しました。

## 主な機能
独自の共有システム: 招待トークンを用いた動的なグループ生成により、特定のユーザー間でのみセキュアにデータを共有。
買い時予測アルゴリズム: 過去の購入頻度に基づき、独自のルールベースで次回購入日を算出。
カレンダー連携: 購入履歴の可視化、および日付単位での新規登録・編集機能。
支出の統計分析: 購入データをグラフ化し、家計の支出傾向を直感的に把握可能。
PWA（Progressive Web Apps）対応: ネイティブアプリに近い操作感を実現し、ホーム画面からの素早いアクセスを可能にしました。


## 技術的工夫と課題解決

1. ユーザー体験（UX）に根ざした予測ロジック
「買い時予測」の実装にあたり、あえて複雑な機械学習モデルを避け、最短2回の履歴から算出するルールベースアルゴリズムを採用しました。
意図: 導入初期のデータ不足段階でも早期に価値を提供するため。
効果: 「平均間隔から逆算して残り4日」という明確な根拠を提示することで、ユーザーの直感に寄り添った「ついで買い」を促します。

2. データ設計の精密化
単なる合計金額の記録に留まらず、「単価」と「個数」を分離したデータ構造を採用。これにより、物価変動のトラッキングや、消費ペースの精密な分析を可能にする拡張性を確保しました。

3. インフラトラブルへの対応
Fly.ioへのデプロイ過程において、データベースのコンフリクトによりデプロイが停止する課題に直面しました。
対策: コンソール操作によるデバッグが不可欠と判断し、一時的にメモリリソースを 256MB から 1024MB へ拡張。
結果: リソース不足によるタイムアウトを回避し、リモート環境での直接的な原因究明と復旧を実現しました。

4. モバイルファーストの実装
PWA化に伴い、実機特有のレイアウト崩れ（右端の表示欠けやUI要素の重なり）を徹底的に排除。1px単位のCSS調整を行い、Webブラウザであることを意識させない滑らかな操作感を実現しました。

5. 堅牢な開発サイクルの維持（テストの徹底）
頻繁な機能追加やデータ構造の変更に伴うバグを未然に防ぐため、RSpecを用いた自動テストを導入しました。
意図: 既存機能の品質を担保しつつ、大胆なリファクタリングやDB設計の変更を行える環境を作るため。
効果: 大規模なマイグレーション実施時も、テストスイートによりデグレード（先祖返り）を即座に検知。本番環境へのデプロイに対する心理的障壁を下げ、安全なリリースサイクルを維持しました。

## kaimonologにおけるHotwire (Turbo) 活用状況
本アプリでは、Rails 7標準の Turbo を活用し、SPA（シングルページアプリケーション）のような滑らかな操作感を実現しています。

1. Turbo Drive（アプリ全体の高速化）
活用度：100%（全画面）
効果： 画面遷移時にページ全体を再読み込みせず、<body> タグの中身だけを差し替えることで、モバイルアプリのようなサクサクとした画面遷移を実現しています。PWA化した際の「ネイティブアプリ感」の核となっています。

2. Turbo Frames（部分更新）
活用度：フォームやリスト操作
効果： 例えば「買い物リストのチェック」や「個数の変更」をした際、ページ全体をリロードせずにその部分だけを書き換えています。これにより、スクロール位置が保持され、ユーザーにストレスを与えない設計にしています。

3. Turbo Streams（リアルタイム性）
活用度：アイテムの追加・削除
効果： 商品を登録した瞬間に、ページを読み直すことなく「買い物リスト」の末尾にシュッと新しいアイテムが現れる挙動に使用。共有相手が追加した際も、画面を更新せずに反映させる土台となっています。

4. Stimulus（JavaScriptの整理）
活用度：招待コードのコピー、グラフの動的表示
効果： 招待コードの「ワンタップコピー」など、ちょっとしたJavaScriptが必要な箇所で、Rails流の綺麗なコード管理を行っています。

## 苦労した点
設計段階での想定を超えたデータ構造の変更により、本番環境でDB不整合が発生しました。

原因分析: 頻繁な機能追加に伴いマイグレーションが複雑化し、デプロイ時にDBロックが発生。さらに、Fly.ioの標準リソース（256MB）では、調査のためのRailsコンソール起動時にメモリ不足でプロセスが強制終了（OOM Kill）され、原因特定が極めて困難な状況に陥りました。

解決プロセス: 一時的にメモリを1024MBへ拡張して調査環境を安定させ、DBのメタデータを直接操作・クリーンアップすることで不整合を解消しました。

学び: この経験を通じ、マイグレーション管理の重要性だけでなく、リソース制限下におけるデバッグ手法（リソースの一時拡張による切り分けなど）を実戦的に習得しました。また、AIを単なる生成ツールではなく「技術顧問」として活用。エラーログの解析や修正案に対して常に論理的な裏付けを確認しながら実装を進める姿勢が身につきました。

## 使用技術 (Tech Stack)
Backend: Ruby on Rails7.1 
Frontend: Hotwire (Turbo, Stimulus), Tailwind CSS, Chart.js
Database: PostgreSQL
Infrastructure: Fly.io
Others: PWA (Progressive Web Apps), Service Worker

## 今後の展望
ユーザーフィードバックの反映: 実際の利用サイクルに基づいたUI/UXの微細な調整。
モバイルアプリ展開: Web版の知見を活かした、App Store / Google Playへのリリース検討。
通知機能: 予測された「買い時」に合わせたプッシュ通知の実装。

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
- has_many :items
- has_many :categories


### items テーブル
### 買い物リスト本体です。定期購入フラグでAI学習対象を判別します。

| Column            | Type       | Options                        |
| ----------------- | ---------- | ------------------------------ |
| name              | string     | null: false                    |
| is_checked        | boolean    | null: false, default: false    |
| is_subscription   | boolean    | null: false, default: false    |
| category          | references | null: false, foreign_key: true |
| group             | references | null: false, foreign_key: true |
| last_bought_at    | datetime   |                                |
| cycle_days        | integer    | null: false, default: 0        |
| price             | integer    |                                |
| quantity          | integer    | null: false, default: 1        |

#### Association
- belongs_to :group
- belongs_to :category
- has_many :purchase_histories




### purchase_histories  テーブル
いつ、いくらで買ったかの記録です。カレンダー表示とAI予測の元データになります。

| Column        | Type       | Options                        |
| ------------- | ---------- | ------------------------------ |
| bought_at     | datetime   | null: false                    |
| price         | integer    |                                |
| item          | references | null: false, foreign_key: true |
| category      | references | null: false, foreign_key: true |
| group         | references | null: false, foreign_key: true |
| quantity      | integer    | null: false, default: 1        |

#### Association
- belongs_to :item
- belongs_to :category
- belongs_to :group


### categories テーブル
グループごとにカスタマイズ可能なカテゴリーです。

| Column                 | Type       | Options                        |
| ---------------------- | ---------- | ------------------------------ |
| name                   | string     | null: false                    |
| group                  | references | null: false, foreign_key: true |

#### Association  

- belongs_to :group
- has_many :item
- has_many :purchase_histories