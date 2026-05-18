# AWS DR Gameday Lab

以 **AWS 災難復原（DR）演練** 為主題的作品集專案，目標是用最小成本展示：

- 主站與備援站的設計思維
- S3 靜態網站的版本控制與保留策略
- 跨區複寫（CRR）的可選啟用方式
- RTO / RPO 的定義與演練紀錄
- DR Runbook 與故障切換流程

## 專案定位

這個 repo 不追求 production-grade 的高成本架構，而是刻意保留成 **可 destroy、可複製、可展示** 的作品集範例。

### 預設原則

- **預設不啟用** Route 53 failover、SNS、RDS
- **預設不啟用** CloudFront、NAT Gateway、WAF、ALB
- 以 **S3 靜態網站 + 版本控制 + lifecycle** 為核心
- CRR 只在需要演示跨區同步時才打開

## 目前內容

- `infra/terraform-intake.md`：Terraform 規劃與假設
- `infra/*.tf`：S3 靜態網站與可選 CRR 的 Terraform
- `docs/ARCHITECTURE.md`：架構說明
- `docs/DR_RUNBOOK.md`：手動/半自動切換步驟
- `docs/RTO_RPO.md`：RTO / RPO 定義與預期值
- `docs/FAILOVER_TEST_REPORT.md`：故障切換測試報告模板
- `scripts/`：Terraform 驗證小工具

## 快速驗證

```bash
./scripts/terraform-fmt.sh
./scripts/terraform-validate.sh
```

> 本 repo 不會在這個階段執行 `terraform apply`。

## 作品集展示重點

1. 為什麼需要 DR，而不是只做單區部署
2. 為什麼把 CRR 設成可選，而不是預設開啟
3. 如何把 RTO / RPO 變成可說明、可驗證的文件
4. 如何在低成本前提下保留切換能力與演練空間

## 建議截圖

- Terraform plan 的資源清單
- primary / DR bucket 設定
- versioning / lifecycle / replication 設定
- DR Runbook 與 failover 測試紀錄

