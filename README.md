# ヨットレース管理システム

このシステムは、ヨットレースの参加チームのGPS位置情報を追跡し、リアルタイムで可視化するためのシステムです。

## システム構成

- **バックエンド**: Supabase（PostgreSQL + RESTful API）
- **フロントエンド**: HTML/JavaScript（GPSデータ送信用）

## セットアップ手順

### 1. Supabaseプロジェクトの設定

1. Supabaseのウェブコンソール（https://app.supabase.com）にログインします。
2. プロジェクト「ylsoibodesucxrxofuir」を選択します。
3. SQLエディタを開き、以下のファイルを順番に実行します：
   - `yacht_race_db_setup.sql` - データベーススキーマとファンクションを作成
   - `yacht_race_test_data.sql` - テスト用データを挿入（オプション）

### 2. GPSデータ送信クライアントの設定

1. `gpss.html`ファイルを開きます。
2. Supabaseの設定が正しく設定されていることを確認します：
   ```javascript
   const SUPABASE_URL = 'https://ylsoibodesucxrxofuir.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlsc29pYm9kZXN1Y3hyeG9mdWlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE1MTA5MzAsImV4cCI6MjA1NzA4NjkzMH0.keB3IujuD-9-398opVDmChBETN0DhNy4u2iaQKdbGtU';
   ```

## 使用方法

### レース管理者向け

1. Supabaseのウェブコンソールにログインします。
2. SQLエディタまたはテーブルエディタを使用して、新しいレースとチームを登録します。
3. レース参加チームを登録し、生成されたUUIDとパスワードを各チームに配布します。

### レース参加者向け

1. GPSデータ送信用のURLを開きます：
   ```
   gpss.html?race=<UUID>&pwd=<PASSWORD>
   ```
   ※ `<UUID>` と `<PASSWORD>` は、レース管理者から提供された値に置き換えてください。

2. ブラウザの位置情報アクセスを許可します。
3. 「ここ」ボタンをクリックして、現在位置を記録します。
4. 設定した間隔で自動的にGPSデータが送信されます。

## データ分析

レースデータの分析には、`yacht_race_queries.sql`に含まれるクエリを使用できます：

1. 特定のレースの全参加チームの最新位置
2. 特定のチームの軌跡（時系列順）
3. 特定のレース内での各チームの平均速度
4. 特定の時間範囲内のGPSデータ
5. 各チームの総移動距離
6. GeoJSON形式のデータ出力（地図表示用）

## セキュリティ

- GPSデータの送信には、UUIDとパスワードによる認証が必要です。
- レースの有効期間外のデータは拒否されます。
- Row Level Security (RLS) により、認証されたユーザーのみがデータにアクセスできます。

## トラブルシューティング

- GPSデータが送信されない場合：
  - ブラウザの位置情報アクセスが許可されているか確認
  - UUIDとパスワードが正しいか確認
  - レースの有効期間内か確認
  - ネットワーク接続を確認

- オフライン時のデータ：
  - オフライン時のデータはローカルに保存され、オンラインに戻ったときに自動的に送信されます。

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
