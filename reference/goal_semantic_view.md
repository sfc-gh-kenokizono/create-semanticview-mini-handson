# ゴール：作成するセマンティックビューの完成形

## 概要

このハンズオンで作成するセマンティックビューの完成イメージです。
**手動作成**でも**AI支援**でも、最終的にはこの構造に近いものを目指します。

---

## セマンティックビュー名

```
Retail_Analytics_SV
```

小売業の売上・マーケティングデータを横断的に分析するためのセマンティックビュー

---

## 構成要素サマリー

| 要素 | 数 | 内容 |
|------|-----|------|
| テーブル | 4 | PRODUCTS, SALES, MARKETING_CAMPAIGN_METRICS, SOCIAL_MEDIA |
| リレーションシップ | 2 | 商品結合、カテゴリ結合 |
| ファクト | 5 | 数値系カラム（売上金額、クリック数など） |
| ディメンション | 13 | 分析軸（地域、カテゴリ、日付など） |
| メトリクス | 7 | 計算式（合計、平均、率など） |

---

## 1. テーブル構成

| テーブル | 主キー | 説明 |
|---------|--------|------|
| **PRODUCTS** | PRODUCT_ID | 製品マスタ（商品ID、商品名、カテゴリ） |
| **SALES** | なし | 売上データ（日付、地域、商品ID、数量、金額） |
| **MARKETING_CAMPAIGN_METRICS** | CATEGORY | マーケティング指標（インプレッション、クリック） |
| **SOCIAL_MEDIA** | なし | SNSデータ（プラットフォーム、インフルエンサー、メンション） |

---

## 2. リレーションシップ

```
PRODUCTS ←───────── SALES
    │                 │
    │ PRODUCT_ID      │ PRODUCT_ID
    │                 │
    └─────────────────┘

MARKETING_CAMPAIGN_METRICS ←───────── SOCIAL_MEDIA
    │                                   │
    │ CATEGORY                          │ CATEGORY
    │                                   │
    └───────────────────────────────────┘
```

| 名前 | 左テーブル | 右テーブル | 結合カラム | カーディナリティ |
|------|-----------|-----------|-----------|----------------|
| sales_to_products | SALES | PRODUCTS | PRODUCT_ID | Many-to-One |
| social_to_marketing | SOCIAL_MEDIA | MARKETING_CAMPAIGN_METRICS | CATEGORY | Many-to-One |

> ⚠️ **注意**: 右テーブル（参照される側）には**主キーの設定が必須**です。
> - PRODUCTS → 主キー: PRODUCT_ID
> - MARKETING_CAMPAIGN_METRICS → 主キー: CATEGORY

---

## 3. ファクト（集計対象の数値）

| ファクト名 | カラム | 説明 |
|-----------|--------|------|
| SALES_AMOUNT | SALES.SALES_AMOUNT | 売上金額 |
| UNITS_SOLD | SALES.UNITS_SOLD | 販売数量 |
| IMPRESSIONS | MARKETING_CAMPAIGN_METRICS.IMPRESSIONS | 広告表示回数 |
| CLICKS | MARKETING_CAMPAIGN_METRICS.CLICKS | クリック数 |
| MENTIONS | SOCIAL_MEDIA.MENTIONS | SNSメンション数 |

---

## 4. ディメンション（分析軸）

### PRODUCTS テーブル
| ディメンション名 | カラム | 説明 |
|-----------------|--------|------|
| PRODUCT_ID | PRODUCTS.PRODUCT_ID | 商品ID |
| PRODUCT_NAME | PRODUCTS.PRODUCT_NAME | 商品名 |
| PRODUCT_CATEGORY | PRODUCTS.CATEGORY | 商品カテゴリ |

### SALES テーブル
| ディメンション名 | カラム | 説明 |
|-----------------|--------|------|
| SALES_DATE | SALES.DATE | 売上日 |
| REGION | SALES.REGION | 地域 |

### MARKETING_CAMPAIGN_METRICS テーブル
| ディメンション名 | カラム | 説明 |
|-----------------|--------|------|
| MARKETING_DATE | MARKETING_CAMPAIGN_METRICS.DATE | キャンペーン日 |
| MARKETING_CATEGORY | MARKETING_CAMPAIGN_METRICS.CATEGORY | マーケティングカテゴリ |
| CAMPAIGN_NAME | MARKETING_CAMPAIGN_METRICS.CAMPAIGN_NAME | キャンペーン名 |

### SOCIAL_MEDIA テーブル
| ディメンション名 | カラム | 説明 |
|-----------------|--------|------|
| SOCIAL_DATE | SOCIAL_MEDIA.DATE | SNS日付 |
| SOCIAL_CATEGORY | SOCIAL_MEDIA.CATEGORY | SNSカテゴリ |
| PLATFORM | SOCIAL_MEDIA.PLATFORM | SNSプラットフォーム |
| INFLUENCER | SOCIAL_MEDIA.INFLUENCER | インフルエンサー |

---

## 5. メトリクス（計算式）

| メトリクス名 | 計算式 | 説明 |
|-------------|--------|------|
| TOTAL_SALES_AMOUNT | `SUM(SALES_AMOUNT)` | 総売上金額 |
| TOTAL_UNITS_SOLD | `SUM(UNITS_SOLD)` | 総販売数量 |
| AVG_SALES_AMOUNT | `AVG(SALES_AMOUNT)` | 平均売上金額 |
| TOTAL_IMPRESSIONS | `SUM(IMPRESSIONS)` | 総インプレッション数 |
| TOTAL_CLICKS | `SUM(CLICKS)` | 総クリック数 |
| CLICK_THROUGH_RATE | `DIV0(SUM(CLICKS), SUM(IMPRESSIONS))` | クリック率（CTR） |
| TOTAL_MENTIONS | `SUM(MENTIONS)` | 総メンション数 |

---

## 6. 期待される分析クエリ例

このセマンティックビューが完成すると、以下のような自然言語での質問に回答できます：

| 質問 | 使用される要素 |
|------|---------------|
| 「製品カテゴリ別の売上を教えて」 | PRODUCT_CATEGORY + TOTAL_SALES_AMOUNT |
| 「6月の地域別売上ランキング」 | REGION + SALES_DATE + TOTAL_SALES_AMOUNT |
| 「キャンペーン別のクリック率は？」 | CAMPAIGN_NAME + CLICK_THROUGH_RATE |
| 「SNSプラットフォーム別のメンション数」 | PLATFORM + TOTAL_MENTIONS |
| 「フィットネスウェアの月別売上推移」 | PRODUCT_CATEGORY + SALES_DATE + TOTAL_SALES_AMOUNT |

---

## 手動 vs AI支援 の違い

### 手動作成の場合

上記の構成要素を**一つずつGUIで設定**する必要があります：
- テーブル4つを選択
- 主キーを2つ設定
- リレーションシップを2つ定義（結合カラム + カーディナリティ）
- ファクトを5つ登録
- ディメンションを13個登録
- メトリクスを7つ定義（計算式を記述）

→ **約25-30分**かかり、設定ミスのリスクあり

### AI支援の場合

サンプルSQLクエリを入力するだけで、上記の構成要素が**自動生成**されます：
- リレーションシップ → JOINから自動抽出
- ファクト/ディメンション → 自動分類
- メトリクス → 集計関数から自動生成
- 説明文 → AI自動生成（オプション）

→ **約10-15分**で完成、確認・微調整のみ

---

## 参考：完成形SQL

```sql
CREATE OR REPLACE SEMANTIC VIEW Retail_Analytics_SV

TABLES (
    PRODUCTS AS SV_HANDSON_DB.RETAIL.PRODUCTS
        PRIMARY KEY (PRODUCT_ID),
    SALES AS SV_HANDSON_DB.RETAIL.SALES,
    MARKETING_CAMPAIGN_METRICS AS SV_HANDSON_DB.RETAIL.MARKETING_CAMPAIGN_METRICS
        PRIMARY KEY (CATEGORY),
    SOCIAL_MEDIA AS SV_HANDSON_DB.RETAIL.SOCIAL_MEDIA
)

RELATIONSHIPS (
    SALES_TO_PRODUCTS AS SALES (PRODUCT_ID) REFERENCES PRODUCTS,
    SOCIAL_TO_MARKETING AS SOCIAL_MEDIA (CATEGORY) REFERENCES MARKETING_CAMPAIGN_METRICS
)

FACTS (
    SALES.sales_amount AS SALES_AMOUNT,
    SALES.units_sold AS UNITS_SOLD,
    MARKETING_CAMPAIGN_METRICS.impressions AS IMPRESSIONS,
    MARKETING_CAMPAIGN_METRICS.clicks AS CLICKS,
    SOCIAL_MEDIA.mentions AS MENTIONS
)

DIMENSIONS (
    PRODUCTS.product_id AS PRODUCT_ID,
    PRODUCTS.product_name AS PRODUCT_NAME,
    PRODUCTS.category AS PRODUCT_CATEGORY,
    SALES.date AS SALES_DATE,
    SALES.region AS REGION,
    MARKETING_CAMPAIGN_METRICS.date AS MARKETING_DATE,
    MARKETING_CAMPAIGN_METRICS.category AS MARKETING_CATEGORY,
    MARKETING_CAMPAIGN_METRICS.campaign_name AS CAMPAIGN_NAME,
    SOCIAL_MEDIA.date AS SOCIAL_DATE,
    SOCIAL_MEDIA.category AS SOCIAL_CATEGORY,
    SOCIAL_MEDIA.platform AS PLATFORM,
    SOCIAL_MEDIA.influencer AS INFLUENCER
)

METRICS (
    SALES.total_sales_amount AS SUM(SALES_AMOUNT),
    SALES.total_units_sold AS SUM(UNITS_SOLD),
    SALES.avg_sales_amount AS AVG(SALES_AMOUNT),
    MARKETING_CAMPAIGN_METRICS.total_impressions AS SUM(IMPRESSIONS),
    MARKETING_CAMPAIGN_METRICS.total_clicks AS SUM(CLICKS),
    MARKETING_CAMPAIGN_METRICS.click_through_rate AS DIV0(SUM(CLICKS), SUM(IMPRESSIONS)),
    SOCIAL_MEDIA.total_mentions AS SUM(MENTIONS)
);
```

