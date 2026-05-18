# Failover Test Report

## 測試摘要

| 欄位 | 內容 |
| --- | --- |
| 測試日期 | 2026-05-18 |
| 測試人員 | chentingwei |
| Primary region | ap-northeast-1 |
| DR region | ap-southeast-1 |
| 模式 | S3 + SNS + CRR + 手動 endpoint failover |
| 入口 | S3 website endpoint |
| Primary bucket | demo-s3-bucket-primary |
| DR bucket | demo-s3-dr-bucket |

## 測試步驟

1. 確認 primary 與 DR endpoint 初始狀態。
2. 發送 SNS gameday start 通知。
3. 透過 primary bucket public access block 模擬 primary website access failure。
4. 驗證 primary endpoint 變成 HTTP 403，DR endpoint 維持 HTTP 200。
5. 宣告手動 failover 到 DR endpoint。
6. 發送 SNS failover executed 通知。
7. 恢復 primary public access block。
8. 驗證 primary / DR endpoint 回復 HTTP 200。
9. 發送 SNS recovery completed 通知。
10. 記錄 RTO / RPO。

## 結果

| 指標 | 目標 | 實測 | Pass/Fail |
| --- | --- | --- | --- |
| RTO | 10 分鐘 | 1 分 13 秒 | PASS |
| RPO | CRR replication 延遲，分鐘級目標 | 0 observed data loss；DR 在 deploy/start 通知後 26 秒內確認可用 | PASS |
| SNS 通知送達 | 是 | deploy / failover / recovery 通知皆送達 | PASS |
| DR endpoint 可用性 | HTTP 200 | primary 403 時 DR 仍 HTTP 200 | PASS |
| 回切成功 | 是 | 17:01:02 primary / DR 皆 HTTP 200 | PASS |

## 觀察與改善

- 手動 endpoint failover 可在 10 分鐘 RTO 目標內完成。
- DR endpoint 在 primary 故障注入時已可用，顯示 CRR 與事前同步流程足以支撐本 Lab 的 RPO 目標。
- SNS 通知可作為演練時間線證據，適合放入作品集。
- 下次可補充 AWS CLI `head-object` 或 S3 Console object version 截圖，讓 RPO 證據更精準。

## 證據

| 證據 | 檔案 |
| --- | --- |
| Primary CRR / lifecycle | `docs/screenshots/2026-05-18-164456-s3-primary-crr-lifecycle.png` |
| Primary object version | `docs/screenshots/2026-05-18-164807-s3-primary-index-version.png` |
| Primary browser baseline | `docs/screenshots/2026-05-18-165134-primary-site-healthy-browser.png` |
| SNS deploy/start | `docs/screenshots/2026-05-18-165207-sns-deploy-start-email.png` |
| Baseline endpoints primary=200 / DR=200 | `docs/screenshots/2026-05-18-165233-endpoints-baseline-primary-dr-200.png` |
| Failure injection primary=403 / DR=200 | `docs/screenshots/2026-05-18-165540-primary-blocked-dr-200.png` |
| SNS failover executed | `docs/screenshots/2026-05-18-165653-sns-failover-executed-email.png` |
| Recovery endpoints primary=200 / DR=200 | `docs/screenshots/2026-05-18-170102-endpoints-recovery-primary-dr-200.png` |
| SNS recovery completed | `docs/screenshots/2026-05-18-170144-sns-recovery-completed-email.png` |
