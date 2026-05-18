# RTO / RPO 設計

## 定義

- **RTO（Recovery Time Objective）**：服務中斷後，可接受多久內恢復。
- **RPO（Recovery Point Objective）**：災難發生時，可接受遺失多久內的資料或更新。

## 本 Lab 目標

| 模式 | RTO 目標 | RPO 目標 | 說明 |
| --- | --- | --- | --- |
| S3 + CRR + SNS + 手動切換 | 10 分鐘 | S3 replication 延遲，通常以分鐘計 | 不需要網域；用 DR endpoint 完成演練 |
| S3 + CRR + SNS + Route 53 Failover | 5 分鐘 | S3 replication 延遲，通常以分鐘計 | 未來有網域時才啟用 |

## 量測方式

1. 記錄故障宣告時間 `T0`。
2. 發送 SNS gameday/failover 通知。
3. 記錄使用者可從 DR endpoint 取得首頁的時間 `T1`。
4. RTO = `T1 - T0`。
5. 比對 primary 與 DR 的 object version、ETag 或發布 commit SHA，估算 RPO。

## S3 CRR 與 RDS DR 的差異

- S3 CRR：object 層級複製，適合靜態檔案、圖片、前端 build artifact。
- RDS Snapshot：備份點還原，RTO 通常較長，RPO 取決於最後 snapshot 時間。
- RDS Read Replica / Aurora Global Database：更接近即時，但需要持續運行資料庫資源，成本較高。

本作品集 Lab 會說明 RDS 差異，但 IaC 不建立 RDS，避免把低成本 DR Lab 變成資料庫維運專案。
