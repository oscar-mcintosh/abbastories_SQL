-- Outer query: used to add spend percentage bucket after calculations are complete
SELECT 
    *,
    
    -- Categorize customers based on what % of their total gas spend went to CENEX
    CASE 
        WHEN cenex_spend_pct BETWEEN 1 AND 24 THEN '1 - 25%'
        WHEN cenex_spend_pct BETWEEN 25 AND 49 THEN '25 - 50%'
        WHEN cenex_spend_pct BETWEEN 50 AND 74 THEN '50 - 75%'
        WHEN cenex_spend_pct BETWEEN 75 AND 100 THEN '75 - 100%'
        ELSE '0%'  -- Catch any zero or null percentages
    END AS spend_pct_bucket

FROM (
    -- Inner query: does the actual data grouping and calculation
    SELECT 
        -- Count of unique customers per group
        COUNT(DISTINCT ENT_CUSTOMER_ID) AS members,		

        -- Bucket customers by distance from store
        CASE 
            WHEN dist <= 5 THEN 'Within 5 miles'
            WHEN dist <= 10 THEN '5-10 miles'
            WHEN dist <= 15 THEN '10-15 miles'
            WHEN dist <= 20 THEN '15-20 miles'
            ELSE 'Over 20 miles'
        END AS distance_bucket,

        -- Bucket customers by age
        CASE 
    	    WHEN age < 25 THEN 'Under 25'
	        WHEN age BETWEEN 25 AND 34 THEN '25-34'
	        WHEN age BETWEEN 35 AND 44 THEN '35-44'
	        WHEN age BETWEEN 45 AND 54 THEN '45-54'
	        WHEN age BETWEEN 55 AND 64 THEN '55-64'
	        ELSE '65+'
        END AS age_range,

        -- Retain additional customer attributes for segmentation
        book,
        tob,
        club_mkt_opt_out,
        brand,
        card_tier,

        -- Determine whether transaction is CENEX or NON_CENEX based on presence in merch table
        CASE 
            WHEN c.merch_nk_sk IS NOT NULL THEN 'CENEX' 
            ELSE 'NON_CENEX' 
        END AS gas_type,    

        -- Sum of spend for CENEX transactions
        SUM(CASE WHEN c.merch_nk_sk IS NOT NULL THEN tran_amt END) AS cenex_spend,

        -- Sum of spend for NON-CENEX transactions
        SUM(CASE WHEN c.merch_nk_sk IS NULL THEN tran_amt END) AS non_cenex_spend,

        -- Compute % of total gas spend that went to CENEX
        ROUND(
            SUM(CASE WHEN c.merch_nk_sk IS NOT NULL THEN tran_amt END) 
            / NULLIF(SUM(tran_amt), 0) * 100, 2
        ) AS cenex_spend_pct

    FROM om_cstmrs_zip_20240910 a

    -- Join transaction table to bring in customer gas transaction history
    JOIN edw_spoke..fact_club_cc_tran b 
    	ON a.club_acct_nk_sk = b.club_acct_nk_sk

    -- Join to merch table to determine if the merchant is a CENEX location
    LEFT JOIN edw_spoke..dim_merch c
        ON b.merch_nk_sk = c.merch_nk_sk 
        AND b.post_dte BETWEEN c.strt_dte AND COALESCE(c.end_dte, CURRENT_DATE)
        AND c.member_type = 'PROMOTIONAL'

    -- Filter to only gas debit transactions over 5 years
    WHERE b.tran_typ_cd = 'DBT'
      AND b.merch_mcc IN ('5542', '5541')  -- MCC codes for gas
      AND b.post_dte BETWEEN '2019-09-13' AND '2024-09-13'

    -- Group by all categorical fields that define each segment
    GROUP BY 
        2, 3, 4, 5, 6, 7, 8, gas_type

) x  -- End of subquery

-- Sort output by proximity and age
ORDER BY distance_bucket, age_range;
