# DR Runbook

## 前置條件

- Terraform 已建立 primary 與 DR S3 website buckets。
- `enable_crr=true`，CRR replication configuration 已建立。
- `enable_sns_notifications=true`，SNS topic 已建立。
- 若有設定 `notification_email`，email subscription 已在信箱中確認。
- 若使用公開 website endpoint，已確認 `public_read_enabled=true` 的風險並只放 demo content。
- 已記錄 Terraform outputs：primary endpoint、DR endpoint、bucket names、SNS topic ARN。

## 日常發布 / 同步策略

1. 每次發布後同步內容到 primary bucket。
2. 由 S3 CRR 自動複製到 DR bucket。
3. 記錄發布時間、commit SHA、primary object version / ETag。
4. 用 SNS 發送演練或發布通知。

```bash
scripts/sync-site.sh ./site primary
scripts/publish-gameday-event.sh "Deploy completed; waiting for CRR replication to DR bucket."
```

> CRR 只會複製啟用 replication 後的新物件或新版本；既有物件若要補複製，需要重新上傳或使用 S3 Batch Replication。

## 主站故障切換（無網域版）

1. 宣告事件開始時間 `T0`。
2. 發送 SNS 通知：

   ```bash
   scripts/publish-gameday-event.sh "Gameday started: primary endpoint degraded; preparing manual failover to DR endpoint."
   ```

3. 執行 health check：

   ```bash
   scripts/check-endpoints.sh
   ```

4. 若 primary 不可用，確認 DR endpoint 可用。
   - 演練 region/site outage 時，不要用刪除 primary object 來模擬；若要測誤刪，請走 versioning rollback 情境。
5. 將展示入口、文件連結、狀態頁或應用設定改指向 DR endpoint。
6. 記錄恢復時間 `T1`，RTO = `T1 - T0`。
7. 比對 DR content version / commit SHA，估算 RPO。
8. 在 `docs/FAILOVER_TEST_REPORT.md` 填入結果。

## 回切 Primary

1. 修復 primary content 或 region 問題。
2. 確認 primary endpoint 回復。
3. 若 DR 有更新，將已知良好版本同步回 primary。
4. 將入口從 DR 切回 primary。
5. 發送 SNS recover 通知。
6. 記錄回切時間與任何資料差異。

## 事故後檢討

- RTO 是否符合 10 分鐘目標？
- RPO 是否符合 CRR replication 延遲預期？
- SNS 通知是否有送達？
- 是否需要未來加入 Route 53 自動 failover？
- 是否真的需要資料庫 DR？若需要，應另外設計 RDS snapshot/read replica，而不是套用 S3 CRR 邏輯。
