WITH dates AS (
    SELECT generate_series(
        DATE '2025-04-15',
        DATE '2025-04-28',
        INTERVAL '1 day'
    )::date AS transaction_date
),
purchases AS (
    SELECT
        transaction_id,
        transaction_date::date AS transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND status = 'completed'
      AND transaction_type = 'purchase'
      AND transaction_date::date BETWEEN DATE '2025-04-15'
                                     AND DATE '2025-04-28'
),
daily_net AS (
    SELECT
        p.transaction_date,
        SUM(p.amount)
        - COALESCE(SUM(r.amount), 0) AS daily_net_revenue
    FROM purchases p
    LEFT JOIN product_sales r
        ON r.original_transaction_id = p.transaction_id
       AND r.transaction_type = 'refund'
       AND r.status = 'completed'
    GROUP BY p.transaction_date
)
SELECT
    d.transaction_date,
    COALESCE(n.daily_net_revenue, 0) AS daily_net_revenue
FROM dates d
LEFT JOIN daily_net n
    ON d.transaction_date = n.transaction_date
ORDER BY d.transaction_date;
