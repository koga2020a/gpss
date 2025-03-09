-- ヨットレース管理システムのテーブルとファンクション作成

-- ヨットレーステーブル
CREATE TABLE yacht_races (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    memo TEXT,
    json_data JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- レースチームテーブル
CREATE TABLE race_teams (
    id SERIAL PRIMARY KEY,
    representative_name TEXT NOT NULL,
    yacht_name TEXT NOT NULL,
    memo TEXT,
    json_data JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- レース参加チームテーブル
CREATE TABLE race_participants (
    id SERIAL PRIMARY KEY,
    race_id INTEGER NOT NULL REFERENCES yacht_races(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES race_teams(id) ON DELETE CASCADE,
    gps_uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    gps_password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(race_id, team_id)
);

-- GPSデータテーブル
CREATE TABLE gps_data (
    id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL REFERENCES race_participants(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    speed DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    altitude DOUBLE PRECISION,
    accuracy DOUBLE PRECISION,
    altitude_accuracy DOUBLE PRECISION,
    json_data JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックスの作成
CREATE INDEX idx_gps_data_participant_id ON gps_data(participant_id);
CREATE INDEX idx_gps_data_timestamp ON gps_data(timestamp);
CREATE INDEX idx_race_participants_race_id ON race_participants(race_id);
CREATE INDEX idx_race_participants_team_id ON race_participants(team_id);
CREATE INDEX idx_race_participants_gps_uuid ON race_participants(gps_uuid);

-- 更新日時を自動的に更新する関数とトリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 各テーブルに更新日時トリガーを設定
CREATE TRIGGER set_updated_at_yacht_races
BEFORE UPDATE ON yacht_races
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_race_teams
BEFORE UPDATE ON race_teams
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_race_participants
BEFORE UPDATE ON race_participants
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- GPSデータを登録するファンクション
CREATE OR REPLACE FUNCTION insert_race_tracking(
    p_race_uuid UUID,
    p_race_password TEXT,
    p_latitude DOUBLE PRECISION,
    p_longitude DOUBLE PRECISION,
    p_timestamp TIMESTAMP WITH TIME ZONE,
    p_speed DOUBLE PRECISION DEFAULT NULL,
    p_heading DOUBLE PRECISION DEFAULT NULL,
    p_altitude DOUBLE PRECISION DEFAULT NULL,
    p_accuracy DOUBLE PRECISION DEFAULT NULL,
    p_altitude_accuracy DOUBLE PRECISION DEFAULT NULL,
    p_json_data JSONB DEFAULT '{}'::JSONB
)
RETURNS JSONB AS $$
DECLARE
    v_participant_id INTEGER;
    v_race_id INTEGER;
    v_race_start_time TIMESTAMP WITH TIME ZONE;
    v_race_end_time TIMESTAMP WITH TIME ZONE;
    v_result JSONB;
BEGIN
    -- 参加者IDの取得と認証
    SELECT rp.id, rp.race_id INTO v_participant_id, v_race_id
    FROM race_participants rp
    WHERE rp.gps_uuid = p_race_uuid
    AND rp.gps_password = p_race_password;
    
    IF v_participant_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Invalid UUID or password'
        );
    END IF;
    
    -- レースの有効時間内かチェック
    SELECT start_time, end_time INTO v_race_start_time, v_race_end_time
    FROM yacht_races
    WHERE id = v_race_id;
    
    IF p_timestamp < v_race_start_time OR p_timestamp > v_race_end_time THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Timestamp is outside of race time window'
        );
    END IF;
    
    -- GPSデータを登録
    INSERT INTO gps_data (
        participant_id,
        latitude,
        longitude,
        timestamp,
        speed,
        heading,
        altitude,
        accuracy,
        altitude_accuracy,
        json_data
    ) VALUES (
        v_participant_id,
        p_latitude,
        p_longitude,
        p_timestamp,
        p_speed,
        p_heading,
        p_altitude,
        p_accuracy,
        p_altitude_accuracy,
        p_json_data
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'message', 'GPS data recorded successfully'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 匿名ユーザーにGPSデータ登録ファンクションの実行権限を付与
GRANT EXECUTE ON FUNCTION insert_race_tracking TO anon;

-- RLSポリシーの設定
ALTER TABLE yacht_races ENABLE ROW LEVEL SECURITY;
ALTER TABLE race_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE race_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE gps_data ENABLE ROW LEVEL SECURITY;

-- 認証済みユーザーのみがレースとチームを管理できるポリシー
CREATE POLICY yacht_races_auth_policy ON yacht_races
    FOR ALL
    TO authenticated
    USING (true);

CREATE POLICY race_teams_auth_policy ON race_teams
    FOR ALL
    TO authenticated
    USING (true);

CREATE POLICY race_participants_auth_policy ON race_participants
    FOR ALL
    TO authenticated
    USING (true);

-- GPSデータは認証済みユーザーが閲覧可能
CREATE POLICY gps_data_auth_read_policy ON gps_data
    FOR SELECT
    TO authenticated
    USING (true);

-- GPSデータの挿入はファンクション経由のみ許可
CREATE POLICY gps_data_insert_policy ON gps_data
    FOR INSERT
    TO anon
    WITH CHECK (false);  -- 直接挿入は禁止、ファンクション経由のみ 