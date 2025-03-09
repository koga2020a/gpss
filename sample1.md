```mermaid
gantt
    title SFTP処理の時間遷移（セッション競合問題）
    dateFormat X

    section アップロード処理
    sftp.uploadDir()           : a1, 0, 6
    処理開始                   : a2, 0, 2
    処理進行中                 : a3, 2, 3
    処理完了                   : done, a4, 5, 1
    SFTPセッション状態 (使用中) : active, a5, 0, 6

    section 終了処理 (問題発生)
    sftp.end() (finally内)     : b1, 3, 2
    処理開始                   : b2, 3, 1
    エラー: セッション使用中    : crit, b3, 4, 0.5
    処理終了 (例外で終了)       : done, b4, 4.5, 0.5

    section 問題の説明
    セッション競合             : milestone, m1, 4, 0
    競合: 使用中に終了要求    : crit, m2, 4, 1
```
create table gps_data (
  id uuid primary key default gen_random_uuid(),
  race_entry_id uuid references race_entries(id) on delete cascade,
  latitude numeric(9,6) not null,
  longitude numeric(9,6) not null,
  speed numeric(6,2),
  gps_timestamp timestamptz not null,
  jsondata jsonb,
  created_at timestamptz default now()
);