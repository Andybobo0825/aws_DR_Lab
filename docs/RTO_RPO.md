# RTO / RPO 設計與實測結果

## 定義

- **RTO（Recovery Time Objective）**：服務中斷後，可接受多久內恢復。
- **RPO（Recovery Point Objective）**：災難發生時，可接受遺失多久內的資料或更新。

## 本 Lab 目標

| 模式 | RTO 目標 | RPO 目標 | 說明 |
| --- | --- | --- | --- |
| S3 + CRR + SNS + 手動 endpoint failover | 10 分鐘 | S3 replication 延遲，分鐘級 | 用 DR endpoint 完成演練 |

## 實測時間線

| 時間 | 事件 | 證據 |
| --- | --- | --- |
| 16:44:56 | Primary bucket lifecycle 與 CRR replication rule 已啟用 | `docs/screenshots/2026-05-18-164456-s3-primary-crr-lifecycle.png` |
| 16:48:07 | Primary `index.html` 有目前版本紀錄 | `docs/screenshots/2026-05-18-164807-s3-primary-index-version.png` |
| 16:51:34 | Primary site browser baseline 正常 | `docs/screenshots/2026-05-18-165134-primary-site-healthy-browser.png` |
| 16:52:07 | SNS 發出演練開始 / deploy notification | `docs/screenshots/2026-05-18-165207-sns-deploy-start-email.png` |
| 16:52:33 | Baseline endpoint check：primary=200、DR=200 | `docs/screenshots/2026-05-18-165233-endpoints-baseline-primary-dr-200.png` |
| 16:55:40 | 故障注入後 endpoint check：primary=403、DR=200 | `docs/screenshots/2026-05-18-165540-primary-blocked-dr-200.png` |
| 16:56:53 | SNS 發出 failover executed notification | `docs/screenshots/2026-05-18-165653-sns-failover-executed-email.png` |
| 17:01:02 | Recovery endpoint check：primary=200、DR=200 | `docs/screenshots/2026-05-18-170102-endpoints-recovery-primary-dr-200.png` |
| 17:01:44 | SNS 發出 recovery completed notification | `docs/screenshots/2026-05-18-170144-sns-recovery-completed-email.png` |

## RTO 實測

- `T0`：16:55:40，primary endpoint 變成 HTTP 403，DR endpoint 仍為 HTTP 200。
- `T1`：16:56:53，SNS failover executed 通知送達，代表操作上已宣告切換到 DR endpoint。
- **RTO = 1 分 13 秒**。

補充：技術上 DR endpoint 在 `T0` 已可用；本報告採用較保守的「完成 failover 宣告」時間作為 `T1`。

## RPO 實測

- 16:52:07 發出 deploy/start 通知。
- 16:52:33 endpoint check 已確認 DR endpoint HTTP 200。
- 從通知到 DR 可用確認的觀測時間為 **26 秒**。
- 故障發生時，DR endpoint 仍提供可用網站內容，因此本次演練結果為 **0 observed data loss**。

## 結論

| 指標 | 目標 | 實測 | 結果 |
| --- | --- | --- | --- |
| RTO | 10 分鐘內 | 1 分 13 秒 | PASS |
| RPO | 分鐘級 | 0 observed data loss；DR 在 26 秒內確認可用 | PASS |
