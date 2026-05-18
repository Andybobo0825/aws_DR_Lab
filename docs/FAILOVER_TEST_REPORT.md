# Failover Test Report

## 測試摘要

| 欄位 | 內容 |
| --- | --- |
| 測試日期 | TBD |
| 測試人員 | TBD |
| Primary region | ap-northeast-1 |
| DR region | ap-southeast-1 |
| 模式 | 手動同步 / CRR / Route 53 Failover |
| 入口 | S3 website endpoint / DNS |

## 測試步驟

1. 確認 primary 與 DR endpoint 初始狀態。
2. 模擬 primary 不可用或宣告 primary 故障。
3. 切換入口到 DR endpoint。
4. 驗證首頁與錯誤頁可正常取得。
5. 記錄 RTO / RPO。
6. 回切 primary。

## 結果

| 指標 | 目標 | 實測 | Pass/Fail |
| --- | --- | --- | --- |
| RTO | 15 分鐘 | TBD | TBD |
| RPO | 上次同步時間 | TBD | TBD |
| DR endpoint 可用性 | HTTP 200 | TBD | TBD |
| 回切成功 | 是 | TBD | TBD |

## 觀察與改善

- TBD

## 證據

```text
貼上 scripts/check-endpoints.sh 輸出、AWS CLI sync output、Terraform output 或截圖連結。
```
