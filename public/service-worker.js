self.addEventListener("install", (event) => {
  console.log("Service Worker installing.");
});

self.addEventListener("fetch", (event) => {
  // オフライン対応をする場合はここにキャッシュ処理を書きますが、
  // まずは空のまま「インストール可能」な状態にします。
});
