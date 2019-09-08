# mikutter WebFinger プラグイン
[yuntan_t@mstdn.maud.io](https://mstdn.maud.io/@yuntan_t)みたいなアドレスから，ユーザーの情報を取得するプラグイン．

## インストール
```bash
curl -L https://github.com/yuntan/mikutter-webfinger/archive/master.tar.gz | tar -xz && mv mikutter-webfinger-master ~/.mikutter/plugin/webfinger
```

## つかいかた
QuickStepを開いて，検索したいアドレスを入力する．

![QuickStep](https://i.gyazo.com/0e66fd4a0dfe9a93d4d7ed12206f3cfe.png)

ユーザーの情報とタイムラインが表示される．

![modelviewer](https://i.gyazo.com/7e62aa3f6bfe28a61d766385ca8d2ad9.png)

## 動作を確認したActivityPub実装
- mastodon
- Pleroma
- Misskey
- writefreely

## TODO
- HTMLの処理
- タイムラインの抽出タブ対応
