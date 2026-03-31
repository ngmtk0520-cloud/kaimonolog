require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー新規登録' do
    context '新規登録ができる場合' do
      it 'nicknameとemail、passwordが存在すれば登録できる' do
        user = User.new(
          nickname: 'テストユーザー',
          email: 'test@example.com',
          password: 'password',
          password_confirmation: 'password'
        )
        expect(user).to be_valid
      end
    end

    context '新規登録ができない場合' do
      it 'nicknameが空では登録できない' do
        user = User.new(nickname: '', email: 'test@example.com', password: 'password')
        user.valid?
        expect(user.errors[:nickname]).to include("can't be blank")
      end

      it 'emailが空では登録できない' do
        user = User.new(nickname: 'テスト', email: '', password: 'password')
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
      end
    end
  end
end