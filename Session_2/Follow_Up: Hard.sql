WITH max_dt AS (
    SELECT MAX(event_time) AS max_time
    FROM search_events
),
user_segment AS (
    SELECT
        a.user_id,
        a.signup_date,
        CASE
            WHEN a.signup_date >= (m.max_time::date - INTERVAL '30 days')
            THEN 'new'
            ELSE 'existing'
        END AS segment
    FROM accounts a
    CROSS JOIN max_dt m
),
searches AS (
    SELECT
        s.search_id,
        s.user_id,
        s.event_time AS search_time
    FROM search_events s
    WHERE s.event_type = 'search'
),
first_click AS (
    SELECT
        c.search_id,
        MIN(c.event_time) AS first_click_time
    FROM search_events c
    WHERE c.event_type = 'click'
    GROUP BY c.search_id
),
search_analysis AS (
    SELECT
        s.user_id,
        s.search_time,
        fc.first_click_time,
        CASE
            WHEN fc.first_click_time IS NOT NULL
             AND fc.first_click_time <= s.search_time + INTERVAL '30 seconds'
            THEN 1 ELSE 0
        END AS is_success
    FROM searches s
    LEFT JOIN first_click fc
        ON s.search_id = fc.search_id
)
SELECT
    us.segment,
    COUNT(*) AS total_searches,
    SUM(sa.is_success) AS successful_searches,
    ROUND(
        SUM(sa.is_success)::numeric / COUNT(*),
        2
    ) AS success_rate
FROM search_analysis sa
JOIN user_segment us
    ON sa.user_id = us.user_id
GROUP BY us.segment;
