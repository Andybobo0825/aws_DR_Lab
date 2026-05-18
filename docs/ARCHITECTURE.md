# Architecture — AWS DR Gameday Lab

## 設計目標

這個作品集的重點是用**最低成本**呈現 AWS DR 的核心能力：

- 主站與備援站的概念分離
- 靜態網站資料的保護與回復
- 以文件化方式描述 RTO / RPO 與切換流程
- 讓面試官可以快速看懂「如果 Region 壞掉怎麼辦」

## 預設架構

```text
User
  -> S3 static website (primary)
  -> S3 static website (DR)
```

### 核心元件

- **Primary S3 bucket**：主站靜態網站 bucket
- **DR S3 bucket**：跨區備援 bucket
- **Versioning**：保留歷史版本，方便回復
- **Lifecycle**：控制 noncurrent versions 成本
- **SSE-S3**：啟用 AWS 管理金鑰加密
- **Optional CRR**：預設關閉，僅在需要近即時複寫時打開

## 預設停用的擴充

這些能力在這個版本中**不啟用**，只保留為未來升級路徑：

- Route 53 failover
- SNS 通知
- RDS / 資料庫
- CloudFront
- NAT Gateway / private network design

原因：

1. 作品集主題是 DR 演練，不是做一個完整企業 landing zone
2. 成本與操作複雜度要維持在低水平
3. 先把 RTO / RPO、runbook、驗證報告做完整，比多堆資源更有展示效果

## Terraform 對應

- `infra/main.tf`：S3 資源、公開讀取政策、CRR 條件式資源
- `infra/providers.tf`：primary 與 DR provider
- `infra/variables.tf`：環境、區域、成本與切換參數
- `infra/outputs.tf`：供文件與 demo 使用的輸出值

## 建議演進路線

1. 先完成文件與最小 Terraform
2. 製作簡單 static site 內容
3. 需要展示 failover 時，再加 Route 53
4. 需要演示通知流程時，再加 SNS
5. 需要示範資料層 DR 時，再補 RDS snapshot / restore
