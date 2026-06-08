WITH monthly AS (
    SELECT
        product_id,
        DATE_TRUNC('month', event_date)::date AS month,
        COUNT(DISTINCT user_id) AS mau
    FROM product_engagement
    GROUP BY 1, 2
),

ordered AS (
    SELECT
        product_id,
        month,
        mau,
        LAG(mau, 1) OVER (PARTITION BY product_id ORDER BY month) AS prev1,
        LAG(mau, 2) OVER (PARTITION BY product_id ORDER BY month) AS prev2,
        LAG(mau, 3) OVER (PARTITION BY product_id ORDER BY month) AS prev3,
        LEAD(mau, 1) OVER (PARTITION BY product_id ORDER BY month) AS next1,
        LEAD(mau, 2) OVER (PARTITION BY product_id ORDER BY month) AS next2,
        LEAD(mau, 3) OVER (PARTITION BY product_id ORDER BY month) AS next3
    FROM monthly
),

signals AS (
    SELECT
        *,
        CASE
            WHEN prev2 > prev1 AND prev1 > mau
             AND prev3 > prev2 AND prev2 > prev1
            THEN 1 ELSE 0
        END AS decline_end_flag,

        CASE
            WHEN next1 > mau AND next2 > next1 AND next3 > next2
            THEN 1 ELSE 0
        END AS growth_start_flag
    FROM ordered
),

events AS (
    SELECT
        product_id,
        month,
        mau,
        MIN(month) FILTER (WHERE decline_end_flag = 1)
            OVER (PARTITION BY product_id) AS decline_end_month,
        MIN(month) FILTER (WHERE growth_start_flag = 1)
            OVER (PARTITION BY product_id) AS growth_start_month
    FROM signals
),

filtered AS (
    SELECT *
    FROM events
    WHERE decline_end_month IS NOT NULL
      AND growth_start_month IS NOT NULL
)

SELECT DISTINCT
    p.name AS product_name,
    f.decline_end_month,
    f.growth_start_month,
    ROUND(
        (MAX(mau) OVER (PARTITION BY product_id) -
         MIN(mau) OVER (PARTITION BY product_id))::numeric
        / NULLIF(MIN(mau) OVER (PARTITION BY product_id), 0),
        2
    ) AS growth_ratio
FROM filtered f
JOIN products p
    ON p.product_id = f.product_id;
