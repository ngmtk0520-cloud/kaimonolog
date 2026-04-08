require 'rails_helper'

RSpec.describe Item, type: :model do
  # --- 共通の準備（ここにあるものは全てのテストで使える） ---
  let(:group) { Group.create!(name: "テスト家族", invite_token: "abcdef123456") }
  let(:category) { Category.create!(name: "通常購入", group: group) }
  # itemを一番上の階層に置くことで、下のdescribeの中からも見えるようにする
  let(:item) { Item.create!(name: '牛乳', group: group, category: category, kind: :subscription, cycle_days: 10) }

  describe 'データ保存' do
    it 'カテゴリー、商品名、グループが有効であれば保存できる' do
      new_item = Item.new(name: '卵', group: group, category: category, kind: :regular)
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
    # ここに書いても良いですが、一番上に let(:item) があるので不要です

    context 'AI予測できる時' do
      it 'kindが定期購入（subscription）として正しく認識されること' do
        expect(item.subscription?).to be true
      end

      it '購入履歴が2回以上あり、予定日4日以内ならtrueを返す' do
        # 過去2回の購入でサイクルを学習させる
        item.purchase_histories.create!(group: group, category: category, bought_at: 20.days.ago.to_date)
        item.purchase_histories.create!(group: group, category: category, bought_at: 10.days.ago.to_date)
        item.update_average_cycle
        
        # 直近の購入が6日前（あと4日で予定日）
        item.purchase_histories.create!(group: group, category: category, bought_at: 6.days.ago.to_date)
        item.reload
        expect(item.due_soon?).to be true
      end
    end

    context 'AI予測できない時' do
      it 'kindが定期購入（subscription）でない場合は予測しない' do
        item.update(kind: :regular)
        item.purchase_histories.create!(group: group, category: category, bought_at: 6.days.ago.to_date)
        expect(item.due_soon?).to be false
      end

      it '購入履歴が1回しかない場合は予測判定できない' do
        item.purchase_histories.create!(group: group, category: category, bought_at: 1.day.ago.to_date)
        expect(item.due_soon?).to be false
      end

      it '予定日までまだ5日以上ある場合はfalseを返す' do
        item.purchase_histories.create!(group: group, category: category, bought_at: 5.days.ago.to_date)
        item.reload
        expect(item.due_soon?).to be false
      end
    end
  end
end