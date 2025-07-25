-- Define campaign dates and promotion ID
WITH campaign_dates AS (
    SELECT 
        DATE '2024-09-19' AS start_date,
        DATE '2024-10-02' AS end_date
),
promotion_points AS (
    SELECT 
        ROUND(SUM(pnt_amt), 0) AS points,
        club_acct_nk_sk,
        inbound_interaction_key,
        pnt_log_cmnt
    FROM edw_spoke.nz.fact_club_pnt_ldgr
    WHERE pnt_log_cmnt = 'PROMOTION ID: 4874'
    GROUP BY club_acct_nk_sk, inbound_interaction_key, pnt_log_cmnt
),
sales_data AS (
    SELECT 
        CAST(b.transaction_datetime AS DATE) AS saledate,
        a.club_acct_nk_sk,
        COALESCE(e.store_brand, d.store_brand) AS store_brand,
        a.pnt_log_cmnt,
        a.inbound_interaction_key,
        ROUND(SUM(c.sales_price), 0) AS sales,
        ROUND(SUM(c.cost), 0) AS cogs,
        a.points,
        d.store_number,
        d.store_name,
        b.club_mdm_persona_member_key
    FROM promotion_points a
    JOIN edw_spoke.nz.fact_bps_sales_header b 
        ON a.inbound_interaction_key = b.inbound_interaction_key
    JOIN campaign_dates cd
        ON EXTRACT(YEAR FROM b.transaction_datetime) = EXTRACT(YEAR FROM cd.end_date)
    JOIN edw_spoke.nz.fact_bps_sales_detail c 
        ON b.inbound_interaction_key = c.sh_inbound_interaction_key
    JOIN edw_spoke.nz.dim_store d 
        ON b.store_member_key = d.member_key
    LEFT JOIN edw_spoke.nz.lu_store_brand_xref e 
        ON d.store_number = e.store_number AND e.end_dte IS NULL
    GROUP BY 
        saledate, a.club_acct_nk_sk, store_brand, a.pnt_log_cmnt, 
        a.inbound_interaction_key, a.points, d.store_number, 
        d.store_name, b.club_mdm_persona_member_key
)

-- Final materialized temp table
CREATE TEMP TABLE trans_kpis AS
SELECT * FROM sales_data;



