# RTO / RPO — AWS DR Gameday Lab

## 定義

- **RTO (Recovery Time Objective)**：服務可以接受的最大恢復時間
- **RPO (Recovery Point Objective)**：服務可以接受的最大資料遺失量 / 資料時間差

## 本專案的預設目標

| 情境 | RTO | RPO | 說明 |
| --- | --- | --- | --- |
| 預設手動切換 | 15 分鐘內 | 最後一次手動同步點 | 最低成本、最容易展示 |
| 啟用 S3 CRR | 15 分鐘內 | 幾分鐘內（視 replication delay） | 更接近自動化 DR |
| 僅內容誤刪 / 誤改 | 10 分鐘內 | 近乎即時（視 version restore） | 透過 versioning 回復 |

## 目標設定原則

- **先清楚界定展示目的，再決定數字**
- 作品集版本以「可理解、可驗證、低成本」優先
- 若未啟用 Route 53 / SNS / RDS，RTO / RPO 只針對靜態網站與內容回復

## 驗證方式

- 以手動切換紀錄實際 RTO
- 以同步延遲或版本還原時間評估 RPO
- 每次演練後更新 `FAILOVER_TEST_REPORT.md`

## 建議調整時機

當你之後要把這個專案升級成更接近 production 的版本時，再重新調整：

- 入口層是否改成 Route 53 failover
- 是否需要 SNS 通知
- 是否加入資料層（例如 RDS）
- 是否需要更嚴格的 RPO 指標
