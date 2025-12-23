# セマンティックビュー作成ハンズオン
## 手動作成 vs AI支援（オートパイロット）比較体験

## 概要

このハンズオンでは、Snowflakeのセマンティックビューを**2つの方法**で作成し、その違いを体験します：

| パターン | 方法 | 体験のポイント |
|----------|------|---------------|
| **手動作成** | Snowsight GUIで一つずつ設定 | 設定項目の多さ、判断の難しさを体感 |
| **AI支援（オートパイロット）** | SQLクエリを入力して自動生成 | 自動化の威力、精度の高さを体感 |

## 学習目標

- セマンティックビューの構成要素（テーブル、リレーションシップ、ファクト、ディメンション、メトリクス）を理解する
- 手動作成で「何を考える必要があるか」を体験する
- AI支援で「どこまで自動化されるか」を体験する
- 両方の方法の使い分けを理解する

## 前提条件

- Snowflakeトライアルアカウント（または本番アカウント）
- ACCOUNTADMINロールへのアクセス
- AWS USリージョン推奨（Cortex機能利用のため）

## データモデル

このハンズオンでは、小売業の売上・マーケティングデータを使用します：

```
┌─────────────────────────┐     ┌─────────────────┐
│ MARKETING_CAMPAIGN      │     │ PRODUCTS        │
│ _METRICS                │     │                 │
│ ─────────────────────── │     │ ─────────────── │
│ DATE                    │     │ PRODUCT_ID (PK) │
│ CATEGORY (PK)           │     │ PRODUCT_NAME    │
│ CAMPAIGN_NAME           │     │ CATEGORY        │
│ IMPRESSIONS             │     └────────┬────────┘
│ CLICKS                  │              │
└───────────┬─────────────┘              │
            │                            │
            │ CATEGORY                   │ PRODUCT_ID
            │                            │
┌───────────▼─────────────┐     ┌────────▼────────┐
│ SOCIAL_MEDIA            │     │ SALES           │
│ ─────────────────────── │     │ ─────────────── │
│ DATE                    │     │ DATE            │
│ CATEGORY                │     │ REGION          │
│ PLATFORM                │     │ PRODUCT_ID      │
│ INFLUENCER              │     │ UNITS_SOLD      │
│ MENTIONS                │     │ SALES_AMOUNT    │
└─────────────────────────┘     └─────────────────┘
```

**リレーションシップ**:
- `SALES.PRODUCT_ID` → `PRODUCTS.PRODUCT_ID`（商品情報との結合）
- `SOCIAL_MEDIA.CATEGORY` → `MARKETING_CAMPAIGN_METRICS.CATEGORY`（カテゴリでの結合）

## ハンズオン構成

| Step | 内容 | 所要時間 |
|------|------|----------|
| **Step 0** | 環境セットアップ | 10分 |
| **Step 1** | 手動でセマンティックビュー作成 | 25-30分 |
| **Step 2** | AI支援でセマンティックビュー作成 | 10-15分 |
| **振り返り** | 比較・まとめ | 5分 |

**合計: 約50-60分**

## ファイル構成

```
.
├── README.md                      # このファイル
├── instructor_guide.md            # 講師ガイド（進行・タイムスケジュール）
├── step0_setup.sql                # 環境セットアップ
├── step1_manual_creation.md       # 手動作成ガイド
├── step2_autopilot_creation.md    # AI支援作成ガイド
└── reference/
    ├── sample_queries.sql         # AI支援用サンプルSQLクエリ
    ├── reset_environment.sql      # 環境リセット用SQL
    └── comparison_cheatsheet.md   # 比較チートシート
```

## 講師向け情報

ハンズオンを実施する講師は、[instructor_guide.md](instructor_guide.md) を参照してください。

- タイムスケジュール（60分構成）
- 各フェーズでの説明ポイント
- よくある質問と回答
- トラブルシューティング

## クイックスタート

### 1. 環境セットアップ

`step0_setup.sql` をSnowsightで実行してください。

### 2. 手動作成を体験

`step1_manual_creation.md` に従って、GUIでセマンティックビューを作成してください。

### 3. 環境をリセット

Step 1で作成したセマンティックビューを削除し、DBを再作成します（クエリ履歴をクリアするため）。

### 4. AI支援作成を体験

`step2_autopilot_creation.md` に従って、AI支援でセマンティックビューを作成してください。

---

## 補足: なぜDB再作成が必要？

セマンティックビュー作成時のAI支援機能は、過去のクエリ履歴を参照します。
手動作成時に実行したクエリが履歴に残ると、AI支援の結果に影響する可能性があります。

`DROP DATABASE` → `CREATE DATABASE` を行うと、新しいデータベースIDが生成され、
過去の履歴との関連が切れるため、公平な比較が可能になります。

---

## 参考リンク

- [セマンティックビュー概要](https://docs.snowflake.com/ja/user-guide/views-semantic/overview)
- [セマンティックビューUI操作](https://docs.snowflake.com/ja/user-guide/views-semantic/ui)
- [Cortex Analyst](https://docs.snowflake.com/ja/user-guide/snowflake-cortex/cortex-analyst/)

