-- ヨットレースデータ分析用クエリ集

-- 1. 特定のレースの全参加チームの最新位置
SELECT 
    r.name AS race_name,
    t.yacht_name,
    g.latitude,
    g.longitude,
    g.timestamp,
    g.speed,
    g.heading
FROM gps_data g
JOIN (
    -- 各参加者の最新のGPSデータを取得
    SELECT participant_id, MAX(timestamp) AS max_timestamp
    FROM gps_data
    GROUP BY participant_id
) latest ON g.participant_id = latest.participant_id AND g.timestamp = latest.max_timestamp
JOIN race_participants rp ON g.participant_id = rp.id
JOIN yacht_races r ON rp.race_id = r.id
JOIN race_teams t ON rp.team_id = t.id
WHERE r.id = 1  -- レースIDを指定
ORDER BY t.yacht_name;

-- 2. 特定のチームの軌跡（時系列順）
SELECT 
    g.latitude,
    g.longitude,
    g.timestamp,
    g.speed,
    g.heading
FROM gps_data g
JOIN race_participants rp ON g.participant_id = rp.id
WHERE rp.team_id = 1  -- チームIDを指定
ORDER BY g.timestamp;

-- 3. 特定のレース内での各チームの平均速度
SELECT 
    r.name AS race_name,
    t.yacht_name,
    AVG(g.speed) AS avg_speed,
    MAX(g.speed) AS max_speed,
    COUNT(g.id) AS data_points
FROM gps_data g
JOIN race_participants rp ON g.participant_id = rp.id
JOIN yacht_races r ON rp.race_id = r.id
JOIN race_teams t ON rp.team_id = t.id
WHERE r.id = 1  -- レースIDを指定
GROUP BY r.name, t.yacht_name
ORDER BY avg_speed DESC;

-- 4. 特定の時間範囲内のGPSデータ
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
WHERE g.timestamp BETWEEN '2023-07-01 10:00:00' AND '2023-07-01 12:00:00'  -- 時間範囲を指定
ORDER BY g.timestamp;

-- 5. 2点間の距離計算関数（ハーバーサイン公式）
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DOUBLE PRECISION,
    lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lon2 DOUBLE PRECISION
) RETURNS DOUBLE PRECISION AS $$
DECLARE
    R DOUBLE PRECISION := 6371000; -- 地球の半径（メートル）
    phi1 DOUBLE PRECISION;
    phi2 DOUBLE PRECISION;
    delta_phi DOUBLE PRECISION;
    delta_lambda DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
    distance DOUBLE PRECISION;
BEGIN
    -- 緯度経度をラジアンに変換
    phi1 := RADIANS(lat1);
    phi2 := RADIANS(lat2);
    delta_phi := RADIANS(lat2 - lat1);
    delta_lambda := RADIANS(lon2 - lon1);
    
    -- ハーバーサイン公式
    a := SIN(delta_phi/2) * SIN(delta_phi/2) +
         COS(phi1) * COS(phi2) *
         SIN(delta_lambda/2) * SIN(delta_lambda/2);
    c := 2 * ATAN2(SQRT(a), SQRT(1-a));
    distance := R * c;
    
    RETURN distance;
END;
$$ LANGUAGE plpgsql;

-- 6. 各チームの総移動距離を計算
WITH consecutive_points AS (
    SELECT 
        g.participant_id,
        g.latitude,
        g.longitude,
        g.timestamp,
        LAG(g.latitude) OVER (PARTITION BY g.participant_id ORDER BY g.timestamp) AS prev_lat,
        LAG(g.longitude) OVER (PARTITION BY g.participant_id ORDER BY g.timestamp) AS prev_lon
    FROM gps_data g
    JOIN race_participants rp ON g.participant_id = rp.id
    WHERE rp.race_id = 1  -- レースIDを指定
)
SELECT 
    r.name AS race_name,
    t.yacht_name,
    SUM(
        CASE 
            WHEN cp.prev_lat IS NULL THEN 0
            ELSE calculate_distance(cp.prev_lat, cp.prev_lon, cp.latitude, cp.longitude)
        END
    ) AS total_distance_meters
FROM consecutive_points cp
JOIN race_participants rp ON cp.participant_id = rp.id
JOIN yacht_races r ON rp.race_id = r.id
JOIN race_teams t ON rp.team_id = t.id
GROUP BY r.name, t.yacht_name
ORDER BY total_distance_meters DESC;

-- 7. レース参加者のGeoJSON形式のデータ出力（地図表示用）
SELECT jsonb_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(feature)
) AS geojson
FROM (
    SELECT jsonb_build_object(
        'type', 'Feature',
        'geometry', jsonb_build_object(
            'type', 'Point',
            'coordinates', jsonb_build_array(g.longitude, g.latitude)
        ),
        'properties', jsonb_build_object(
            'yacht_name', t.yacht_name,
            'timestamp', g.timestamp,
            'speed', g.speed,
            'heading', g.heading
        )
    ) AS feature
    FROM (
        -- 各参加者の最新のGPSデータを取得
        SELECT DISTINCT ON (g.participant_id)
            g.participant_id,
            g.latitude,
            g.longitude,
            g.timestamp,
            g.speed,
            g.heading
        FROM gps_data g
        JOIN race_participants rp ON g.participant_id = rp.id
        WHERE rp.race_id = 1  -- レースIDを指定
        ORDER BY g.participant_id, g.timestamp DESC
    ) g
    JOIN race_participants rp ON g.participant_id = rp.id
    JOIN race_teams t ON rp.team_id = t.id
) features; 