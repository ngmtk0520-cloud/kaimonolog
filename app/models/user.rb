class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :group, optional: true
  after_destroy :destroy_empty_group

  has_many :purchase_histories

  validates :nickname, presence: true

  private

  def destroy_empty_group
    # ユーザーが所属していたグループを取得
    return if group.nil?
    
    # そのグループに所属しているユーザーが0人になったら、グループを削除
    if group.users.count == 0
      group.destroy
    end
  end
end
