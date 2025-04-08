# kozo_ibaraki


## 環境構築
- [windows](https://qiita.com/shimizu-m1127/items/d8dfc2179bc01baaef6b)


## GitHub
- [クローン(ダウンロード)](https://webcreatorfile.com/web/git/869/)


## Flutter
### クリーン
1. ```flutter clean```
2. ```flutter pub get```


## Windowsビルド
- [開発者モード：オン](https://zenn.dev/nukokoi/articles/5f108b0b66e639)

- タイトル変更：windows\runner\main.cppの修正
    ```
  if (!window.Create(L"MyApp", origin, size)) 
    ```


## Webビルド
### リリース(Firebase)
1. Firebaseでプロジェクト作成
1. ```npm install -g firebase-tools```
1. ```firebase login```
1. ```firebase init```
    1. Hosting を選択
    1. Use an existing project を選択し、作成したFirebaseプロジェクトを選択
    1. public directory を build/web に設定
    1. single-page app として設定
1. ```flutter build web```

1. 複数ページのとき：firebase.jsonに以下を追加
    ```
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
    ```

1. ```firebase deploy```

### 更新(Firebase)
1. ```flutter build web```
1. ```firebase deploy```


## Androidビルド
### 初回
1. com.exampleを変更する（例：com.takahironakayama）


### 毎回
1. バージョン更新：pubspec.yamlの編集
    ```
    version: 1.0.0+2（2を変更）
    ```
1. ```flutter build appbundle```