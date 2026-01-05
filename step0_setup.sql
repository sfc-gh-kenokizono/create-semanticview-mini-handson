-- ============================================
-- Step 0: 環境のセットアップ
-- ============================================
-- このハンズオン用のロール、データベース、ウェアハウスを作成し、
-- サンプルデータをロードします。
-- ============================================

USE ROLE ACCOUNTADMIN;

-- ============================================
-- ACCOUNTADMINで実行が必要な部分
-- ============================================

-- ロールの作成と権限付与
CREATE OR REPLACE ROLE semantic_view_handson_role;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE semantic_view_handson_role;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE semantic_view_handson_role;

-- 現在のユーザーにロールを付与
SET current_user = (SELECT CURRENT_USER());   
GRANT ROLE semantic_view_handson_role TO USER IDENTIFIER($current_user);

-- Git連携のAPI統合を作成（ACCOUNTADMINが必要）
CREATE OR REPLACE API INTEGRATION git_api_integration_sv
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-kenokizono/')
  ENABLED = TRUE;

-- Cortexクロスリージョン設定（AI支援機能を使うために必要）
-- トライアルアカウントのリージョンによってはこの設定が必要です
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';

-- ============================================
-- ここからはハンズオン用ロールで実行
-- ============================================

USE ROLE semantic_view_handson_role;

-- データベース・スキーマ・ウェアハウスの作成
CREATE OR REPLACE DATABASE sv_handson_db;
CREATE OR REPLACE SCHEMA retail;
CREATE OR REPLACE WAREHOUSE sv_handson_wh WITH WAREHOUSE_SIZE = 'XSMALL';

USE DATABASE sv_handson_db;
USE SCHEMA retail;
USE WAREHOUSE sv_handson_wh;

-- CSVファイルフォーマットの作成
CREATE OR REPLACE FILE FORMAT sv_csvformat
  SKIP_HEADER = 1  
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'  
  TYPE = 'CSV';  

-- GIT統合の作成（このリポジトリを参照）
CREATE OR REPLACE GIT REPOSITORY git_sv_handson
  API_INTEGRATION = git_api_integration_sv
  ORIGIN = 'https://github.com/sfc-gh-kenokizono/create-semanticview-mini-handson.git';

-- リポジトリの確認
LS @git_sv_handson/branches/main;

-- ステージの作成
CREATE OR REPLACE STAGE sv_handson_db.retail.sv_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') 
  DIRECTORY = (ENABLE = TRUE)
  FILE_FORMAT = sv_csvformat;

-- Gitからファイルをコピー
COPY FILES INTO @sv_handson_db.retail.sv_stage
  FROM @git_sv_handson/branches/main/data/ 
  PATTERN = '.*\\.csv$';

-- ============================================
-- テーブル作成とデータロード（4テーブル）
-- ============================================

-- [1/4] PRODUCTS: 製品マスタ
-- 商品ID、商品名、カテゴリの製品情報
-- ※ PRIMARY KEY はセマンティックビューのリレーションシップで参照される側に必要
CREATE OR REPLACE TABLE products (
  product_id NUMBER(38,0) PRIMARY KEY,
  product_name VARCHAR(16777216),
  category VARCHAR(16777216)
);
COPY INTO products FROM @sv_handson_db.retail.sv_stage/products.csv;

-- [2/4] SALES: 売上データ
-- 日付、地域、商品ごとの販売数量と売上金額
CREATE OR REPLACE TABLE sales (
  date DATE,
  region VARCHAR(16777216),
  product_id NUMBER(38,0),
  units_sold NUMBER(38,0),
  sales_amount NUMBER(38,2)
);
COPY INTO sales FROM @sv_handson_db.retail.sv_stage/sales.csv;

-- [3/4] MARKETING_CAMPAIGN_METRICS: マーケティングキャンペーン指標
-- インプレッション数、クリック数などのキャンペーン効果を記録
-- ※ CATEGORYを論理的な主キーとして設定（SOCIAL_MEDIAとの結合用）
-- ※ Snowflakeの主キー制約はインフォメーショナル（一意性は強制されない）
CREATE OR REPLACE TABLE marketing_campaign_metrics (
  date DATE,
  category VARCHAR(16777216) PRIMARY KEY,
  campaign_name VARCHAR(16777216),
  impressions NUMBER(38,0),
  clicks NUMBER(38,0)
);
COPY INTO marketing_campaign_metrics FROM @sv_handson_db.retail.sv_stage/marketing_campaign_metrics.csv;

-- [4/4] SOCIAL_MEDIA: ソーシャルメディア指標
-- プラットフォーム別、インフルエンサー別のメンション数
CREATE OR REPLACE TABLE social_media (
  date DATE,
  category VARCHAR(16777216),
  platform VARCHAR(16777216),
  influencer VARCHAR(16777216),
  mentions NUMBER(38,0)
);
COPY INTO social_media FROM @sv_handson_db.retail.sv_stage/social_media_mentions.csv;

-- ============================================
-- データ確認
-- ============================================

-- 各テーブルの行数を確認
SELECT 'PRODUCTS' AS table_name, COUNT(*) AS row_count FROM products
UNION ALL
SELECT 'SALES', COUNT(*) FROM sales
UNION ALL
SELECT 'MARKETING_CAMPAIGN_METRICS', COUNT(*) FROM marketing_campaign_metrics
UNION ALL
SELECT 'SOCIAL_MEDIA', COUNT(*) FROM social_media;

-- サンプルデータの確認
SELECT * FROM products LIMIT 5;
SELECT * FROM sales LIMIT 5;
SELECT * FROM marketing_campaign_metrics LIMIT 5;
SELECT * FROM social_media LIMIT 5;

-- ============================================
-- セットアップ完了
-- ============================================
SELECT '✅ Step 0 セットアップ完了！Step 1に進んでください。' AS status;


-- ============================================
-- 【参考】環境リセット用SQL
-- ============================================
-- Step 1完了後、Step 2の前に実行してください。
-- クエリ履歴をクリアするためにDBを再作成します。
-- ============================================

/*

-- 環境リセット（Step 1完了後に実行）
USE ROLE semantic_view_handson_role;

-- セマンティックビューの削除（作成していた場合）
DROP SEMANTIC VIEW IF EXISTS sv_handson_db.retail.retail_analytics_manual_sv;

-- データベースを再作成（クエリ履歴をクリア）
DROP DATABASE IF EXISTS sv_handson_db;
CREATE DATABASE sv_handson_db;
CREATE SCHEMA retail;

USE DATABASE sv_handson_db;
USE SCHEMA retail;

-- ステージとデータを再作成
CREATE OR REPLACE STAGE sv_handson_db.retail.sv_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE') 
  DIRECTORY = (ENABLE = TRUE)
  FILE_FORMAT = sv_csvformat;

COPY FILES INTO @sv_handson_db.retail.sv_stage
  FROM @git_sv_handson/branches/main/data/ 
  PATTERN = '.*\\.csv$';

-- テーブル再作成（上記のCREATE TABLE文を再実行）

*/


-- ============================================
-- 【参考】クリーンアップ用SQL
-- ============================================
-- ハンズオン終了後、すべてのリソースを削除する場合
-- ============================================

/*

USE ROLE ACCOUNTADMIN;

DROP DATABASE IF EXISTS sv_handson_db;
DROP WAREHOUSE IF EXISTS sv_handson_wh;
DROP API INTEGRATION IF EXISTS git_api_integration_sv;
DROP ROLE IF EXISTS semantic_view_handson_role;

SELECT '🧹 クリーンアップ完了！' AS status;

*/

