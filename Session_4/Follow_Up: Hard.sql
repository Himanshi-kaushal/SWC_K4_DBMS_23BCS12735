WITH cleaned AS (
    SELECT DISTINCT
        task_id,
        start_time,
        end_time
    FROM task_schedule
    WHERE start_time IS NOT NULL
      AND end_time IS NOT NULL
),

events AS (
    SELECT start_time AS time, 1 AS change
    FROM cleaned

    UNION ALL

    SELECT end_time AS time, -1 AS change
    FROM cleaned
),

timeline AS (
    SELECT
        time,
        SUM(change) AS delta
    FROM events
    GROUP BY time
)

SELECT
    MAX(active_tasks) AS min_cpus_required
FROM (
    SELECT
        time,
        SUM(delta) OVER (ORDER BY time) AS active_tasks
    FROM timeline
) t;
