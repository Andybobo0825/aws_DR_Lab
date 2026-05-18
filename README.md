# AWS DR Gameday Lab

一個以 **AWS 災難復原演練** 為主題的作品集專案，目標不是做複雜系統，而是用最小成本清楚展示：

- 主站與 DR 站的設計思維
- S3 靜態網站的版本控制與生命周期管理
- 跨區備援與可切換性
- RTO / RPO 的定義與驗證
- 可被面試官快速理解的 DR runbook 與演練紀錄

## 專案重點

- **主要架構**：兩個 AWS Region 的 S3 靜態網站 bucket
- **備援策略**：預設以手動或半自動切換為主
- **成本控制**：預設不啟用 Route 53 failover / SNS / RDS / CloudFront / NAT Gateway
- **資料保護**：bucket versioning、lifecycle、SSE-S3
- **可選擴充**：S3 CRR（預設關閉）

## 目前 Terraform 狀態

`infra/` 內已提供最小可用的 Terraform 骨架，重點如下：

- `infra/main.tf`：主站與 DR S3 bucket、versioning、lifecycle、可選 CRR
- `infra/providers.tf`：primary / DR 雙 provider
- `infra/variables.tf`：環境與成本參數
- `infra/outputs.tf`：bucket 名稱、endpoint、CRR 狀態
- `infra/terraform-intake.md`：Terraform 前置決策紀錄

## 文件索引

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/DR_RUNBOOK.md`](docs/DR_RUNBOOK.md)
- [`docs/RTO_RPO.md`](docs/RTO_RPO.md)
- [`docs/FAILOVER_TEST_REPORT.md`](docs/FAILOVER_TEST_REPORT.md)

## 常用腳本

- `scripts/terraform-check.sh`：格式化與 Terraform 靜態驗證
- `scripts/dr-checklist.sh`：印出 DR 演練與驗收清單

## 快速開始

1. 檢查 Terraform：

   ```bash
   ./scripts/terraform-check.sh
   ```

2. 規劃資源（不會實際 apply）：

   ```bash
   terraform -chdir=infra plan
   ```

3. 依照文件進行 DR 演練：

   - 先閱讀 `docs/DR_RUNBOOK.md`
   - 再參考 `docs/RTO_RPO.md`
   - 最後填寫 `docs/FAILOVER_TEST_REPORT.md`

## 預設停用的擴充項

以下能力是刻意保留為**預設停用**，避免增加成本與維運複雜度：

- Route 53 failover
- SNS 通知
- RDS / 資料庫層
- CloudFront
- NAT Gateway
- WAF

如果要把此 repo 升級成更接近 production 的 DR 架構，再逐步打開這些能力即可。
