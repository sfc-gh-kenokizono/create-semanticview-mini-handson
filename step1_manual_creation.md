# Step 1: 手動でセマンティックビューを作成する

## 概要

このステップでは、Snowsight の GUI を使って**手動で**セマンティックビューを作成します。
各設定項目を一つずつ入力し、「何を考える必要があるか」を体験してください。

**所要時間**: 25-30分

---

## 1.1 セマンティックビュー作成画面を開く

1. **Snowsight** にログイン
2. 左メニューから **「AI と ML」** → **「Cortex 分析」** を選択
3. 右上の **「+ 新規作成」** をクリック
4. **「新しいセマンティックビューを作成」** を選択

> 💡 **ポイント**: この時点では「AI支援」オプションは使用しません。手動で設定していきます。

---

## 1.2 基本情報の入力

### セマンティックビュー名
```
Retail_Analytics_Manual_SV
```

### 場所
- **データベース**: `SV_HANDSON_DB`
- **スキーマ**: `RETAIL`

### 説明（オプション）
```
小売業の売上・マーケティングデータを分析するためのセマンティックビュー（手動作成版）
```

---

## 1.3 テーブルの選択と主キー設定

### 🤔 考えてみよう
以下の4つのテーブルを追加します。各テーブルの**主キー**は何でしょうか？

| テーブル名 | カラム | 主キーは？ |
|-----------|--------|-----------|
| PRODUCTS | PRODUCT_ID, PRODUCT_NAME, CATEGORY | ??? |
| SALES | DATE, REGION, PRODUCT_ID, UNITS_SOLD, SALES_AMOUNT | ??? |
| MARKETING_CAMPAIGN_METRICS | DATE, CATEGORY, CAMPAIGN_NAME, IMPRESSIONS, CLICKS | ??? |
| SOCIAL_MEDIA | DATE, CATEGORY, PLATFORM, INFLUENCER, MENTIONS | ??? |

---

### 回答を考えてから、以下を設定してください

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

---

### 設定手順

1. **「テーブルを追加」** をクリック
2. `SV_HANDSON_DB.RETAIL.PRODUCTS` を選択
3. 追加されたテーブルカードで **主キー** を確認
   - `PRODUCT_ID` が自動選択されているはず（テーブル定義で設定済み）
4. 同様に以下のテーブルも追加
   - `SALES`（主キー: なし）
   - `MARKETING_CAMPAIGN_METRICS`（主キー: `CATEGORY` が自動選択）
   - `SOCIAL_MEDIA`（主キー: なし）

> 💡 **ポイント**: PRODUCTS と MARKETING_CAMPAIGN_METRICS はテーブル定義時に主キーが設定されているため、自動で選択されます。
> これらはリレーションシップで参照される側なので、主キーが必要です。

> ⏱️ **ここまでの所要時間**: 約5分

---

## 1.4 リレーションシップの設定

> ⚠️ **重要**: リレーションシップを張るには、**参照される側のテーブルに主キーが設定されている必要があります**。
> 
> 例: `SALES (PRODUCT_ID) REFERENCES PRODUCTS` の場合、PRODUCTS に主キーが必要です。
> 
> 前のステップで PRODUCTS と MARKETING_CAMPAIGN_METRICS に主キーを設定したのはこのためです。
> 主キーが設定されていないとエラーになります。

### 🤔 考えてみよう
4つのテーブル間で、どのような結合関係がありますか？

```
PRODUCTS        SALES        MARKETING_CAMPAIGN_METRICS        SOCIAL_MEDIA
   ?     ←→      ?                    ?             ←→             ?
```

以下を考えてみてください：
1. どのカラム同士で結合できるか？
2. 結合の方向（many-to-one / one-to-many）はどちらか？

---

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

---

### 設定手順

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

> ⏱️ **ここまでの所要時間**: 約10分（累計15分）

---

## 1.5 ファクト（Facts）の設定

### 🤔 考えてみよう
「ファクト」は集計対象となる数値カラムです。以下のカラムのうち、ファクトとして適切なものはどれでしょう？

| カラム | ファクト？ | 理由 |
|--------|-----------|------|
| SALES.SALES_AMOUNT | ??? | |
| SALES.UNITS_SOLD | ??? | |
| SALES.PRODUCT_ID | ??? | |
| MARKETING_CAMPAIGN_METRICS.IMPRESSIONS | ??? | |
| MARKETING_CAMPAIGN_METRICS.CLICKS | ??? | |
| SOCIAL_MEDIA.MENTIONS | ??? | |

---

<details>
<summary>✅ 回答（クリックして表示）</summary>

| カラム | ファクト？ | 理由 |
|--------|-----------|------|
| SALES.SALES_AMOUNT | ✅ YES | 売上金額は集計対象 |
| SALES.UNITS_SOLD | ✅ YES | 販売数量は集計対象 |
| SALES.PRODUCT_ID | ❌ NO | IDは識別子であり集計対象ではない |
| IMPRESSIONS | ✅ YES | インプレッション数は集計対象 |
| CLICKS | ✅ YES | クリック数は集計対象 |
| MENTIONS | ✅ YES | メンション数は集計対象 |

</details>

---

### 設定手順

1. **「ファクト」** タブを開く
2. 各テーブルのカラムから、ファクトを追加：

| ファクト名 | カラム | コメント |
|-----------|--------|---------|
| `SALES_AMOUNT` | SALES.SALES_AMOUNT | 売上金額 |
| `UNITS_SOLD` | SALES.UNITS_SOLD | 販売数量 |
| `IMPRESSIONS` | MARKETING_CAMPAIGN_METRICS.IMPRESSIONS | インプレッション数 |
| `CLICKS` | MARKETING_CAMPAIGN_METRICS.CLICKS | クリック数 |
| `MENTIONS` | SOCIAL_MEDIA.MENTIONS | メンション数 |

> ⏱️ **ここまでの所要時間**: 約5分（累計20分）

---

## 1.6 ディメンション（Dimensions）の設定

### 🤔 考えてみよう
「ディメンション」は分析の切り口（「〜別」「〜ごと」）となるカラムです。

---

### 設定手順

以下のディメンションを追加してください：

| ディメンション名 | カラム | コメント |
|-----------------|--------|---------|
| `PRODUCT_ID` | PRODUCTS.PRODUCT_ID | 商品ID |
| `PRODUCT_NAME` | PRODUCTS.PRODUCT_NAME | 商品名 |
| `PRODUCT_CATEGORY` | PRODUCTS.CATEGORY | 商品カテゴリ |
| `SALES_DATE` | SALES.DATE | 売上日 |
| `REGION` | SALES.REGION | 地域 |
| `MARKETING_DATE` | MARKETING_CAMPAIGN_METRICS.DATE | キャンペーン日 |
| `CAMPAIGN_NAME` | MARKETING_CAMPAIGN_METRICS.CAMPAIGN_NAME | キャンペーン名 |
| `MARKETING_CATEGORY` | MARKETING_CAMPAIGN_METRICS.CATEGORY | マーケティングカテゴリ |
| `SOCIAL_DATE` | SOCIAL_MEDIA.DATE | SNS日付 |
| `PLATFORM` | SOCIAL_MEDIA.PLATFORM | SNSプラットフォーム |
| `INFLUENCER` | SOCIAL_MEDIA.INFLUENCER | インフルエンサー |

> ⏱️ **ここまでの所要時間**: 約5分（累計25分）

---

## 1.7 メトリクス（Metrics）の設定

### 🤔 考えてみよう
「メトリクス」は計算式を定義したものです。以下のビジネス指標を計算式で表現してみてください：

| ビジネス指標 | 計算式 |
|-------------|--------|
| 総売上金額 | ??? |
| 総販売数量 | ??? |
| 平均売上金額 | ??? |
| クリック率（CTR） | ??? |
| 総メンション数 | ??? |

---

<details>
<summary>✅ 回答（クリックして表示）</summary>

| ビジネス指標 | 計算式 |
|-------------|--------|
| 総売上金額 | `SUM(SALES_AMOUNT)` |
| 総販売数量 | `SUM(UNITS_SOLD)` |
| 平均売上金額 | `AVG(SALES_AMOUNT)` |
| クリック率（CTR） | `DIV0(SUM(CLICKS), SUM(IMPRESSIONS))` |
| 総メンション数 | `SUM(MENTIONS)` |

</details>

---

### 設定手順

1. **「メトリクス」** タブを開く
2. 以下のメトリクスを追加：

| メトリクス名 | 計算式 | コメント |
|-------------|--------|---------|
| `TOTAL_SALES_AMOUNT` | `SUM(SALES_AMOUNT)` | 総売上金額 |
| `TOTAL_UNITS_SOLD` | `SUM(UNITS_SOLD)` | 総販売数量 |
| `AVG_SALES_AMOUNT` | `AVG(SALES_AMOUNT)` | 平均売上金額 |
| `CLICK_THROUGH_RATE` | `DIV0(SUM(CLICKS), SUM(IMPRESSIONS))` | クリック率 |
| `TOTAL_MENTIONS` | `SUM(MENTIONS)` | 総メンション数 |

> ⏱️ **ここまでの所要時間**: 約5分（累計30分）

---

## 1.8 セマンティックビューの作成

1. すべての設定を確認
2. **「作成」** ボタンをクリック
3. 作成完了を確認

---

## 1.9 動作確認

### Playgroundでテスト

1. 作成したセマンティックビュー `Retail_Analytics_Manual_SV` を選択
2. **「Playground」** タブを開く
3. 以下の質問を試してみてください：

```
製品カテゴリ別の売上を教えて
```

```
6月の地域別売上ランキング
```

```
キャンペーン別のクリック率は？
```

---

## 振り返り：手動作成で感じたこと

✍️ **以下の点を振り返ってみてください**：

- [ ] 主キーの判断は簡単でしたか？
- [ ] リレーションシップのカーディナリティ判定は直感的でしたか？
- [ ] ファクトとディメンションの分類に迷いはありませんでしたか？
- [ ] メトリクスの計算式は正しく書けましたか？
- [ ] 全体で何分かかりましたか？

---

## 次のステップ

**Step 2に進む前に**、環境をリセットします。

以下のSQLを実行してください：

```sql
-- Step 1で作成したセマンティックビューを削除
USE ROLE semantic_view_handson_role;
DROP SEMANTIC VIEW IF EXISTS sv_handson_db.retail.retail_analytics_manual_sv;

-- 確認
SELECT 'セマンティックビュー削除完了。Step 2に進んでください。' AS status;
```

> 📝 **注意**: Step 2ではAI支援を使って同じセマンティックビューを作成します。
> 公平な比較のため、手動で作成したものを削除しておきます。

---

[→ Step 2: AI支援でセマンティックビューを作成する](step2_autopilot_creation.md)

