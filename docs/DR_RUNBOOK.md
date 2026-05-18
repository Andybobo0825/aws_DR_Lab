# DR Runbook — AWS DR Gameday Lab

## 目的

在 primary site 無法使用時，快速把靜態網站切到 DR site，並保留可驗證的切換記錄。

## 前置條件

- Terraform 已建立 primary / DR buckets。
- 內容已部署到 primary，若啟用 CRR，DR 會自動同步。
- 已確認網站內容符合對外展示要求。

## 演練模式

### 模式 A：無 CRR

1. 確認 primary 站點目前內容版本。
2. 將 primary 內容複製到 DR：
   - 使用 `aws s3 sync` 或人工複製流程。
3. 驗證 DR website endpoint 可讀。
4. 若有 DNS 層切換，再更新 Route 53 或手動切換入口。
5. 記錄切換時間與差異。

### 模式 B：有 CRR

1. 確認 primary bucket replication 狀態正常。
2. 等待 DR bucket 接收最新版本。
3. 驗證 DR website endpoint 可讀。
4. 若有 DNS 層切換，再更新入口流量。
5. 驗證版本與內容一致性。

## 建議切換步驟

- [ ] 宣告進入 DR 演練
- [ ] 停止或隔離 primary 的變更來源
- [ ] 驗證 DR 內容最新
- [ ] 切換入口指向 DR
- [ ] 驗證首頁與錯誤頁
- [ ] 紀錄 RTO / RPO
- [ ] 整理演練結果

## 回復步驟

1. 確認 primary 站點恢復。
2. 讓 primary 重新成為內容寫入來源。
3. 必要時把 DR 的最後狀態同步回 primary。
4. 重新驗證網站。

## 成功標準

- DR endpoint 可正常回應。
- 內容可讀，且版本符合預期。
- 切換流程可在文件中重複執行。
- RTO / RPO 可被量化與回報。

## 測試紀錄欄位

- 日期：
- 測試模式：
- 觸發原因：
- 切換完成時間：
- RTO：
- RPO：
- 結果：
- 後續改善：

