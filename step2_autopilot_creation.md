# Step 2: AI支援（オートパイロット）でセマンティックビューを作成する

## 概要

このステップでは、**AI支援ジェネレーター**を使ってセマンティックビューを作成します。
Step 1と同じ4つのテーブルから、サンプルSQLクエリを入力するだけで、
リレーションシップやメトリクスが自動生成される様子を体験してください。

**所要時間**: 10-15分

---

## 2.1 AI支援ジェネレーターを開く

1. **Snowsight** にログイン
2. 左メニューから **「AI と ML」** → **「Cortex 分析」** を選択
3. 右上の **「+ 新規作成」** をクリック
4. **「新しいセマンティックビューを作成」** を選択
5. **「AI支援で生成」** オプションを選択 ← ✨ここがポイント！

---

## 2.2 基本情報の入力

### セマンティックビュー名
```
Retail_Analytics_Autopilot_SV
```

### 場所
- **データベース**: `SV_HANDSON_DB`
- **スキーマ**: `RETAIL`

### 説明
```
小売業の売上・マーケティングデータを分析するためのセマンティックビュー。
製品カテゴリ別の売上分析、キャンペーン効果測定、SNSエンゲージメント分析が可能。
```

> 💡 **ポイント**: 説明文はAIがセマンティックビューの目的を理解するために使用します。
> ビジネスコンテキストを含めることで、より適切な構造が生成されます。

---

## 2.3 テーブルの選択

以下の4つのテーブルを選択します：

- `SV_HANDSON_DB.RETAIL.PRODUCTS`
- `SV_HANDSON_DB.RETAIL.SALES`
- `SV_HANDSON_DB.RETAIL.MARKETING_CAMPAIGN_METRICS`
- `SV_HANDSON_DB.RETAIL.SOCIAL_MEDIA`

> 📝 Step 1では各テーブルの主キーを手動で設定しましたが、
> AI支援ではこの段階では設定不要です。

---

## 2.4 AI生成オプションの有効化 ← ✨メタデータも自動生成！

テーブル選択後、以下のオプションを有効にします：

### 「AI-generated descriptions」オプション

☑️ **Add AI-generated descriptions for tables and columns**

このオプションを有効にすると：
- **テーブルの説明文**が自動生成される
- **カラムの説明文**が自動生成される
- カラム名とサンプル値からAIが内容を推測

> 💡 **ポイント**: 事前にカタログでメタデータを準備する必要はありません！
> セマンティックビュー作成プロセス内で完結します。

### 「Sample values」オプション（推奨）

☑️ **Include sample values**

サンプル値を含めることで、AIがカラムの内容をより正確に理解し、
適切な説明文やシノニムを生成できます。

---

## 2.5 サンプルSQLクエリの入力

以下のSQLクエリをコピーして、**「SQLクエリ」** フィールドに貼り付けてください。

### クエリ1: 製品カテゴリ別売上分析
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

### クエリ2: 地域×月別売上トレンド
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

### クエリ3: キャンペーン効果分析（CTR）
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

### クエリ4: SNSエンゲージメントとマーケティングの相関
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

---

## 2.6 AIによる自動生成を実行

1. すべてのクエリを入力したら、**「生成」** ボタンをクリック
2. AIが処理を開始します（約1-2分）

### 🔄 AIが自動で行うこと

| 処理内容 | 手動の場合 | AI支援の場合 |
|----------|-----------|-------------|
| 主キーの検出 | 手動で判断・設定 | ✅ 自動検出 |
| リレーションシップ検出 | JOINカラムを手動特定 | ✅ SQLから自動抽出 |
| カーディナリティ判定 | 手動で判断 | ✅ データ分析で自動判定 |
| ファクト/ディメンション分類 | 1つずつ手動分類 | ✅ 自動分類 |
| メトリクス定義 | 計算式を手動記述 | ✅ SQLから自動生成 |
| テーブル/カラム説明文 | 手動で記述 | ✅ 自動生成（オプション有効時） |
| シノニム（同義語） | 手動追加 | ✅ 一部自動提案 |

---

## 2.7 生成結果の確認

AIによる生成が完了したら、以下を確認してください：

### ✅ チェックリスト

- [ ] **リレーションシップ**: SQLのJOIN条件から正しく抽出されているか？
  - `SALES.PRODUCT_ID` → `PRODUCTS.PRODUCT_ID`
  - `SOCIAL_MEDIA.CATEGORY` → `MARKETING_CAMPAIGN_METRICS.CATEGORY`
  
- [ ] **ファクト**: 数値カラムが正しく識別されているか？
  - SALES_AMOUNT, UNITS_SOLD, IMPRESSIONS, CLICKS, MENTIONS

- [ ] **ディメンション**: 分析軸が適切に設定されているか？
  - CATEGORY, REGION, DATE, PLATFORM, CAMPAIGN_NAME など

- [ ] **メトリクス**: 計算式が正しく生成されているか？
  - SUM, AVG, DIV0 などの集計関数

---

## 2.8 必要に応じて微調整

AIが生成した内容を確認し、必要であれば調整します。

### よくある調整ポイント

1. **シノニム（同義語）の追加**
   - 日本語の別名を追加すると、日本語での質問精度が向上
   - 例: `SALES_AMOUNT` に「売上」「売上金額」を追加

2. **コメントの充実**
   - ビジネス用語での説明を追加
   - 例: 「CTR」→「クリック率。広告が表示された回数に対するクリック数の割合」

3. **不要な項目の削除**
   - AIが過剰に生成した場合は削除

---

## 2.9 セマンティックビューの作成

1. 調整が完了したら、**「作成」** ボタンをクリック
2. 作成完了を確認

---

## 2.10 動作確認

### Playgroundでテスト

1. 作成したセマンティックビュー `Retail_Analytics_Autopilot_SV` を選択
2. **「Playground」** タブを開く
3. Step 1と同じ質問を試してみてください：

```
製品カテゴリ別の売上を教えて
```

```
6月の地域別売上ランキング
```

```
キャンペーン別のクリック率は？
```

### 比較してみよう

Step 1で手動作成したものと、回答の精度や速度に違いはありますか？

---

## 振り返り：AI支援で感じたこと

✍️ **以下の点を振り返ってみてください**：

- [ ] 手動作成と比べて、どれくらい時間が短縮されましたか？
- [ ] リレーションシップは正しく検出されましたか？
- [ ] メトリクスの計算式は期待通りでしたか？
- [ ] どの部分が最も「楽になった」と感じましたか？
- [ ] 手動調整が必要だった箇所はありましたか？

---

## Step 1 vs Step 2 比較まとめ

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

---

## 使い分けガイド

### AI支援が向いているケース
- 既存のSQLクエリがある場合
- 複数テーブルの複雑な結合がある場合
- 素早くプロトタイプを作りたい場合
- データモデルに詳しくない場合

### 手動作成が向いているケース
- 非常にシンプルな構造の場合（1-2テーブル）
- 特殊なビジネスロジックが必要な場合
- AI生成結果を微調整したい場合

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

SELECT '🧹 クリーンアップ完了！' AS status;
```

---

## おわりに

このハンズオンでは、セマンティックビューの**手動作成**と**AI支援作成**の両方を体験しました。

### 主なポイント

1. **AI支援は時間短縮に効果的**
   - 特にリレーションシップとメトリクスの自動生成が強力

2. **SQLクエリがAI支援の「材料」**
   - 良質なサンプルクエリを用意することで、より精度の高い結果が得られる

3. **手動の知識は依然として重要**
   - AI生成結果のレビュー・調整には、データモデルの理解が必要

4. **ベストプラクティス**
   - まずAI支援で素早く生成 → 手動で微調整 → 検証済みクエリで精度向上

---

お疲れ様でした！ 🎉

