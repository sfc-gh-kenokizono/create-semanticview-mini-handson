# セマンティックビュー作成ハンズオン

## 手動作成 vs AI支援（オートパイロット）比較体験

---

## 概要

このハンズオンでは、Snowflakeのセマンティックビューを**2つの方法**で作成し、その違いを体験します：

| パターン | 方法 | 体験のポイント |
|----------|------|---------------|
| **手動作成** | Snowsight GUIで一つずつ設定 | 設定項目の多さ、判断の難しさを体感 |
| **AI支援** | SQLクエリを入力して自動生成 | 自動化の威力、精度の高さを体感 |

### 学習目標

- セマンティックビューの構成要素を理解する
- 手動作成で「何を考える必要があるか」を体験する
- AI支援で「どこまで自動化されるか」を体験する
- 両方の方法の使い分けを理解する

### 所要時間

| Step | 内容 | 所要時間 |
|------|------|----------|
| Step 0 | 環境セットアップ | 10分 |
| Step 1 | 手動でセマンティックビュー作成 | 25-30分 |
| Step 2 | AI支援でセマンティックビュー作成 | 10-15分 |
| 振り返り | 比較・まとめ | 5分 |

**合計: 約50-60分**

### 前提条件

- Snowflakeトライアルアカウント（または本番アカウント）
- ACCOUNTADMINロールへのアクセス
- AWS USリージョン推奨（Cortex機能利用のため）

---

## ゴール：作成するセマンティックビュー

このハンズオンで作成するセマンティックビューの構成：

| 要素 | 数 | 内容 |
|------|-----|------|
| テーブル | 4 | PRODUCTS, SALES, MARKETING_CAMPAIGN_METRICS, SOCIAL_MEDIA |
| リレーションシップ | 2 | 商品結合、カテゴリ結合 |
| ファクト | 5 | 売上金額、販売数量、インプレッション、クリック、メンション |
| ディメンション | 13 | 地域、カテゴリ、日付、プラットフォームなど |
| メトリクス | 7 | 総売上、平均売上、CTR（クリック率）など |

完成すると、以下のような質問に回答できます：
- 「製品カテゴリ別の売上を教えて」
- 「2025年6月の地域別売上ランキング」
- 「クリック率を時系列で分析して」

---

## データモデル

小売業の売上・マーケティングデータを使用します：

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

---

## Step 0: 環境セットアップ

### 手順

1. Snowsightにログイン
2. 新しいワークシートを開く
3. `step0_setup.sql` の内容をコピー＆ペースト
4. 全文を選択して実行

### 確認

以下のSQLでテーブルが作成されたことを確認：

```sql
SELECT 'PRODUCTS' AS table_name, COUNT(*) FROM products
UNION ALL SELECT 'SALES', COUNT(*) FROM sales
UNION ALL SELECT 'MARKETING_CAMPAIGN_METRICS', COUNT(*) FROM marketing_campaign_metrics
UNION ALL SELECT 'SOCIAL_MEDIA', COUNT(*) FROM social_media;
```

### よくあるトラブル

| 症状 | 原因 | 対処 |
|------|------|------|
| 権限エラー | ACCOUNTADMINでない | `USE ROLE ACCOUNTADMIN;` を実行 |
| テーブルが見えない | DB/スキーマが違う | `USE DATABASE SV_HANDSON_DB; USE SCHEMA RETAIL;` |

---

## Step 1: 手動でセマンティックビューを作成する

Snowsight の GUI を使って**手動で**セマンティックビューを作成します。
各設定項目を一つずつ入力し、「何を考える必要があるか」を体験してください。

**所要時間**: 25-30分

### 1.1 セマンティックビュー作成画面を開く

1. **Snowsight** にログイン
2. 左メニューから **「AI と ML」** → **「Cortex 分析」** を選択
3. 右上の **「+ 新規作成」** をクリック
4. **「新しいセマンティックビューを作成」** を選択

> 💡 **ポイント**: この時点では「AI支援」オプションは使用しません。手動で設定していきます。

### 1.2 基本情報の入力

**セマンティックビュー名**
```
Retail_Analytics_Manual_SV
```

**場所**
- データベース: `SV_HANDSON_DB`
- スキーマ: `RETAIL`

**説明（オプション）**
```
小売業の売上・マーケティングデータを分析するためのセマンティックビュー（手動作成版）
```

### 1.3 テーブルの選択と主キー設定

以下の4つのテーブルを追加します。各テーブルの**主キー**は何でしょうか？

| テーブル名 | カラム | 主キーは？ |
|-----------|--------|-----------|
| PRODUCTS | PRODUCT_ID, PRODUCT_NAME, CATEGORY | ??? |
| SALES | DATE, REGION, PRODUCT_ID, UNITS_SOLD, SALES_AMOUNT | ??? |
| MARKETING_CAMPAIGN_METRICS | DATE, CATEGORY, CAMPAIGN_NAME, IMPRESSIONS, CLICKS | ??? |
| SOCIAL_MEDIA | DATE, CATEGORY, PLATFORM, INFLUENCER, MENTIONS | ??? |

<details>
<summary>💡 ヒント（クリックして表示）</summary>

主キーを決めるには、以下を考えます：
- そのカラムの値はユニーク（一意）か？
- 他のテーブルから参照される可能性があるか？

</details>

<details>
<summary>✅ 回答（クリックして表示）</summary>

| テーブル名 | 主キー | 理由 |
|-----------|--------|------|
| PRODUCTS | `PRODUCT_ID` | 各製品を一意に識別 |
| SALES | なし（複合キー相当） | 日付×地域×商品の組み合わせで一意 |
| MARKETING_CAMPAIGN_METRICS | `CATEGORY` | カテゴリごとに集計されたデータ |
| SOCIAL_MEDIA | なし | 日付×カテゴリ×プラットフォームの組み合わせ |

</details>

**設定手順**

1. **「テーブルを追加」** をクリック
2. 以下の4つのテーブルを追加：
   - `SV_HANDSON_DB.RETAIL.MARKETING_CAMPAIGN_METRICS`
   - `SV_HANDSON_DB.RETAIL.PRODUCTS`
   - `SV_HANDSON_DB.RETAIL.SALES`
   - `SV_HANDSON_DB.RETAIL.SOCIAL_MEDIA`

### 1.4 リレーションシップの設定

> ⚠️ **重要**: リレーションシップを張るには、**参照される側のテーブルに主キーが設定されている必要があります**。
> 主キーが設定されていないとエラーになります。

4つのテーブル間で、どのような結合関係がありますか？

<details>
<summary>💡 ヒント（クリックして表示）</summary>

- SALESテーブルには `PRODUCT_ID` があります。PRODUCTSテーブルと結合できそうです。
- SOCIAL_MEDIAとMARKETING_CAMPAIGN_METRICSは、`CATEGORY` で結合できそうです。
- カーディナリティ（多対一など）は、各テーブルのデータを見て判断します。

</details>

<details>
<summary>✅ 回答（クリックして表示）</summary>

**リレーションシップ1**: SALES → PRODUCTS
- 結合カラム: `SALES.PRODUCT_ID` = `PRODUCTS.PRODUCT_ID`
- カーディナリティ: **Many-to-One**（1つの商品に対して複数の売上レコード）

**リレーションシップ2**: SOCIAL_MEDIA → MARKETING_CAMPAIGN_METRICS
- 結合カラム: `SOCIAL_MEDIA.CATEGORY` = `MARKETING_CAMPAIGN_METRICS.CATEGORY`
- カーディナリティ: **Many-to-One**（1つのカテゴリに対して複数のSNSデータ）

</details>

**設定手順**

1. **「リレーションシップ」** タブを開く
2. **「+ リレーションシップを追加」** をクリック
3. 以下を設定：

**リレーションシップ1**:

| 項目 | 値 |
|------|-----|
| 名前 | `sales_to_products` |
| 左テーブル | `SALES` |
| 左カラム | `PRODUCT_ID` |
| 右テーブル | `PRODUCTS` |
| 右カラム | `PRODUCT_ID` |
| カーディナリティ | `Many to One` |

**リレーションシップ2**:

| 項目 | 値 |
|------|-----|
| 名前 | `social_to_marketing` |
| 左テーブル | `SOCIAL_MEDIA` |
| 左カラム | `CATEGORY` |
| 右テーブル | `MARKETING_CAMPAIGN_METRICS` |
| 右カラム | `CATEGORY` |
| カーディナリティ | `Many to One` |

### 1.5 ファクト（Facts）の設定

「ファクト」は集計対象となる数値カラムです。

> 💡 **注意**: Snowflakeはテーブル追加時にカラムを自動分類しますが、数値カラムが「ディメンション」に分類されていることがあります。
> 例えば `CLICKS` や `IMPRESSIONS` がディメンションにある場合は、**「ファクトへ移動」** してください。

1. **「ファクト」** タブを開く
2. 以下のカラムがファクトにあることを確認（なければディメンションから移動）：

| テーブル | ファクト名 | コメント |
|---------|-----------|---------|
| MARKETING_CAMPAIGN_METRICS | `CLICKS` | クリック数 |
| MARKETING_CAMPAIGN_METRICS | `IMPRESSIONS` | インプレッション数 |
| SALES | `SALES_AMOUNT` | 売上金額 |
| SALES | `UNITS_SOLD` | 販売数量 |
| SOCIAL_MEDIA | `MENTIONS` | メンション数 |

### 1.6 ディメンション（Dimensions）の設定

「ディメンション」は分析の切り口（「〜別」「〜ごと」）となるカラムです。

> 💡 **注意**: ファクトに分類されているカラムがあれば、**「ディメンションへ移動」** してください。

1. **「ディメンション」** タブを開く
2. 以下のカラムがディメンションにあることを確認（なければファクトから移動）：

| テーブル | ディメンション名 | 種類 | コメント |
|---------|-----------------|------|---------|
| MARKETING_CAMPAIGN_METRICS | `CAMPAIGN_NAME` | | キャンペーン名 |
| MARKETING_CAMPAIGN_METRICS | `CATEGORY` | | マーケティングカテゴリ |
| MARKETING_CAMPAIGN_METRICS | `DATE` | 時間 | キャンペーン日 |
| PRODUCTS | `CATEGORY` | | 商品カテゴリ |
| PRODUCTS | `PRODUCT_ID` | | 商品ID |
| PRODUCTS | `PRODUCT_NAME` | | 商品名 |
| SALES | `DATE` | 時間 | 売上日 |
| SALES | `REGION` | | 地域 |
| SOCIAL_MEDIA | `CATEGORY` | | SNSカテゴリ |
| SOCIAL_MEDIA | `DATE` | 時間 | SNS日付 |
| SOCIAL_MEDIA | `INFLUENCER` | | インフルエンサー |
| SOCIAL_MEDIA | `PLATFORM` | | SNSプラットフォーム |

> 💡 **時間ディメンション**: `DATE` カラムは「時間」タイプのディメンションです。
> 時間ディメンションを設定すると、「月別」「四半期別」などの時間軸での分析が可能になります。

### 1.7 メトリクス（Metrics）の設定

「メトリクス」は複数のファクトを組み合わせた計算式を定義します。

> 💡 **ポイント**: 単純な`SUM`や`AVG`はファクトがあれば自動集計されるため、メトリクス化は不要です。
> メトリクスは「クリック率 = クリック数 ÷ インプレッション数」のような**複合計算**に使います。

1. **「メトリクス」** タブを開く
2. 以下のメトリクスを追加：

| テーブル | メトリクス名 | 計算式 | コメント |
|---------|-------------|--------|---------|
| MARKETING_CAMPAIGN_METRICS | `CLICK_THROUGH_RATE` | `DIV0(SUM(CLICKS), SUM(IMPRESSIONS))` | クリック率 |

### 1.8 セマンティックビューの作成

1. すべての設定を確認
2. **「作成」** ボタンをクリック
3. 作成完了を確認

### 1.9 動作確認（Playground）

1. 作成したセマンティックビュー `Retail_Analytics_Manual_SV` を選択
2. **「Playground」** タブを開く
3. 以下の質問を試してみてください：

```
製品カテゴリ別の売上を教えて
```

```
2025年6月の地域別売上ランキング
```

```
クリック率を時系列で分析して
```

### 振り返り：手動作成で感じたこと

- 主キーの判断は簡単でしたか？
- リレーションシップのカーディナリティ判定は直感的でしたか？
- ファクトとディメンションの分類に迷いはありませんでしたか？
- メトリクスの計算式は正しく書けましたか？
- 全体で何分かかりましたか？

> 💡 **次のステップ**: 手動で作成したセマンティックビューはそのまま残して、Step 2に進みます。
> 最後に両方をPlaygroundで比較します。

---

## Step 2: AI支援（オートパイロット）でセマンティックビューを作成する

**AI支援ジェネレーター**を使ってセマンティックビューを作成します。
Step 1と同じ4つのテーブルから、サンプルSQLクエリを入力するだけで、
リレーションシップやメトリクスが自動生成される様子を体験してください。

**所要時間**: 10-15分

### 2.1 AI支援ジェネレーターを開く

1. **Snowsight** にログイン
2. 左メニューから **「AI と ML」** → **「Cortex 分析」** を選択
3. 右上の **「+ 新規作成」** をクリック
4. **「新しいセマンティックビューを作成」** を選択
5. **「AI支援で生成」** オプションを選択 ← ✨ここがポイント！

### 2.2 基本情報の入力

**セマンティックビュー名**
```
Retail_Analytics_Autopilot_SV
```

**場所**
- データベース: `SV_HANDSON_DB`
- スキーマ: `RETAIL`

**説明**
```
小売業の売上・マーケティングデータを分析するためのセマンティックビュー。
製品カテゴリ別の売上分析、キャンペーン効果測定、SNSエンゲージメント分析が可能。
```

> 💡 **ポイント**: 説明文はAIがセマンティックビューの目的を理解するために使用します。

### 2.3 テーブルの選択

以下の4つのテーブルを選択します：

- `SV_HANDSON_DB.RETAIL.PRODUCTS`
- `SV_HANDSON_DB.RETAIL.SALES`
- `SV_HANDSON_DB.RETAIL.MARKETING_CAMPAIGN_METRICS`
- `SV_HANDSON_DB.RETAIL.SOCIAL_MEDIA`

### 2.4 AI生成オプションの有効化 ← ✨メタデータも自動生成！

テーブル選択後、以下のオプションを有効にします：

☑️ **Add AI-generated descriptions for tables and columns**

このオプションを有効にすると：
- テーブルの説明文が自動生成される
- カラムの説明文が自動生成される
- カラム名とサンプル値からAIが内容を推測

> 💡 **ポイント**: 事前にカタログでメタデータを準備する必要はありません！

☑️ **Include sample values**（推奨）

サンプル値を含めることで、AIがカラムの内容をより正確に理解します。

### 2.5 サンプルSQLクエリの入力

以下のSQLクエリをコピーして、**「SQLクエリ」** フィールドに貼り付けてください。

**クエリ1: 製品カテゴリ別売上分析**

```sql
SELECT 
    p.category,
    SUM(s.sales_amount) AS total_sales,
    SUM(s.units_sold) AS total_units
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;
```

**クエリ2: 地域×月別売上トレンド**

```sql
SELECT 
    s.region,
    DATE_TRUNC('month', s.date) AS month,
    SUM(s.sales_amount) AS monthly_sales,
    AVG(s.sales_amount) AS avg_sales
FROM sales s
GROUP BY s.region, DATE_TRUNC('month', s.date)
ORDER BY month, region;
```

**クエリ3: キャンペーン効果分析（CTR）**

```sql
SELECT 
    m.campaign_name,
    m.category,
    SUM(m.impressions) AS total_impressions,
    SUM(m.clicks) AS total_clicks,
    DIV0(SUM(m.clicks), SUM(m.impressions)) AS ctr
FROM marketing_campaign_metrics m
GROUP BY m.campaign_name, m.category
ORDER BY ctr DESC;
```

**クエリ4: SNSエンゲージメントとマーケティングの相関**

```sql
SELECT 
    sm.category,
    sm.platform,
    SUM(sm.mentions) AS total_mentions,
    SUM(m.clicks) AS total_clicks
FROM social_media sm
JOIN marketing_campaign_metrics m ON sm.category = m.category
GROUP BY sm.category, sm.platform
ORDER BY total_mentions DESC;
```

### 2.6 AIによる自動生成を実行

1. すべてのクエリを入力したら、**「生成」** ボタンをクリック
2. AIが処理を開始します（約1-2分）

**AIが自動で行うこと**

| 処理内容 | 手動の場合 | AI支援の場合 |
|----------|-----------|-------------|
| 主キーの検出 | 手動で判断・設定 | ✅ 自動検出 |
| リレーションシップ検出 | JOINカラムを手動特定 | ✅ SQLから自動抽出 |
| カーディナリティ判定 | 手動で判断 | ✅ データ分析で自動判定 |
| ファクト/ディメンション分類 | 1つずつ手動分類 | ✅ 自動分類 |
| メトリクス定義 | 計算式を手動記述 | ✅ SQLから自動生成 |
| テーブル/カラム説明文 | 手動で記述 | ✅ 自動生成（オプション有効時） |

### 2.7 生成結果の確認

AIによる生成が完了したら、以下を確認してください：

- **リレーションシップ**: SQLのJOIN条件から正しく抽出されているか？
- **ファクト**: 数値カラムが正しく識別されているか？
- **ディメンション**: 分析軸が適切に設定されているか？
- **メトリクス**: 計算式が正しく生成されているか？

### 2.8 必要に応じて微調整

AIが生成した内容を確認し、必要であれば調整します。

**よくある調整ポイント**

1. **シノニム（同義語）の追加**
   - 日本語の別名を追加すると、日本語での質問精度が向上
   - 例: `SALES_AMOUNT` に「売上」「売上金額」を追加

2. **コメントの充実**
   - ビジネス用語での説明を追加
   - 例: 「CTR」→「クリック率。広告表示回数に対するクリック数の割合」

### 2.9 セマンティックビューの作成

1. 調整が完了したら、**「作成」** ボタンをクリック
2. 作成完了を確認

### 2.10 動作確認 & 比較（Playground）

両方のセマンティックビューをPlaygroundで比較します：

1. **Cortex 分析** 画面で、以下の2つが表示されていることを確認：
   - `Retail_Analytics_Manual_SV`（Step 1で作成）
   - `Retail_Analytics_Autopilot_SV`（Step 2で作成）

2. それぞれのセマンティックビューで**同じ質問**を試して、回答を比較してください：

```
製品カテゴリ別の売上を教えて
```

```
2025年6月の地域別売上ランキング
```

```
クリック率を時系列で分析して
```

### 比較ポイント

- 回答の精度に違いはありますか？
- 生成されるSQLに違いはありますか？
- どちらが使いやすいと感じましたか？

---

## 比較まとめ

### Step 1 vs Step 2 比較

| 比較項目 | Step 1（手動） | Step 2（AI支援） |
|----------|---------------|-----------------|
| **所要時間** | 25-30分 | 10-15分 |
| **主キー設定** | 手動で判断 | 自動検出 |
| **リレーションシップ** | 手動で設定 | SQLから自動抽出 |
| **カーディナリティ** | 手動で判断 | 自動判定 |
| **ファクト/ディメンション** | 1つずつ分類 | 自動分類 |
| **メトリクス** | 計算式を手動記述 | SQLから自動生成 |
| **精度** | 人間の判断に依存 | データ分析ベース |
| **再現性** | 担当者によりばらつき | 一貫した結果 |

### 使い分けガイド

**AI支援が向いているケース**
- 既存のSQLクエリがある場合
- 複数テーブルの複雑な結合がある場合
- 素早くプロトタイプを作りたい場合
- データモデルに詳しくない場合

**手動作成が向いているケース**
- 非常にシンプルな構造の場合（1-2テーブル）
- 特殊なビジネスロジックが必要な場合
- AI生成結果を微調整したい場合
- 学習目的で構成要素を理解したい場合

---

## クリーンアップ

ハンズオン終了後、リソースを削除する場合：

```sql
USE ROLE ACCOUNTADMIN;

-- セマンティックビューの削除
DROP SEMANTIC VIEW IF EXISTS sv_handson_db.retail.retail_analytics_manual_sv;
DROP SEMANTIC VIEW IF EXISTS sv_handson_db.retail.retail_analytics_autopilot_sv;

-- データベースとウェアハウスの削除
DROP DATABASE IF EXISTS sv_handson_db;
DROP WAREHOUSE IF EXISTS sv_handson_wh;

-- API統合の削除
DROP API INTEGRATION IF EXISTS git_api_integration_sv;

-- ロールの削除
DROP ROLE IF EXISTS semantic_view_handson_role;

SELECT 'クリーンアップ完了！' AS status;
```

---

## 参考リンク

- [セマンティックビュー概要](https://docs.snowflake.com/ja/user-guide/views-semantic/overview)
- [セマンティックビューUI操作](https://docs.snowflake.com/ja/user-guide/views-semantic/ui)
- [Cortex Analyst](https://docs.snowflake.com/ja/user-guide/snowflake-cortex/cortex-analyst/)

---

## ファイル構成

```
.
├── README.md             # このファイル（ユーザーガイド）
├── step0_setup.sql       # 環境セットアップSQL
├── sample_queries.sql    # AI支援用サンプルSQLクエリ（コピー用）
└── data/                 # サンプルデータ（CSVファイル）
    ├── products.csv
    ├── sales.csv
    ├── marketing_campaign_metrics.csv
    └── social_media_mentions.csv
```
