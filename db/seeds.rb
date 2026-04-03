group = Group.find_or_create_by!(name: "長松家")

group.categories.find_or_create_by!(name: "通常購入")
group.categories.find_or_create_by!(name: "定期購入")
group.categories.find_or_create_by!(name: "スポット")