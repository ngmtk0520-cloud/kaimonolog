class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [:update]

  protected

  # プロフィール更新時にニックネームの変更を許可する
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end

  # 更新した後に「設定画面」に戻るようにする
  def after_update_path_for(resource)
    settings_path # あなたの設定画面のパスに合わせてください
  end
end
