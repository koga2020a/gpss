-- テスト用データの挿入

-- テスト用ヨットレース
INSERT INTO yacht_races (name, start_time, end_time, memo)
VALUES 
('テストレース1', NOW() - INTERVAL '1 day', NOW() + INTERVAL '2 days', 'テスト用レース1です'),
('テストレース2', NOW(), NOW() + INTERVAL '3 days', 'テスト用レース2です');

-- テスト用レースチーム
INSERT INTO race_teams (representative_name, yacht_name, memo)
VALUES 
('山田太郎', 'シーホーク', 'テストチーム1'),
('佐藤次郎', 'ウェーブランナー', 'テストチーム2'),
('鈴木三郎', 'オーシャンブリーズ', 'テストチーム3');

-- テスト用レース参加チーム
-- レース1に2チーム、レース2に1チーム参加
INSERT INTO race_participants (race_id, team_id, gps_password)
VALUES 
(1, 1, 'password1'),
(1, 2, 'password2'),
(2, 3, 'password3');

-- 参加チームのUUIDを取得して表示（実際のアプリで使用するため）
SELECT 
    r.name AS race_name, 
    t.yacht_name, 
    rp.gps_uuid, 
    rp.gps_password
FROM race_participants rp
JOIN yacht_races r ON rp.race_id = r.id
JOIN race_teams t ON rp.team_id = t.id;

-- テスト用GPSデータ（オプション）
-- 実際のアプリからデータを送信する前にテスト用のデータを入れる場合
INSERT INTO gps_data (participant_id, latitude, longitude, timestamp, speed, heading)
VALUES 
(1, 35.6895, 139.6917, NOW() - INTERVAL '30 minutes', 5.2, 120),
(1, 35.6897, 139.6920, NOW() - INTERVAL '20 minutes', 5.5, 125),
(2, 35.6890, 139.6915, NOW() - INTERVAL '25 minutes', 4.8, 110);

-- GPSデータの確認クエリ
SELECT 
    r.name AS race_name,
    t.yacht_name,
    g.latitude,
    g.longitude,
    g.timestamp,
    g.speed
FROM gps_data g
JOIN race_participants rp ON g.participant_id = rp.id
JOIN yacht_races r ON rp.race_id = r.id
JOIN race_teams t ON rp.team_id = t.id
ORDER BY g.timestamp DESC; 