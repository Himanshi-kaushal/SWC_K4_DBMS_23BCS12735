WITH joined AS (
    SELECT
        f.date,
        a.paying_customer,
        f.downloads
    FROM ms_download_facts f
    JOIN ms_user_dimension u
        ON f.user_id = u.user_id
    JOIN ms_acc_dimension a
        ON u.acc_id = a.acc_id
),

agg AS (
    SELECT
        date,
        SUM(CASE WHEN paying_customer = 'yes' THEN downloads ELSE 0 END) AS paying_downloads,
        SUM(CASE WHEN paying_customer = 'no'  THEN downloads ELSE 0 END) AS non_paying_downloads
    FROM joined
    GROUP BY date
)

SELECT
    date,
    non_paying_downloads,
    paying_downloads
FROM agg
WHERE non_paying_downloads > paying_downloads
ORDER BY date;
