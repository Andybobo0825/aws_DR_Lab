# 架構說明

## 目標

用低成本資源模擬「主區域靜態網站故障，切換到 DR 區域」的災難復原流程，讓架構可以被部署、演練、量測與回顧。

## 預設架構

```text
使用者
  |
  |  手動切換或選用 Route 53 Failover（預設關閉）
  v
Primary S3 Website bucket (ap-northeast-1)
  |
  |  optional S3 CRR（enable_crr=false by default）
  v
DR S3 Website bucket (ap-southeast-1)
```

## Terraform 建立的預設資源

- Primary S3 website bucket
- DR S3 website bucket
- S3 Versioning
- S3 lifecycle：清理 noncurrent object versions
- SSE-S3 encryption
- Public access policy gate：`public_read_enabled=false` by default

## 預設關閉的選項

| 功能 | 變數 | 預設 | 原因 |
| --- | --- | --- | --- |
| S3 CRR | `enable_crr` | `false` | 避免額外 replication/storage 成本 |
| Route 53 Failover | `enable_route53_failover` | `false` | Health check 是付費資源，且需要 hosted zone |
| SNS 通知 | `enable_sns_notifications` | `false` | Demo 預設不建立通知資源 |
| RDS 還原演練 | `enable_rds_restore_demo` | `false` | 最小成本 lab 不建立資料庫 |

## 故障模式

- Primary bucket content 被誤刪：使用 S3 Versioning 復原。
- Primary region/site 不可用：手動將入口切到 DR endpoint，或啟用 Route 53 failover。
- 部署錯誤：用舊 object version rollback，或重新 sync 已知良好版本。

## 成本控制

- 沒有 EC2、NAT Gateway、RDS、WAF 或 CloudFront 預設資源。
- Lifecycle 自動清理舊版本。
- `force_destroy=true` 便於 demo 後清理；保留證據時可改為 `false`。
