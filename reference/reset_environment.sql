-- ============================================
-- 環境リセット用SQL
-- ============================================
-- Step 1（手動作成）完了後、Step 2（AI支援）の前に実行します。
-- 
-- 目的:
-- - クエリ履歴をクリアするためにDBを再作成
-- - 公平な比較のため、手動作成で蓄積された履歴の影響を排除
-- ============================================

USE ROLE semantic_view_handson_role;

-- Step 1で作成したセマンティックビューを削除
DROP SEMANTIC VIEW IF EXISTS sv_handson_db.retail.retail_analytics_manual_sv;

-- 確認
SELECT 'セマンティックビュー削除完了' AS step1;


-- ============================================
-- 【オプション】完全リセット（DB再作成）
-- ============================================
-- クエリ履歴の影響を完全に排除したい場合は、
-- 以下のコメントを解除して実行してください。
-- 
-- ※ DB再作成後は、テーブルのデータも再ロードが必要です
-- ============================================

/*

-- データベースを削除
DROP DATABASE IF EXISTS sv_handson_db;

-- データベースを再作成
CREATE DATABASE sv_handson_db;
CREATE SCHEMA sv_handson_db.retail;

USE DATABASE sv_handson_db;
USE SCHEMA retail;

-- ファイルフォーマット再作成
CREATE OR REPLACE FILE FORMAT sv_csvformat
  SKIP_HEADER = 1  
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'  
  TYPE = 'CSV';  

-- ステージ再作成
CREATE OR REPLACE STAGE sv_handson_db.retail.sv_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') 
  DIRECTORY = (ENABLE = TRUE)
  FILE_FORMAT = sv_csvformat;

-- Gitからファイルをコピー
COPY FILES INTO @sv_handson_db.retail.sv_stage
  FROM @git_sv_handson/branches/main/data/ 
  PATTERN = '.*\\.csv$';

-- テーブル再作成
CREATE OR REPLACE TABLE products (
  product_id NUMBER(38,0),
  product_name VARCHAR(16777216),
  category VARCHAR(16777216)
);
COPY INTO products FROM @sv_handson_db.retail.sv_stage/products.csv;

CREATE OR REPLACE TABLE sales (
  date DATE,
  region VARCHAR(16777216),
  product_id NUMBER(38,0),
  units_sold NUMBER(38,0),
  sales_amount NUMBER(38,2)
);
COPY INTO sales FROM @sv_handson_db.retail.sv_stage/sales.csv;

CREATE OR REPLACE TABLE marketing_campaign_metrics (
  date DATE,
  category VARCHAR(16777216),
  campaign_name VARCHAR(16777216),
  impressions NUMBER(38,0),
  clicks NUMBER(38,0)
);
COPY INTO marketing_campaign_metrics FROM @sv_handson_db.retail.sv_stage/marketing_campaign_metrics.csv;

CREATE OR REPLACE TABLE social_media (
  date DATE,
  category VARCHAR(16777216),
  platform VARCHAR(16777216),
  influencer VARCHAR(16777216),
  mentions NUMBER(38,0)
);
COPY INTO social_media FROM @sv_handson_db.retail.sv_stage/social_media_mentions.csv;

SELECT '✅ 環境リセット完了。Step 2に進んでください。' AS status;

*/

