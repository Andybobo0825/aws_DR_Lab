# Failover Test Report

## 測試目的

驗證 AWS DR Gameday Lab 在 primary 故障或內容失效時，是否能按照 Runbook 完成切換與回復。

## 測試範圍

- S3 static website primary bucket
- S3 static website DR bucket
- versioning
- lifecycle
- optional CRR
- optional DNS / Route 53 failover（預設未啟用）

## 測試結果模板

| 欄位 | 內容 |
| --- | --- |
| 測試日期 | 待填 |
| 測試者 | 待填 |
| 測試模式 | 無 CRR / 有 CRR |
| 觸發事件 | 待填 |
| primary 狀態 | 待填 |
| DR 狀態 | 待填 |
| 切換方式 | 待填 |
| RTO | 待填 |
| RPO | 待填 |
| 結果 | PASS / FAIL |

## 建議驗證項目

- DR website endpoint 可打開。
- 切換後首頁內容正確。
- versioning 保留了可回復版本。
- lifecycle 不會過度清理最近版本。
- CRR 啟用時，DR bucket 能收到新版本。

## 待補證據

- Terraform plan 輸出截圖
- primary bucket 設定截圖
- DR bucket 設定截圖
- failover 切換截圖
- 演練時間紀錄

## 結論範例

> PASS：依照 DR Runbook 將內容切換到 DR site，網站在目標時間內恢復可用，RTO / RPO 均有紀錄。

