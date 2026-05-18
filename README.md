# AWS DR Gameday Lab

這是一個以 **S3 + SNS + CRR** 為核心的 AWS 災難復原（Disaster Recovery, DR）作品集專案。目標是用低成本、可驗證、可清除的雲端資源展示 Cloud SA / DevOps 面試常問的可靠性設計：主站故障時怎麼切、RTO/RPO 怎麼定、演練結果如何留下證據。

本 Lab 不需要自有網域；演練時以 **Primary S3 website endpoint** 與 **DR S3 website endpoint** 完成手動 failover。

## 專案亮點

- **Primary + DR 雙區域靜態網站**：Terraform 建立主站與備援 S3 Website bucket。
- **CRR 跨區複製**：S3 Cross-Region Replication 預設啟用，用來展示 RPO 降低；delete marker replication 預設關閉，避免誤刪立刻同步到 DR。
- **SNS 通知**：SNS Topic 預設建立；可填入 `notification_email` 建立 email subscription。
- **版本控管與生命週期**：S3 Versioning + lifecycle 清理舊版本，兼顧復原與成本。
- **中文文件完整**：架構、Runbook、RTO/RPO、Failover 測試報告都有可直接展示的模板。

## 目錄

```text
infra/                  Terraform：S3 primary/DR、versioning、lifecycle、CRR、SNS
docs/ARCHITECTURE.md    架構說明
docs/DR_RUNBOOK.md      DR 演練步驟
docs/RTO_RPO.md         RTO/RPO 設計與實測結果
docs/FAILOVER_TEST_REPORT.md  演練紀錄
docs/screenshots/       演練截圖證據
scripts/                本機與 AWS CLI 輔助腳本
```

## 演練結果摘要

| 指標 | 目標 | 實測 | 結果 |
| --- | --- | --- | --- |
| RTO | 10 分鐘內 | 1 分 13 秒 | PASS |
| RPO | 分鐘級 | 0 observed data loss；DR 在部署通知後 26 秒內確認可用 | PASS |
| SNS 通知 | 送達 | deploy / failover / recovery 三封通知皆有截圖 | PASS |
| DR endpoint | HTTP 200 | primary 403 時 DR 仍為 HTTP 200 | PASS |
| Recovery | primary 回復 HTTP 200 | 17:01:02 primary / DR 皆為 HTTP 200 | PASS |

## 演練證據截圖

### 1. S3 CRR 與 lifecycle 已啟用

![Primary S3 CRR lifecycle](docs/screenshots/2026-05-18-164456-s3-primary-crr-lifecycle.png)

### 2. Primary 物件版本紀錄

![Primary index version](docs/screenshots/2026-05-18-164807-s3-primary-index-version.png)

### 3. DR bucket lifecycle 狀態

![DR bucket lifecycle](docs/screenshots/2026-05-18-164842-s3-dr-lifecycle-no-outbound-replication.png)

### 4. Primary site baseline 正常

![Primary site healthy](docs/screenshots/2026-05-18-165134-primary-site-healthy-browser.png)

### 5. SNS deploy/start 通知

![SNS deploy start email](docs/screenshots/2026-05-18-165207-sns-deploy-start-email.png)

### 6. Baseline endpoints：primary / DR 皆 HTTP 200

![Baseline endpoint check](docs/screenshots/2026-05-18-165233-endpoints-baseline-primary-dr-200.png)

### 7. 故障注入：primary 403，DR 仍 HTTP 200

![Primary blocked and DR healthy](docs/screenshots/2026-05-18-165540-primary-blocked-dr-200.png)

### 8. SNS failover 通知

![SNS failover email](docs/screenshots/2026-05-18-165653-sns-failover-executed-email.png)

### 9. Recovery endpoint check：primary / DR 回復 HTTP 200

![Recovery endpoint check](docs/screenshots/2026-05-18-170102-endpoints-recovery-primary-dr-200.png)

### 10. SNS recovery 通知

![SNS recovery email](docs/screenshots/2026-05-18-170144-sns-recovery-completed-email.png)

## 成本與清理

本 Lab 使用 S3 bucket、CRR 所需 IAM role、SNS topic 與少量靜態檔案。CRR 會產生跨區複製請求、資料傳輸與 DR bucket 儲存成本；請只放小型 demo 檔案，演練完執行：

```bash
terraform -chdir=infra destroy
```
