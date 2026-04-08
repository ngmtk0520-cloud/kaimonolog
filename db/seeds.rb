group = Group.find_or_initialize_by(name: "長松家")
if group.new_record?
  # 重複しないトークンを生成するまで繰り返す（より安全な書き方）
  group.invite_token = loop do
    token = SecureRandom.hex(6)
    break token unless Group.exists?(invite_token: token)
  end
  group.save!
end