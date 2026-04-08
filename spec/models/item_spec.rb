require 'rails_helper'

RSpec.describe Item, type: :model do
  # --- 1. 全てのテストで使う共通データ ---
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }
  # 通常のカテゴリー
  let(:category) { Category.create!(name: "通常購入", group: group) }
  # 予測用の特別なカテゴリー
  let(:sub_category) { Category.create!(name: "定期購入", group: group) }

  describe 'データ保存' do
    it 'カテゴリー、商品名、グループが有効であれば保存できる' do
      new_item = Item.new(name: '卵', group: group, category: category)
      expect(new_item).to be_valid
    end

    context 'データが保存されない時' do
      it 'カテゴリーがなければ保存できない' do
        new_item = Item.new(name: '牛乳', group: group, category: nil)
        expect(new_item).to_not be_valid
      end

      it '商品名が入っていない場合は保存できない' do
        new_item = Item.new(name: nil, group: group, category: category)
        expect(new_item).to_not be_valid
      end

      it 'グループがなければ保存できない' do
        new_item = Item.new(name: '牛乳', group: nil, category: category)
        expect(new_item).to_not be_valid
      end
    end
  end

  describe 'AI予測機能' do
    # ここで AI予測用の item を作成（sub_category を使う）
    let(:item_for_ai) { Item.create!(name: '牛乳', group: group, category: sub_category) }

    context 'AI予測できる時' do
      it '定期購入（is_subscription）として正しく認識されること' do
        # モデルの before_save :set_subscription_flag が効いて true になるはず
        expect(item_for_ai.is_subscription?).to be true
      end

      it '購入履歴が2回以上あり、予定日4日以内ならtrueを返す' do
        # 履歴を登録
        item_for_ai.purchase_histories.create!(group: group, category: sub_category, bought_at: 20.days.ago.to_date)
        item_for_ai.purchase_histories.create!(group: group, category: sub_category, bought_at: 10.days.ago.to_date)
        
        # サイクルを計算 (10日間)
        item_for_ai.update_average_cycle
        
        # 6日前に購入（10日サイクルのうち6日経過 ＝ あと4日）
        item_for_ai.purchase_histories.create!(group: group, category: sub_category, bought_at: 6.days.ago.to_date)
        
        item_for_ai.reload
        expect(item_for_ai.due_soon?).to be true
      end
    end

    context 'AI予測できない時' do
      it '定期購入（is_subscription）でない場合は予測しない' do
        # 通常カテゴリーのアイテムを作る
        regular_item = Item.create!(name: 'お菓子', group: group, category: category)
        expect(regular_item.is_subscription?).to be false
        
        regular_item.purchase_histories.create!(group: group, category: category, bought_at: 6.days.ago.to_date)
        expect(regular_item.due_soon?).to be false
      end

      it '購入履歴が1回しかない場合は予測判定できない' do
        item_for_ai.purchase_histories.create!(group: group, category: sub_category, bought_at: 1.day.ago.to_date)
        expect(item_for_ai.due_soon?).to be false
      end

      it '予定日までまだ5日以上ある場合はfalseを返す' do
        item_for_ai.update(cycle_days: 10)
        item_for_ai.purchase_histories.create!(group: group, category: sub_category, bought_at: 5.days.ago.to_date)
        item_for_ai.reload
        expect(item_for_ai.due_soon?).to be false
      end
    end
  end
end