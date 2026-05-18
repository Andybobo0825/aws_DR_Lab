# DR Runbook — AWS DR Gameday Lab

## 目的

定義在主站異常、Region 不可用、或內容損毀時，如何把靜態網站服務切換到 DR 站。

## 前提

- 預設只有 S3 主站 / DR bucket
- Route 53、SNS、RDS 預設**不啟用**
- 如果 `enable_crr = true`，DR bucket 可能會比手動同步更接近主站內容

## 演練前檢查

- [ ] Terraform 狀態正常
- [ ] primary / DR bucket 名稱確認
- [ ] 需要演練的靜態內容已上傳到 primary bucket
- [ ] `RTO_RPO.md` 已確認目標值
- [ ] `FAILOVER_TEST_REPORT.md` 已準備好紀錄欄位

## 主站故障時的切換步驟

1. 確認問題範圍：
   - 是單一檔案損毀
   - 還是整個 primary bucket / primary region 無法服務
2. 檢查 DR bucket 是否有可用內容：
   - 若啟用 CRR，先確認最後同步狀態
   - 若未啟用 CRR，使用最近一次手動同步內容
3. 啟動 DR 站：
   - 使用 DR bucket website endpoint 或對應的 DNS 指向
   - 如未使用 Route 53，則以手動切換入口為主
4. 驗證網站：
   - 首頁可讀取
   - 錯誤頁可讀取
   - 主要靜態資源可載入
5. 記錄事件：
   - 切換開始時間
   - 切換完成時間
   - 影響範圍
   - 使用的恢復方法

## 資料回復步驟

如果問題是「內容被誤刪 / 誤改」而不是 Region 故障：

1. 先確認 bucket versioning 是否已啟用
2. 找回正確版本
3. 恢復到 primary bucket
4. 重新同步到 DR bucket
5. 更新 failover test report

## 回切步驟

當 primary 恢復後：

1. 確認 primary 服務健康
2. 將新內容同步回 primary
3. 如有 DNS / 入口切換，將流量切回 primary
4. 再次驗證網站功能
5. 完成 post-incident notes

## 演練結束輸出

- `FAILOVER_TEST_REPORT.md`：實際演練結果
- `RTO_RPO.md`：如有必要，根據實測結果修正目標
- README / 架構圖：如有新設計再同步更新
