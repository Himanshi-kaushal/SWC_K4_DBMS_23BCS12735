WITH first_purchase AS (
    SELECT
        user_id,
        MIN(created_at) AS first_purchase_date
    FROM amazon_transactions
    GROUP BY user_id
)
SELECT DISTINCT
    t.user_id
FROM amazon_transactions t
JOIN first_purchase f
    ON t.user_id = f.user_id
WHERE t.created_at > f.first_purchase_date
  AND t.created_at <= f.first_purchase_date + INTERVAL '7 days'
ORDER BY t.user_id;
