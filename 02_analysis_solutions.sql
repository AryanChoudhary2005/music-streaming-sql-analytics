/*
======================================================================
MYSQL DATA ANALYTICS PROJECT — SOLUTIONS
Music Streaming / Sparkify Dataset
MySQL 8.0+
======================================================================

Tables:
    events
    songs

Important:
    Song play = events.page = 'NextSong'
    Join:
        events.artist = songs.artist_name
        AND events.song = songs.title

Note:
    Q17 thresholds are assumed because the question does not specify
    exact thresholds:
        Heavy   >= 100 plays
        Regular >= 50 plays
        Light   < 50 plays
======================================================================
*/

USE sparkify;


/* ================================================================
   Q1. Total song plays for every artist
   ================================================================ */
SELECT
    s.artist_name,
    COUNT(*) AS total_song_plays
FROM events e
JOIN songs s
    ON e.artist = s.artist_name
    AND e.song = s.title
WHERE e.page = 'NextSong'
GROUP BY s.artist_name
ORDER BY total_song_plays DESC;


/* ================================================================
   Q2. Top 10 songs by number of plays
   ================================================================ */
SELECT
    s.title,
    s.artist_name,
    COUNT(*) AS total_plays
FROM events e
JOIN songs s
    ON e.artist = s.artist_name
    AND e.song = s.title
WHERE e.page = 'NextSong'
GROUP BY s.title, s.artist_name
ORDER BY total_plays DESC
LIMIT 10;


/* ================================================================
   Q3. Total listening time in minutes for every artist
   events.length is in seconds.
   ================================================================ */
SELECT
    s.artist_name,
    SUM(e.length) / 60 AS total_listening_minutes
FROM events e
JOIN songs s
    ON e.artist = s.artist_name
    AND e.song = s.title
WHERE e.page = 'NextSong'
GROUP BY s.artist_name
ORDER BY total_listening_minutes DESC;


/* ================================================================
   Q4. Users who listened to at least one song released after 2010
   ================================================================ */
SELECT DISTINCT
    e.userId
FROM events e
JOIN songs s
    ON e.artist = s.artist_name
    AND e.song = s.title
WHERE e.page = 'NextSong'
  AND s.year > 2010;


/* ================================================================
   Q5. Compare paid and free users by number of song plays
   ================================================================ */
SELECT
    e.level,
    COUNT(*) AS total_song_plays
FROM events e
WHERE e.page = 'NextSong'
GROUP BY e.level
ORDER BY total_song_plays DESC;


/* ================================================================
   Q6. Most popular song for every subscription level
   ================================================================ */
WITH song_plays AS (
    SELECT
        e.level,
        s.title,
        s.artist_name,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY e.level, s.title, s.artist_name
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY level
            ORDER BY total_plays DESC
        ) AS rn
    FROM song_plays
)
SELECT
    level,
    title,
    artist_name,
    total_plays
FROM ranked
WHERE rn = 1;


/* ================================================================
   Q7. Rank artists by total song plays using RANK()
   ================================================================ */
WITH artist_plays AS (
    SELECT
        s.artist_name,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY s.artist_name
)
SELECT
    artist_name,
    total_plays,
    RANK() OVER (
        ORDER BY total_plays DESC
    ) AS artist_rank
FROM artist_plays
ORDER BY artist_rank, artist_name;


/* ================================================================
   Q8. Rank songs within each subscription level using DENSE_RANK()
   ================================================================ */
WITH song_plays AS (
    SELECT
        e.level,
        s.title,
        s.artist_name,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY e.level, s.title, s.artist_name
)
SELECT
    level,
    title,
    artist_name,
    total_plays,
    DENSE_RANK() OVER (
        PARTITION BY level
        ORDER BY total_plays DESC
    ) AS song_rank
FROM song_plays
ORDER BY level, song_rank;


/* ================================================================
   Q9. Top 3 artists by plays in each subscription level using ROW_NUMBER()
   ================================================================ */
WITH artist_plays AS (
    SELECT
        e.level,
        s.artist_name,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY e.level, s.artist_name
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY level
            ORDER BY total_plays DESC
        ) AS rn
    FROM artist_plays
)
SELECT
    level,
    artist_name,
    total_plays,
    rn AS artist_rank
FROM ranked
WHERE rn <= 3
ORDER BY level, artist_rank;


/* ================================================================
   Q10. Number song-play events chronologically for every user
   ================================================================ */
SELECT
    userId,
    ts,
    artist,
    song,
    ROW_NUMBER() OVER (
        PARTITION BY userId
        ORDER BY ts
    ) AS play_number
FROM events
WHERE page = 'NextSong'
ORDER BY userId, play_number;


/* ================================================================
   Q11. Time in minutes between consecutive song plays for each user
   ts is Unix timestamp in milliseconds.
   ================================================================ */
WITH previous_plays AS (
    SELECT
        userId,
        ts,
        artist,
        song,
        LAG(ts) OVER (
            PARTITION BY userId
            ORDER BY ts
        ) AS previous_ts
    FROM events
    WHERE page = 'NextSong'
)
SELECT
    userId,
    artist,
    song,
    ts,
    previous_ts,
    (ts - previous_ts) / 1000 / 60 AS minutes_since_previous_play
FROM previous_plays
ORDER BY userId, ts;


/* ================================================================
   Q12. Cumulative listening time for every user over time
   ================================================================ */
SELECT
    userId,
    ts,
    artist,
    song,
    length,
    SUM(length) OVER (
        PARTITION BY userId
        ORDER BY ts
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / 60 AS cumulative_listening_minutes
FROM events
WHERE page = 'NextSong'
ORDER BY userId, ts;


/* ================================================================
   Q13. Each user's percentage contribution to total song plays
   ================================================================ */
WITH user_plays AS (
    SELECT
        userId,
        COUNT(*) AS total_plays
    FROM events
    WHERE page = 'NextSong'
    GROUP BY userId
)
SELECT
    userId,
    total_plays,
    ROUND(
        total_plays * 100.0 /
        SUM(total_plays) OVER (),
        2
    ) AS percentage_of_total_plays
FROM user_plays
ORDER BY percentage_of_total_plays DESC;


/* ================================================================
   Q14. Each user's most-played song using ROW_NUMBER()
   ================================================================ */
WITH song_plays AS (
    SELECT
        e.userId,
        s.title,
        s.artist_name,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY e.userId, s.title, s.artist_name
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY userId
            ORDER BY total_plays DESC
        ) AS rn
    FROM song_plays
)
SELECT
    userId,
    title,
    artist_name,
    total_plays
FROM ranked
WHERE rn = 1
ORDER BY userId;


/* ================================================================
   Q15. Most popular song for each song-release year using RANK()
   ================================================================ */
WITH song_plays AS (
    SELECT
        s.year,
        s.title,
        s.artist_name,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY s.year, s.title, s.artist_name
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY year
            ORDER BY total_plays DESC
        ) AS song_rank
    FROM song_plays
)
SELECT
    year,
    title,
    artist_name,
    total_plays,
    song_rank
FROM ranked
WHERE song_rank = 1
ORDER BY year;


/* ================================================================
   Q16. Current song length vs previous song length using LAG()
   ================================================================ */
SELECT
    userId,
    ts,
    song,
    length AS current_song_length,
    LAG(length) OVER (
        PARTITION BY userId
        ORDER BY ts
    ) AS previous_song_length,
    length - LAG(length) OVER (
        PARTITION BY userId
        ORDER BY ts
    ) AS length_difference
FROM events
WHERE page = 'NextSong'
ORDER BY userId, ts;


/* ================================================================
   Q17. Classify users as Heavy, Regular, or Light listeners
   Assumed thresholds:
       Heavy   >= 100
       Regular >= 50
       Light   < 50
   ================================================================ */
WITH user_plays AS (
    SELECT
        userId,
        COUNT(*) AS total_plays
    FROM events
    WHERE page = 'NextSong'
    GROUP BY userId
)
SELECT
    userId,
    total_plays,
    CASE
        WHEN total_plays >= 100 THEN 'Heavy'
        WHEN total_plays >= 50 THEN 'Regular'
        ELSE 'Light'
    END AS listener_type
FROM user_plays
ORDER BY total_plays DESC;


/* ================================================================
   Q18. Top 10 users by total listening minutes using CTE
   ================================================================ */
WITH user_listening AS (
    SELECT
        userId,
        SUM(length) / 60 AS total_listening_minutes
    FROM events
    WHERE page = 'NextSong'
    GROUP BY userId
)
SELECT
    userId,
    total_listening_minutes
FROM user_listening
ORDER BY total_listening_minutes DESC
LIMIT 10;


/* ================================================================
   Q19. Daily song plays and days with above-average activity
   ================================================================ */
WITH daily_plays AS (
    SELECT
        DATE(FROM_UNIXTIME(ts / 1000)) AS play_date,
        COUNT(*) AS total_plays
    FROM events
    WHERE page = 'NextSong'
    GROUP BY DATE(FROM_UNIXTIME(ts / 1000))
),
average_activity AS (
    SELECT
        AVG(total_plays) AS avg_daily_plays
    FROM daily_plays
)
SELECT
    d.play_date,
    d.total_plays,
    a.avg_daily_plays
FROM daily_plays d
CROSS JOIN average_activity a
WHERE d.total_plays > a.avg_daily_plays
ORDER BY d.play_date;


/* ================================================================
   Q20. Unique users, total plays and plays per user for each level
   ================================================================ */
WITH subscription_stats AS (
    SELECT
        level,
        COUNT(DISTINCT userId) AS unique_users,
        COUNT(*) AS total_plays
    FROM events
    WHERE page = 'NextSong'
    GROUP BY level
)
SELECT
    level,
    unique_users,
    total_plays,
    ROUND(
        total_plays * 1.0 / unique_users,
        2
    ) AS plays_per_user
FROM subscription_stats
ORDER BY level;


/* ================================================================
   Q21. Monthly song plays and month with highest activity
   ================================================================ */
WITH monthly_plays AS (
    SELECT
        DATE_FORMAT(
            FROM_UNIXTIME(ts / 1000),
            '%Y-%m'
        ) AS play_month,
        COUNT(*) AS total_plays
    FROM events
    WHERE page = 'NextSong'
    GROUP BY DATE_FORMAT(
        FROM_UNIXTIME(ts / 1000),
        '%Y-%m'
    )
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY total_plays DESC
        ) AS month_rank
    FROM monthly_plays
)
SELECT
    play_month,
    total_plays,
    month_rank
FROM ranked
WHERE month_rank = 1;


/* ================================================================
   Q22. Plays by song-release year and above-average years
   ================================================================ */
WITH yearly_plays AS (
    SELECT
        s.year,
        COUNT(*) AS total_plays
    FROM events e
    JOIN songs s
        ON e.artist = s.artist_name
        AND e.song = s.title
    WHERE e.page = 'NextSong'
    GROUP BY s.year
),
average_plays AS (
    SELECT
        AVG(total_plays) AS avg_yearly_plays
    FROM yearly_plays
)
SELECT
    y.year,
    y.total_plays,
    a.avg_yearly_plays
FROM yearly_plays y
CROSS JOIN average_plays a
WHERE y.total_plays > a.avg_yearly_plays
ORDER BY y.year;


/* ================================================================
   Q23. Users whose total song plays > average plays per user
   ================================================================ */
SELECT
    userId,
    COUNT(*) AS total_plays
FROM events
WHERE page = 'NextSong'
GROUP BY userId
HAVING COUNT(*) > (
    SELECT AVG(user_plays)
    FROM (
        SELECT
            userId,
            COUNT(*) AS user_plays
        FROM events
        WHERE page = 'NextSong'
        GROUP BY userId
    ) AS x
)
ORDER BY total_plays DESC;


/* ================================================================
   Q24. Songs whose plays > average plays across all played songs
   ================================================================ */
SELECT
    e.song,
    e.artist,
    COUNT(*) AS total_plays
FROM events e
WHERE e.page = 'NextSong'
GROUP BY e.song, e.artist
HAVING COUNT(*) > (
    SELECT AVG(song_plays)
    FROM (
        SELECT
            song,
            artist,
            COUNT(*) AS song_plays
        FROM events
        WHERE page = 'NextSong'
        GROUP BY song, artist
    ) AS x
)
ORDER BY total_plays DESC;


/* ================================================================
   Q25. User with highest total listening time using a subquery
   ================================================================ */
SELECT
    userId,
    SUM(length) / 60 AS total_listening_minutes
FROM events
WHERE page = 'NextSong'
GROUP BY userId
HAVING SUM(length) = (
    SELECT MAX(total_length)
    FROM (
        SELECT
            userId,
            SUM(length) AS total_length
        FROM events
        WHERE page = 'NextSong'
        GROUP BY userId
    ) AS x
);


/* ================================================================
   Q26. Artists whose plays > average artist play count
   ================================================================ */
SELECT
    e.artist,
    COUNT(*) AS total_plays
FROM events e
WHERE e.page = 'NextSong'
GROUP BY e.artist
HAVING COUNT(*) > (
    SELECT AVG(artist_plays)
    FROM (
        SELECT
            artist,
            COUNT(*) AS artist_plays
        FROM events
        WHERE page = 'NextSong'
        GROUP BY artist
    ) AS x
)
ORDER BY total_plays DESC;


/* ================================================================
   Q27. Users who listened to more distinct songs than average user
   ================================================================ */
SELECT
    userId,
    COUNT(DISTINCT song) AS distinct_songs
FROM events
WHERE page = 'NextSong'
GROUP BY userId
HAVING COUNT(DISTINCT song) > (
    SELECT AVG(distinct_song_count)
    FROM (
        SELECT
            userId,
            COUNT(DISTINCT song) AS distinct_song_count
        FROM events
        WHERE page = 'NextSong'
        GROUP BY userId
    ) AS x
)
ORDER BY distinct_songs DESC;


/* ================================================================
   Q28. Songs with release year > average release year
        that were actually played
   ================================================================ */
SELECT DISTINCT
    s.title,
    s.artist_name,
    s.year
FROM events e
JOIN songs s
    ON e.artist = s.artist_name
    AND e.song = s.title
WHERE e.page = 'NextSong'
  AND s.year > (
      SELECT AVG(year)
      FROM songs
      WHERE year > 0
  )
ORDER BY s.year DESC;
