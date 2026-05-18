# RTO / RPO 設計

## 定義

- **RTO（Recovery Time Objective）**：服務中斷後，可接受多久內恢復。
- **RPO（Recovery Point Objective）**：災難發生時，可接受遺失多久內的資料或更新。

## 本 Lab 目標

| 模式 | RTO 目標 | RPO 目標 | 說明 |
| --- | --- | --- | --- |
| 手動同步 + 手動切換 | 15 分鐘 | 上次成功同步時間 | 最低成本，適合 portfolio demo |
| CRR + 手動切換 | 10 分鐘 | S3 replication 延遲，通常以分鐘計 | 增加同步可靠性，但有額外成本 |
| CRR + Route 53 Failover | 5 分鐘 | S3 replication 延遲，通常以分鐘計 | 更接近半自動 DR，但 health check 付費 |

## 量測方式

1. 記錄故障宣告時間 `T0`。
2. 記錄使用者可從 DR endpoint 取得首頁的時間 `T1`。
3. RTO = `T1 - T0`。
4. 比對 primary 與 DR 的 object version 或發布 commit SHA，估算 RPO。

## 取捨

- 最低成本模式最容易清理，但 RPO 取決於人工同步紀律。
- CRR 可改善 RPO，但不是零延遲，也可能複製錯誤內容。
- Route 53 failover 可縮短切換時間，但需要 hosted zone 與 health check 成本。
- RDS snapshot/restore 適合下一階段演練；本 repo 預設不建立 RDS。
