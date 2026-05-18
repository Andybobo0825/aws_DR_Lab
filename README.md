# AWS DR Gameday Lab

這是一個以 **S3 + SNS + CRR** 為核心的 AWS 災難復原（Disaster Recovery, DR）作品集專案。目標是用低成本、可驗證、可清除的雲端資源展示 Cloud SA / DevOps 面試常問的可靠性設計：主站故障時怎麼切、RTO/RPO 怎麼定、同步與通知怎麼設計、演練結果如何留下證據。

> 本 Lab **不需要 Route 53 或自有網域**。沒有網域時，failover 以 Primary S3 website endpoint 與 DR S3 website endpoint 的手動切換來展示。

## 專案亮點

- **Primary + DR 雙區域靜態網站**：Terraform 建立主站與備援 S3 Website bucket。
- **CRR 跨區複製**：S3 Cross-Region Replication 預設啟用，用來展示 RPO 降低；delete marker replication 預設關閉，避免誤刪立刻同步到 DR。
- **SNS 通知**：SNS Topic 預設建立；可填入 `notification_email` 建立 email subscription。
- **版本控管與生命週期**：S3 Versioning + lifecycle 清理舊版本，兼顧復原與成本。
- **無網域也能演練**：Route 53 Failover 保留為可選擴充，預設關閉。
- **RDS 不建立**：RDS snapshot/restore 與 S3 CRR 是不同 DR 模型，本 Lab 聚焦 S3 object/static site DR，避免資料庫成本。
- **中文文件完整**：架構、Runbook、RTO/RPO、Failover 測試報告都有可直接展示的模板。

## 目錄

```text
infra/                  Terraform：S3 primary/DR、versioning、lifecycle、CRR、SNS、optional Route53
docs/ARCHITECTURE.md    架構說明
docs/DR_RUNBOOK.md      DR 演練步驟
docs/RTO_RPO.md         RTO/RPO 設計
docs/FAILOVER_TEST_REPORT.md  演練紀錄模板
scripts/                本機與 AWS CLI 輔助腳本
```

## 快速檢查（不套用雲端）

```bash
./scripts/terraform-check.sh
```

成功時會看到 Terraform validate 成功，這張可以當作品集截圖。

## 作品集截圖清單

建議在完成一次本地或 AWS demo 後，將以下截圖補到作品集頁面或本 README：

1. **Terraform 驗證截圖**：`./scripts/terraform-check.sh` 顯示 `Success! The configuration is valid.`
2. **Terraform Plan 截圖**：Primary / DR S3 bucket、versioning、lifecycle、CRR、SNS topic。
3. **S3 Bucket 截圖**：Primary 與 DR bucket 的 Versioning / Lifecycle / Replication 設定。
4. **SNS 截圖**：SNS topic 與 email subscription confirmed 狀態（如果有設定 email）。
5. **網站端點截圖**：Primary endpoint 正常、DR endpoint 備援頁面正常。
6. **Failover 演練截圖**：`scripts/check-endpoints.sh` 在切換前/切換後的輸出。
7. **RTO/RPO 紀錄截圖**：`docs/FAILOVER_TEST_REPORT.md` 填寫完成後的演練結果。
8. **可選擴充截圖**：如果未來有網域並啟用 Route 53，再補 Hosted Zone records 與 Health Check 狀態。

## 實作步驟總覽

詳細指令請看本回覆下方或 `docs/DR_RUNBOOK.md`。核心流程是：

1. `./scripts/terraform-check.sh`
2. `./scripts/render-demo-site.sh ./site`
3. 複製 `examples/s3-sns-crr.tfvars.example` 的值，填入唯一 bucket 名稱與 email
4. `terraform -chdir=infra plan ...`
5. `terraform -chdir=infra apply ...`
6. 確認 SNS email subscription
7. `scripts/sync-site.sh ./site primary`
8. 等待 CRR 複製到 DR bucket，或用 AWS Console/CLI 驗證
9. `scripts/check-endpoints.sh`
10. 宣告 primary 故障，切到 DR endpoint，記錄 RTO/RPO
11. `terraform -chdir=infra destroy ...` 清除資源

## 成本與範圍

本 Lab 預設建立 S3、CRR 所需 IAM role、SNS topic。這些適合小型 demo，但不是免費；CRR 會產生跨區複製請求、資料傳輸與 DR bucket 儲存成本。請只放小型靜態檔案，演練完執行 destroy。

預設仍不建立：

- Route 53 / Health Check（因為你目前沒有網域，也會有額外成本）
- RDS / Aurora（資料庫 DR 與 S3 object DR 邏輯不同，文件中說明但不建立）
- NAT Gateway、EC2、CloudFront、WAF
