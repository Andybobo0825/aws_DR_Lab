# 架構說明 — AWS DR Gameday Lab

## 目標

本專案用最低成本展示 AWS 災難復原設計，核心不是把架構做大，而是把 **備援思維、資料保護、切換流程** 說清楚。

## 架構總覽

- **Primary Region**：預設 `ap-northeast-1`
- **DR Region**：預設 `ap-southeast-1`
- **工作負載**：S3 靜態網站
- **主要資源**：
  - primary S3 bucket
  - DR S3 bucket
  - bucket versioning
  - lifecycle policy
  - optional CRR

## 設計原則

1. **低成本優先**
   - 不預設建立 NAT Gateway、ALB、CloudFront、RDS、SNS、Route 53。
   - 只有在明確需要演示時，才啟用額外元件。

2. **備援可展示**
   - Primary bucket 與 DR bucket 採相同命名規則與設定。
   - 透過 versioning 保留物件版本，降低誤刪風險。
   - 透過 lifecycle 控制歷史版本的成本。

3. **CRR 可選**
   - `enable_crr = false` 為預設。
   - 啟用 CRR 後，primary 會把物件複寫到 DR bucket。
   - 這讓作品集同時保留「最低成本」與「更強 DR 能力」兩種展示路線。

## 資料保護策略

- **Versioning**：保留歷史版本，支援回復。
- **Lifecycle**：清理過舊 noncurrent versions，避免 demo 成本無限制成長。
- **SSE-S3**：使用 S3 管理的加密，避免額外 KMS 成本。

## 切換思路

### 無 CRR

- 主站資料以手動同步為主。
- 測試時可用 `aws s3 sync` 或等效工具把內容從 primary 複製到 DR。
- RPO 取決於最後一次同步時間。

### 有 CRR

- primary bucket 變更會自動複寫到 DR bucket。
- 仍需用 Runbook 定義 DNS 或流量切換步驟。
- 適合展示更成熟的 DR 能力。

## 預設停用的擴充元件

- **Route 53 failover**：需域名與健康檢查，且會增加持續成本。
- **SNS**：可做通知，但不是最低成本核心。
- **RDS**：資料庫復原演練可作為後續擴充，不列入預設路徑。

## Terraform 主要設定點

- `infra/terraform-intake.md`
- `infra/providers.tf`
- `infra/variables.tf`
- `infra/main.tf`
- `infra/outputs.tf`

