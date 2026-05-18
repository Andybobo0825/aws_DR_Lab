# Failover Test Report

## 測試摘要

| 欄位 | 內容 |
| --- | --- |
| 測試日期 | TBD |
| 測試人員 | TBD |
| Primary region | ap-northeast-1 |
| DR region | ap-southeast-1 |
| 模式 | S3 + SNS + CRR + 手動 endpoint failover |
| 入口 | S3 website endpoint |
| SNS topic | TBD |

## 測試步驟

1. 確認 primary 與 DR endpoint 初始狀態。
2. 發送 SNS gameday start 通知。
3. 模擬 primary 不可用或宣告 primary 故障。
4. 切換入口到 DR endpoint。
5. 驗證首頁與錯誤頁可正常取得。
6. 比對 primary / DR content version、ETag 或 commit SHA。
7. 記錄 RTO / RPO。
8. 回切 primary。

## 結果

| 指標 | 目標 | 實測 | Pass/Fail |
| --- | --- | --- | --- |
| RTO | 10 分鐘 | TBD | TBD |
| RPO | CRR replication 延遲，分鐘級目標 | TBD | TBD |
| SNS 通知送達 | 是 | TBD | TBD |
| DR endpoint 可用性 | HTTP 200 | TBD | TBD |
| 回切成功 | 是 | TBD | TBD |

## 觀察與改善

- TBD

## 證據

```text
貼上 scripts/check-endpoints.sh 輸出、scripts/publish-gameday-event.sh 輸出、AWS CLI sync output、Terraform output、SNS subscription 截圖或 S3 replication 截圖連結。
```
