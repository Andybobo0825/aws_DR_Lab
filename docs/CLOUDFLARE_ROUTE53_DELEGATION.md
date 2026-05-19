# Cloudflare Domain 委派 Route 53 子網域設定

本文件說明如何保留 Cloudflare 作為主網域 DNS，並把一個子網域委派給 Amazon Route 53，讓 AWS Lab 可以使用 Route 53 Hosted Zone 與 Failover Record。

## 目標拓樸

```text
yourdomain.com                  由 Cloudflare 管理
└── dr.yourdomain.com            NS 委派到 Route 53
    └── www.dr.yourdomain.com    Route 53 Failover record
```

## 重要限制

目前 Lab 的核心是 S3 Website endpoint + CRR。AWS S3 static website 綁定自訂網域時，bucket name 需要和 DNS record name 對應；同一個自訂入口要同時切到兩個不同 Region 的 S3 website bucket，不能只靠一組 Route 53 failover CNAME 做到完整的瀏覽器 HTTP 200。

因此這份 IaC 的 Route 53 內容定位為：

- 練習 Cloudflare 子網域委派到 Route 53。
- 練習 Route 53 Hosted Zone、Health Check、Failover Record 的控制面設定。
- 若要正式讓同一個網域自動切到跨區靜態網站，建議後續改成 CloudFront origin failover、Cloudflare Load Balancing，或每區都有可接受相同 Host header 的 HTTP 服務。

## AWS / Terraform 設定

在 `infra/terraform.tfvars` 加上以下設定：

```hcl
# Cloudflare parent zone: yourdomain.com
# Route 53 child zone: dr.yourdomain.com
enable_route53_delegated_zone = true
route53_delegated_zone_name   = "dr.yourdomain.com"

# Route 53 failover DNS control plane
enable_route53_failover = true
failover_record_name    = "www.dr.yourdomain.com"
```

套用：

```bash
terraform -chdir=infra init
terraform -chdir=infra apply
terraform -chdir=infra output route53_delegated_zone_name_servers
```

Terraform 會輸出類似以下 4 筆 Route 53 name servers：

```text
ns-123.awsdns-45.com
ns-678.awsdns-90.net
ns-111.awsdns-22.org
ns-333.awsdns-44.co.uk
```

## Cloudflare DNS 委派設定

到 Cloudflare Dashboard：

1. 選擇你的主網域，例如 `yourdomain.com`。
2. 進入 **DNS > Records**。
3. 新增 4 筆 `NS` records。
4. 每一筆都設定：
   - **Type**：`NS`
   - **Name**：`dr`
   - **Nameserver**：貼上 Terraform output 的其中一筆 Route 53 name server
   - **Proxy status**：NS record 不走 proxy，保持 DNS only
   - **TTL**：Auto 或 300 秒皆可
5. 儲存後等待 DNS propagation。

檢查委派是否生效：

```bash
dig NS dr.yourdomain.com +short
```

預期會看到 Route 53 的 `awsdns-*` name servers。

檢查 Route 53 record：

```bash
dig www.dr.yourdomain.com +short
```

若 Route 53 failover record 已建立，會解析到目前健康的目標 CNAME。

## 成本提醒

這個延伸會新增 Route 53 Hosted Zone 與 Health Check，會比原本 S3 + SNS + CRR Lab 多固定成本。若只是保留最低成本作品集，保持 `enable_route53_failover = false`。
