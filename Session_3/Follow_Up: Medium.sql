SELECT
    customer_id,
    SUM(revenue) AS total_revenue
FROM orders
WHERE transaction_date >= DATE '2019-03-01'
  AND transaction_date <  DATE '2019-04-01'
GROUP BY customer_id
ORDER BY total_revenue DESC;
