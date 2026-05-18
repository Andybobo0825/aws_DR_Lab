# AWS DR Gameday Lab

這是一個低成本、可驗證的 AWS 災難復原（Disaster Recovery, DR）作品集專案。目標不是堆疊昂貴服務，而是用最小雲端資源展示 Cloud SA / DevOps 面試常問的可靠性設計：主站故障時怎麼切、RTO/RPO 怎麼定、演練結果如何留下證據。

## 專案亮點

- **Primary + DR 雙區域靜態網站**：Terraform 建立主站與備援 S3 Website bucket。
- **版本控管與生命週期**：S3 Versioning + lifecycle 清理舊版本，兼顧復原與成本。
- **可選 CRR**：S3 Cross-Region Replication 預設關閉，需要演練時再啟用。
- **可選 DNS / 通知**：Route 53 Failover 與 SNS 預設關閉，避免健康檢查與通知資源產生成本。
- **RDS 不預設建立**：RDS snapshot/restore 只在 Runbook 中保留擴充路徑，避免誤開資料庫費用。
- **中文文件完整**：架構、Runbook、RTO/RPO、Failover 測試報告都有可直接展示的模板。

## 目錄

```text
infra/                  Terraform：S3 primary/DR、versioning、lifecycle、optional CRR/Route53/SNS
docs/ARCHITECTURE.md    架構說明
docs/DR_RUNBOOK.md      DR 演練步驟
docs/RTO_RPO.md         RTO/RPO 設計
docs/FAILOVER_TEST_REPORT.md  演練紀錄模板
scripts/                本機輔助腳本，不會 terraform apply
```

## 快速開始（不套用雲端）

```bash
terraform -chdir=infra init -backend=false
terraform -chdir=infra fmt -recursive -check
terraform -chdir=infra validate
```


## 作品集截圖清單

建議在完成一次本地或 AWS demo 後，將以下截圖補到作品集頁面或本 README：

1. **Terraform 驗證截圖**：`./scripts/terraform-check.sh` 顯示 `Success! The configuration is valid.`
2. **Terraform Plan 截圖**：S3 Primary / DR bucket、versioning、lifecycle、optional CRR 狀態。
3. **S3 Bucket 截圖**：Primary 與 DR bucket 的 Versioning / Lifecycle 設定。
4. **網站端點截圖**：Primary endpoint 正常、DR endpoint 備援頁面正常。
5. **Failover 演練截圖**：`scripts/check-endpoints.sh` 在切換前/切換後的輸出。
6. **RTO/RPO 紀錄截圖**：`docs/FAILOVER_TEST_REPORT.md` 填寫完成後的演練結果。
7. **可選擴充截圖**：若啟用 Route 53 failover，再補 Hosted Zone records 與 Health Check 狀態。

## 建議 Demo 流程

1. 準備 `index.html` 與 `error.html`。
2. `terraform plan` 檢查 primary / DR bucket 與輸出 endpoint。
3. 若已建立資源，用 `scripts/sync-site.sh` 同步靜態檔到 primary 或 DR bucket。
4. 用 `scripts/check-endpoints.sh` 記錄主站與 DR endpoint 狀態。
5. 依 `docs/DR_RUNBOOK.md` 執行手動 failover 並填寫 `docs/FAILOVER_TEST_REPORT.md`。

> 本 repo 不會自動 apply cloud，也不包含任何 AWS credentials。
