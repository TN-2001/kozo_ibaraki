# kozo_ibaraki

## Windows
- コンパイル：Visual Studioが必要（CMakeのバージョンが低いとエラーが出る）


- タイトル変更（windows\runner\main.cpp）
  if (!window.Create(L"MyApp", origin, size)) 

## Web
### リリース(Firebase)
1. Firebaseでプロジェクト作成
1. npm install -g firebase-tools
1. firebase login
1. firebase init
　（Hosting を選択
　　Use an existing project を選択し、作成したFirebaseプロジェクトを選択
　　public directory を build/web に設定
　　single-page app として設定）
1. flutter build web

1. 複数ページのとき
 firebase.jsonに以下を追加
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]

1. firebase deploy

### 更新(Firebase)
1. flutter build web
1. firebase deploy

## Android
### 初回
1. com.exampleを変更する（例：com.takahironakayama）

### 毎回
1. pubspec.yaml/version: 1.0.0+2（2を変更）
1. flutter build appbundle

## Flutter
### クリーン
1. flutter clean 
2. flutter pub get