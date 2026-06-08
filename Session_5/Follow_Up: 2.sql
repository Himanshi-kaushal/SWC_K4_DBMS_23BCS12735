WITH ordered AS (
    SELECT
        transaction_id,
        merchant_id,
        credit_card_id,
        amount,
        transaction_timestamp,
        LAG(transaction_timestamp) OVER (
            PARTITION BY merchant_id, credit_card_id, amount
            ORDER BY transaction_timestamp
        ) AS prev_time
    FROM transactions
)

SELECT
    COUNT(*) AS payment_count
FROM ordered
WHERE prev_time IS NOT NULL
  AND transaction_timestamp - prev_time <= INTERVAL '10 minutes';
