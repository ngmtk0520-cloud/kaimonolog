require 'rails_helper'

RSpec.describe "MainFlow", type: :system do
  before do
    driven_by(:selenium_chrome) # ブラウザの動きを目視！
  end

  let(:user) { { nickname: "テストユーザー", email: "test@example.com", password: "password" } }

  it "新規登録からログアウトまでのメインストーリーを完走する" do
    # 1. ユーザー登録
    visit new_user_registration_path
    fill_in "user_nickname", with: user[:nickname]
    fill_in "user_email", with: user[:email]
    fill_in "user_password", with: user[:password]
    fill_in "user_password_confirmation", with: user[:password]
    click_button "登録"

    # 2. ログイン後の確認（ここがエラーの場所でした！修正済み）
    expect(page).to have_content "こんにちは、#{user[:nickname]} さん！", wait: 10

    # 3. グループ作成（withinで確実に上のフォームを狙う）
    within(find('.group-card', text: '新しくグループを作る')) do
      fill_in "group_name", with: "テストグループ"
      click_button "作成する"
    end

    # 4. グループ作成成功の確認
    expect(page).to have_content "所属：テストグループ", wait: 10

    # 5. アイテム一覧へ移動
    click_link "🛒 買い物リストを見る"
    
    # 6. カテゴリー追加（今日こだわった動線）
    within(".category-add-area") do
      fill_in "category_name", with: "飲料" 
      click_button "追加"
    end
    
    # items_path に戻ることを確認
    expect(current_path).to eq items_path
    expect(page).to have_content "飲料"

     # 3. 買い物リスト追加
    within("#item_form") do # ←実際のHTMLのクラス名に合わせて変えてください
      fill_in "商品名を入力", with: "牛乳"
      click_button "追加"
    end

    # 4. 購入完了チェック
    # ここも金額入力エリアの中に「追加」ボタンがあるなら、同様に囲みます
    item = Item.find_by(name: "牛乳")

    within("#item_#{item.id}") do
      fill_in "price_input_#{item.id}", with: "200"
      fill_in "quantity_input_#{item.id}", with: "3"
      
      # チェックを入れる
      find('input[type="checkbox"]').check 
    end

    # 💡 ここがポイント：
    # 画面が非同期(Turbo)で書き換わるのを待つために wait を入れる
    # また、いきなり (¥200 × 3) を探すのではなく、
    # 「購入を記録しました」などのフラッシュメッセージが出るならそれを先に待つのも有効です。
    expect(page).to have_content("(¥200 × 3)", wait: 10)

    # 5. カレンダー画面の確認（購入したものが反映されているか）
    # 5. カレンダー画面の確認
    visit calendars_path

    # 💡 データがある日（active）をクリック
    find(".purchase_history.active").click

    # 💡 詳細画面での確認
    # ビューの <h2> に日付が表示されているはずなので、念のため確認
    expect(page).to have_content Date.current.strftime("%Y年%m月%d日")

    # 商品名 (item_name) が表示されているか
    expect(page).to have_content "牛乳"

    # 金額と個数の表示を確認
    # number_with_delimiter(200) => "200"
    expect(page).to have_content "200円"
    expect(page).to have_content "(× 3)"

    # 合計金額 (@total_price) 600円 が表示されているか
    within(".total-price-section") do
      expect(page).to have_content "600円"
    end

    # 5-2 支出表反映
    visit total_expenses_path
    expect(page).to have_content "今月の支出割合"
    expect(page).to have_content "月別支出推移"

    # グラフが描画される要素（canvas）が存在することを確認
    expect(page).to have_css "canvas", count: 2

    # 6. 設定：グループ名編集
    visit settings_path

    # 「グループ」セクションの「編集」リンクをクラス名でクリック
    find(".group-edit-link").click

    # 編集画面に遷移したあと
    fill_in "グループ名", with: "最強チーム" # ここは実際の編集フォームのラベルに合わせてください
    click_button "更新する" # ここも「更新」など実際のボタン名に合わせてください

    # 設定画面に戻って、名前が変わっているか確認
    expect(page).to have_content "最強チーム"

    # 6-2. プロフィール編集
    visit settings_path
    find(".profile-edit-link").click
    fill_in "ニックネーム", with: "新しいニックネーム"
    fill_in "現在のパスワード", with: user[:password]
    click_button "変更を保存する"
    expect(page).to have_content "新しいニックネーム"

    # 6-3. カテゴリー編集
    visit settings_path
    find(".content-edit-link").click

    # 💡 「飲料」というテキストを持つ div を探し、その「兄弟」または「子」にあるリンクをクリック
    # match: :first をつけることで、もし複数あっても最初の一つを叩きます
    find('div', text: '飲料', exact_text: true).sibling('div').click_link('編集')

    # 💡 カテゴリー編集画面（edit）での操作
    fill_in "カテゴリー名", with: "飲み物"
    click_button "更新する"

    # 💡 更新後の確認（一覧画面に戻る想定）
    expect(page).to have_content "飲み物"

    # 7. ログアウト
    visit settings_path

    accept_confirm do
      # クラス名で指定し、クリックを確実に実行
      find(".logout-link").click
    end

    # 💡 ここがポイント：遷移を待つために、パスの確認の前に「画面上の変化」を確認する
    expect(page).to have_content "ログイン" # または「新規登録」など、ログアウト後に出る文字
    expect(current_path).to eq root_path
  end
end