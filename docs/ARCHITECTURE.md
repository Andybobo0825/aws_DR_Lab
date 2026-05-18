# 架構說明

## 目標

用低成本資源模擬「主區域靜態網站故障，切換到 DR 區域」的災難復原流程，讓架構可以被部署、演練、量測與回顧。

本 Lab 聚焦 **S3 object / static website DR**，不是 RDS 資料庫 DR。S3 使用 CRR 跨區複製 object；RDS 則通常使用 snapshot restore、cross-region read replica 或 Aurora Global Database，成本與復原流程不同。

## 預設架構

```text
                 SNS Topic
                    ^
                    |  gameday notification / manual publish
                    |
使用者 / 面試展示
  |
  |  無網域：手動切換入口文件或直接開 DR endpoint
  |  有網域：可選 Route 53 Failover（預設關閉）
  v
Primary S3 Website bucket (ap-northeast-1)
  |
  |  S3 CRR（enable_crr=true by default）
  v
DR S3 Website bucket (ap-southeast-1)
```

## Terraform 預設建立的資源

- Primary S3 website bucket
- DR S3 website bucket
- S3 Versioning
- S3 lifecycle：清理 noncurrent object versions
- SSE-S3 encryption
- S3 CRR IAM role / policy / replication configuration
- Delete marker replication 預設關閉，降低 primary 誤刪同步到 DR 的風險
- SNS topic for gameday notification
- Optional SNS email subscription（設定 `notification_email` 時建立）
- Public access policy gate：`public_read_enabled=false` by default，實際展示 S3 website endpoint 時需明確改為 `true`

## 預設關閉的選項

| 功能 | 變數 | 預設 | 原因 |
| --- | --- | --- | --- |
| Route 53 Failover | `enable_route53_failover` | `false` | 你目前沒有網域；Health Check 也是付費資源 |
| RDS 還原演練 | `enable_rds_restore_demo` | `false` | 本 Lab 聚焦 S3 + SNS + CRR，不建立資料庫 |

## 故障模式

- Primary bucket content 被誤刪：使用 S3 Versioning 復原。
- Primary region/site 不可用：手動將入口切到 DR endpoint。
- 部署錯誤：用舊 object version rollback，或重新 sync 已知良好版本。
- 事件通知：用 SNS 發送 gameday 開始、failover、recover 等事件。

## 成本控制

- 沒有 EC2、NAT Gateway、RDS、WAF 或 CloudFront 預設資源。
- Lifecycle 自動清理舊版本。
- CRR 會產生跨區複製與 DR 儲存成本；demo 檔案保持小型。
- `force_destroy=true` 便於 demo 後清理；保留證據時可改為 `false`。
