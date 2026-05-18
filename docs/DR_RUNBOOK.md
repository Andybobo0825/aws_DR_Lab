# DR Runbook

## 前置條件

- Terraform 已建立 primary 與 DR S3 website buckets。
- 已準備可公開展示的靜態內容。
- 若使用公開 website endpoint，已確認 `public_read_enabled=true` 的風險並只放 demo content。
- 已記錄 Terraform outputs：primary endpoint、DR endpoint、bucket names。

## 日常備份 / 同步策略

### 最低成本模式（預設）

1. 每次發布後同步到 primary bucket。
2. 同步同一份內容到 DR bucket。
3. 記錄發布時間與 commit SHA。

```bash
scripts/sync-site.sh ./site primary
scripts/sync-site.sh ./site dr
```

### CRR 模式（選用）

1. 將 `enable_crr=true`。
2. 確認 replication IAM role 與 bucket versioning。
3. 發布到 primary 後觀察 DR bucket 是否完成複製。

## 主站故障切換

1. 宣告事件開始時間 `T0`。
2. 執行 health check：

   ```bash
   scripts/check-endpoints.sh
   ```

3. 若 primary 不可用，確認 DR endpoint 可用。
4. 入口切換：
   - 手動模式：把對外文件或 DNS CNAME 指到 DR endpoint。
   - Route 53 模式：確認 failover record 已切到 secondary。
5. 記錄恢復時間 `T1`，RTO = `T1 - T0`。
6. 檢查內容版本，估算 RPO。
7. 在 `docs/FAILOVER_TEST_REPORT.md` 填入結果。

## 回切 Primary

1. 修復 primary content 或 region 問題。
2. 用 `scripts/sync-site.sh` 將已知良好版本同步回 primary。
3. health check primary endpoint。
4. 將入口從 DR 切回 primary。
5. 記錄回切時間與任何資料差異。

## 事故後檢討

- RTO 是否符合目標？
- RPO 是否符合目標？
- 哪個步驟需要自動化？
- 是否需要啟用 CRR、Route 53 或 SNS？
