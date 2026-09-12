# 🎵 Music Streaming SQL Analytics — Sparkify

A MySQL 8.0+ data analytics project based on the **Sparkify music streaming dataset**.

The project analyzes user listening behavior, songs, artists, subscription levels, listening time, and activity trends using SQL.

---

## 📌 Project Overview

This project contains **28 SQL analytics questions** designed to practice and demonstrate:

- JOINs
- Aggregations
- GROUP BY / HAVING
- Subqueries
- CTEs
- Window Functions
- RANK()
- DENSE_RANK()
- ROW_NUMBER()
- LAG()
- Date & time conversion
- User-level and song-level analytics
- Business-style insights

The dataset consists of two tables:

```text
events
songs
```

---

## 🗂️ Repository Structure

```text
music-streaming-sql-analytics/
│
├── 01_database_setup.sql
├── 02_analysis_solutions.sql
└── README.md
```

### `01_database_setup.sql`

Creates the `sparkify` database, creates the `events` and `songs` tables, and inserts the complete dataset.

### `02_analysis_solutions.sql`

Contains the complete solutions for all **28 analytics questions**, organized question-by-question with comments.

---

## 🛢️ Database Schema

### `events`

| Column | Description |
|---|---|
| `artist` | Artist name |
| `auth` | Authentication status |
| `firstName` | User first name |
| `gender` | User gender |
| `itemInSession` | Item number within session |
| `lastName` | User last name |
| `length` | Song listening length in seconds |
| `level` | Subscription level (`free` / `paid`) |
| `location` | User location |
| `method` | HTTP method |
| `page` | Event/page type |
| `registration` | User registration timestamp |
| `sessionId` | Session ID |
| `song` | Song title |
| `status` | HTTP status |
| `ts` | Event timestamp in milliseconds |
| `userAgent` | User agent |
| `userId` | User ID |

### `songs`

| Column | Description |
|---|---|
| `artist_id` | Artist ID |
| `artist_latitude` | Artist latitude |
| `artist_location` | Artist location |
| `artist_longitude` | Artist longitude |
| `artist_name` | Artist name |
| `duration` | Song duration |
| `num_songs` | Number of songs |
| `song_id` | Song ID |
| `title` | Song title |
| `year` | Song release year |

---

## 🔗 Join Logic

The `events` and `songs` tables are joined using:

```sql
e.artist = s.artist_name
AND e.song = s.title
```

A song play is represented by:

```sql
e.page = 'NextSong'
```

Therefore, most listening analytics use:

```sql
WHERE e.page = 'NextSong'
```

---

## ⏱️ Timestamp Handling

`events.ts` is stored as a Unix timestamp in **milliseconds**.

For date conversion:

```sql
DATE(FROM_UNIXTIME(ts / 1000))
```

For monthly analysis:

```sql
DATE_FORMAT(FROM_UNIXTIME(ts / 1000), '%Y-%m')
```

Listening length is stored in seconds, so minutes are calculated using:

```sql
SUM(length) / 60
```

---

## 📊 Questions Covered

### 🔹 JOINs & Aggregations

- Q1 — Total song plays for every artist
- Q2 — Top 10 songs by plays
- Q3 — Total listening time by artist
- Q4 — Users who listened to songs released after 2010
- Q5 — Paid vs free song plays
- Q6 — Most popular song by subscription level

### 🔹 Window Functions

- Q7 — Artist ranking using `RANK()`
- Q8 — Song ranking by subscription using `DENSE_RANK()`
- Q9 — Top 3 artists per subscription using `ROW_NUMBER()`
- Q10 — Chronological song-play numbering per user
- Q11 — Time between consecutive plays using `LAG()`
- Q12 — Cumulative listening time
- Q13 — User contribution to total plays
- Q14 — Most-played song per user
- Q15 — Most popular song by release year
- Q16 — Current vs previous song length using `LAG()`

### 🔹 CTEs

- Q17 — Heavy / Regular / Light listener classification
- Q18 — Top 10 users by listening time
- Q19 — Above-average daily activity
- Q20 — Subscription-level user and play statistics
- Q21 — Month with highest activity
- Q22 — Release years with above-average plays

### 🔹 Subqueries

- Q23 — Users above average plays per user
- Q24 — Songs above average song plays
- Q25 — User with highest listening time
- Q26 — Artists above average artist plays
- Q27 — Users above average distinct songs
- Q28 — Played songs released after the average release year

---

## 🧠 SQL Concepts Demonstrated

This project demonstrates practical use of:

```text
SELECT
WHERE
GROUP BY
HAVING
ORDER BY
JOIN
DISTINCT
CASE
CTE (WITH)
Subqueries
RANK()
DENSE_RANK()
ROW_NUMBER()
LAG()
SUM() OVER()
COUNT()
COUNT(DISTINCT)
AVG()
MAX()
DATE()
DATE_FORMAT()
FROM_UNIXTIME()
```

---

## 🚀 How to Run the Project

### 1. Open MySQL Workbench

Make sure you have **MySQL 8.0+** installed.

### 2. Run the database setup

Open:

```text
01_database_setup.sql
```

Run the complete script.

It will:

1. Create the `sparkify` database
2. Create the `events` table
3. Create the `songs` table
4. Insert the dataset

### 3. Select the database

```sql
USE sparkify;
```

### 4. Verify the data

```sql
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM songs;
```

Expected row counts:

```text
events → 8056
songs  → 79
```

### 5. Run the analytics

Open:

```text
02_analysis_solutions.sql
```

Each question is separated with a clear heading, so queries can be executed individually.

---

## 📈 Project Goal

The goal of this project is to use SQL to turn raw music-streaming event data into useful analytical insights, such as:

- Which artists receive the most plays?
- Which songs are most popular?
- How do paid and free users differ?
- Who are the most active listeners?
- What are the busiest days and months?
- Which songs perform above average?
- How does listening behavior vary between users?

---

## 🛠️ Tools Used

- **MySQL 8.0+**
- **MySQL Workbench**
- SQL
- CSV dataset

---

## 👤 Author

**Aryan Choudhary**

This project was created as part of SQL/data analytics practice, with a focus on writing practical analytical queries using MySQL.
