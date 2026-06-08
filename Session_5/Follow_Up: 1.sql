WITH monthly_users AS (
    SELECT
        user_id,
        DATE_TRUNC('month', event_date)::date AS month
    FROM user_actions
    WHERE event_type IN ('sign-in', 'like', 'comment')
    GROUP BY user_id, DATE_TRUNC('month', event_date)
),

july_users AS (
    SELECT user_id
    FROM monthly_users
    WHERE month = DATE '2022-07-01'
),

june_users AS (
    SELECT user_id
    FROM monthly_users
    WHERE month = DATE '2022-06-01'
)

SELECT
    7 AS month,
    COUNT(*) AS monthly_active_users
FROM july_users j
JOIN june_users u
    ON j.user_id = u.user_id;
