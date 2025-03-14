# GPS速度アプリ操作マニュアル

## 基本機能

### 速度表示
- 現在の速度がノット単位で大きく表示されます
- 速度表示をタップすると、現在の速度が音声で読み上げられます

### 音声アナウンス間隔
- 画面上部の数字は音声アナウンスの間隔を示しています
- タップするごとに「10秒」→「30秒」→「50秒」→「120秒」→「240秒」→「ミュート」→「10秒」の順に切り替わります
- 設定した間隔で自動的に速度が読み上げられます

### 位置保存
- 「ここ」ボタンをタップすると現在位置が保存されます
- 最大5箇所まで保存でき、古い位置情報は自動的に削除されます
- 保存した位置情報には以下の情報が表示されます：
  - 保存時刻
  - 現在地からの距離
  - 方位（北、南東など）と角度

### ダークモード切替
- 「保存した地点」のタイトルをタップするとダークモードと通常モードが切り替わります

## マップ機能

### マップの表示
- 保存した位置情報をタップするとマップが表示されます
- マップには以下の情報が表示されます：
  - 現在位置（青いマーカー）
  - 保存した位置（赤いマーカー）
  - 移動経路（灰色の線）
  - 速度に応じた色分け経路（青→緑→赤）

### マップの操作
- ピンチイン/アウト：ズームイン/アウト
- ドラッグ：マップの移動
- 右上の「×」ボタン：マップを閉じる

### 速度表示モード
- 左上の「衛星」/「速度」ボタン：地図タイプの切り替え
- 右下の速度凡例：タップすると速度フィルターが切り替わります
  - 「速度（ノット）」：すべての速度を表示
  - 「0-3ノット」：低速のみ表示
  - 「3-6ノット」：中速のみ表示
  - 「6+ノット」：高速のみ表示

### 追跡モード
- 右下の「📍」ボタン：タップすると現在位置を中心に表示するモードになります
- 再度タップすると通常モードに戻ります

### マーカー操作モード
- 左下の情報パネルをタップすると「マーカーのみ移動可能モード」に切り替わります
- このモードでは：
  - マップのスクロールやズームができなくなります
  - 赤いマーカーが点滅し、移動可能になります
  - マーカーは経路上にスナップします
  - マーカーの位置に応じた速度情報が表示されます
- 再度情報パネルをタップすると通常モードに戻ります

### 経路クリック機能
- 経路上の任意の点をクリックすると、マーカーがその位置に移動します
- マーカーは常に最も近い経路上にスナップします
- マーカーの位置に応じた速度情報が左下の情報パネルに表示されます

## 高度な機能

### 詳細な経路表示
- アプリは定期的に詳細な位置情報を記録し、より細かい経路を表示します
- 詳細経路は細い線で表示され、速度に応じた色で表示されます

### 速度フィルター時のアニメーション
- 特定の速度範囲をフィルター表示すると、該当する経路が点滅表示されます
- これにより、特定の速度での航行区間を視覚的に確認できます

### レース追跡機能
- URLパラメータでレースIDとパスワードを指定すると、位置情報がサーバーに送信されます
- オフライン時にも位置情報を記録し、オンラインに復帰した際に自動的に送信します

### 保存位置の削除
- 保存した位置情報を右から左にスワイプすると削除できます
