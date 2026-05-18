# Failover Test Report — AWS DR Gameday Lab

## 狀態

- [ ] 尚未實際執行
- [x] 文件模板已建立

## 基本資訊

| 欄位 | 內容 |
| --- | --- |
| 演練日期 | 待填 |
| 演練人員 | 待填 |
| 目標環境 | AWS DR Gameday Lab |
| 入口模式 | S3 靜態網站 / 手動切換 |
| Route 53 failover | 預設停用 |
| SNS 通知 | 預設停用 |
| RDS | 預設停用 |

## 演練情境

- [ ] 主站 bucket 損毀
- [ ] 主站區域不可用
- [ ] 靜態檔案誤刪 / 誤改
- [ ] CRR 延遲驗證

## 預期結果

- DR bucket 可正常提供網站內容
- 可以在可接受時間內完成切換
- 可清楚說明 RTO / RPO 是否達標
- 可完成事後記錄與改進

## 實際結果

> 這一份文件是 template。請在實際演練後填入觀測結果。

| 項目 | 結果 |
| --- | --- |
| 切換開始時間 | 待填 |
| 切換完成時間 | 待填 |
| 實際 RTO | 待填 |
| 實際 RPO | 待填 |
| 使用的回復方式 | 待填 |
| 是否達標 | 待填 |

## Observations / Lessons Learned

- 待填

## Follow-up Actions

- 待填
