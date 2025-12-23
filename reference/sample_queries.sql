-- ============================================
-- AI支援セマンティックビュー作成用サンプルクエリ
-- ============================================
-- これらのクエリをAI支援ジェネレーターに入力することで、
-- リレーションシップ、ファクト、ディメンション、メトリクスが
-- 自動的に検出・生成されます。
-- ============================================


-- ============================================
-- クエリ1: 製品カテゴリ別売上分析
-- ============================================
-- 目的: 製品カテゴリごとの売上金額と販売数量を集計
-- 検出されるもの:
--   - リレーションシップ: SALES.PRODUCT_ID → PRODUCTS.PRODUCT_ID
--   - ファクト: SALES_AMOUNT, UNITS_SOLD
--   - ディメンション: CATEGORY
--   - メトリクス: SUM(SALES_AMOUNT), SUM(UNITS_SOLD)

SELECT 
    p.category,
    SUM(s.sales_amount) AS total_sales,
    SUM(s.units_sold) AS total_units
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;


-- ============================================
-- クエリ2: 地域×月別売上トレンド
-- ============================================
-- 目的: 地域ごとの月次売上推移を分析
-- 検出されるもの:
--   - ディメンション: REGION, DATE
--   - メトリクス: SUM(SALES_AMOUNT), AVG(SALES_AMOUNT)

SELECT 
    s.region,
    DATE_TRUNC('month', s.date) AS month,
    SUM(s.sales_amount) AS monthly_sales,
    AVG(s.sales_amount) AS avg_sales
FROM sales s
GROUP BY s.region, DATE_TRUNC('month', s.date)
ORDER BY month, region;


-- ============================================
-- クエリ3: キャンペーン効果分析（CTR計算）
-- ============================================
-- 目的: マーケティングキャンペーンのクリック率を算出
-- 検出されるもの:
--   - ファクト: IMPRESSIONS, CLICKS
--   - ディメンション: CAMPAIGN_NAME, CATEGORY
--   - メトリクス: SUM(IMPRESSIONS), SUM(CLICKS), DIV0(CTR計算)

SELECT 
    m.campaign_name,
    m.category,
    SUM(m.impressions) AS total_impressions,
    SUM(m.clicks) AS total_clicks,
    DIV0(SUM(m.clicks), SUM(m.impressions)) AS ctr
FROM marketing_campaign_metrics m
GROUP BY m.campaign_name, m.category
ORDER BY ctr DESC;


-- ============================================
-- クエリ4: SNSエンゲージメントとマーケティングの相関
-- ============================================
-- 目的: SNSメンション数とマーケティングクリック数の関係を分析
-- 検出されるもの:
--   - リレーションシップ: SOCIAL_MEDIA.CATEGORY → MARKETING_CAMPAIGN_METRICS.CATEGORY
--   - ファクト: MENTIONS
--   - ディメンション: PLATFORM, INFLUENCER

SELECT 
    sm.category,
    sm.platform,
    SUM(sm.mentions) AS total_mentions,
    SUM(m.clicks) AS total_clicks
FROM social_media sm
JOIN marketing_campaign_metrics m ON sm.category = m.category
GROUP BY sm.category, sm.platform
ORDER BY total_mentions DESC;


-- ============================================
-- クエリ5: インフルエンサー別パフォーマンス
-- ============================================
-- 目的: インフルエンサーごとのメンション数を比較
-- 検出されるもの:
--   - ディメンション: INFLUENCER, PLATFORM
--   - メトリクス: SUM(MENTIONS)

SELECT 
    sm.influencer,
    sm.platform,
    SUM(sm.mentions) AS total_mentions
FROM social_media sm
GROUP BY sm.influencer, sm.platform
ORDER BY total_mentions DESC;


-- ============================================
-- クエリ6: 製品×地域クロス分析
-- ============================================
-- 目的: 製品カテゴリと地域の組み合わせで売上を分析
-- 検出されるもの:
--   - 複数ディメンションの組み合わせパターン

SELECT 
    p.category AS product_category,
    s.region,
    SUM(s.sales_amount) AS total_sales,
    COUNT(*) AS transaction_count
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category, s.region
ORDER BY total_sales DESC;


-- ============================================
-- 補足: これらのクエリの効果
-- ============================================
-- 
-- 1. JOIN条件からリレーションシップが自動検出される
-- 2. GROUP BYからディメンション候補が特定される
-- 3. 集計関数（SUM, AVG, COUNT）からメトリクスが生成される
-- 4. 数値カラムがファクトとして識別される
-- 5. DIV0などの計算式もメトリクスとして取り込まれる
--
-- ============================================

