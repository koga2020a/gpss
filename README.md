# GPS速度voiceアプリ（gpss）

## 概要
このアプリケーションは、モバイルデバイスのGPS機能を使用して現在の移動速度を音声で発表するWebアプリです。主にボート、ヨット、その他の水上活動での使用を想定していますが、運転中や自転車での移動など、画面を見ることが難しい状況でも便利にお使いいただけます。

## 主な機能
- リアルタイムでの速度計測と表示（ノット単位）
- 設定可能な間隔での音声発表（10秒、30秒、50秒、120秒、240秒）
- 位置情報の保存機能（最大5地点）
- 保存地点からの距離と方位の表示
- 平均速度の計算と表示
- スムーズな速度表示（急激な変化を抑制）
- 完全オフライン対応

## 使用方法

### 基本操作
1. ブラウザでアプリを開く
2. 位置情報の使用を許可する
3. 画面中央の数字をタップすると、現在の速度を音声で発表
4. 「ここ」ボタンで現在地を保存（最大5地点）

### 音声発表間隔の設定
- 画面上部の秒数表示をタップして切り替え
- 設定可能な間隔：
  - ミュート（音声なし）
  - 10秒
  - 30秒（デフォルト）
  - 50秒
  - 120秒
  - 240秒

### 保存地点の管理
- 「ここ」ボタンで現在地を保存
- 保存地点には以下の情報が表示されます：
  - 保存時刻
  - 現在地からの距離
  - 方位（16方位）
  - 経過時間
  - 平均速度
- 「保存した地点」をタップすると履歴を削除可能

## 必要環境
- GPS機能搭載のモバイルデバイス（スマートフォン、タブレット）
- 以下のいずれかのモダンブラウザ：
  - iOS: Safari
  - Android: Chrome
  - その他: Firefox, Edge
- 位置情報の使用許可
- 音声出力機能

## プライバシーとセキュリティ
- 位置情報はすべてデバイス内でのみ処理
- 外部サーバーへのデータ送信なし
- 保存データはローカルストレージにのみ保存
- アプリを閉じても保存地点は維持（手動で削除可能）

## 技術仕様
- 使用技術：
  - HTML5
  - CSS3
  - JavaScript (ES6+)
- 使用API：
  - Geolocation API
  - Web Speech API
  - LocalStorage API
- 距離計算：Haversine公式（地球の曲率を考慮）
- 速度計算：
  - GPS速度値を優先使用
  - 位置の差分から計算（フォールバック）
  - 移動平均によるスムージング処理

## 制限事項
- GPS精度は使用デバイスに依存
- バックグラウンド動作時は端末の設定により動作が制限される場合あり
- 音声発表は端末の設定により制限される場合あり

## ライセンス
MIT License

## 開発者
[coo2020]

---
最終更新：2024年3月
```
