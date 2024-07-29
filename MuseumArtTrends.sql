
--Question 1-A: What museums have the highest proportion of cubist paintings? 


-- Step 1: Looking at the number of Cubist paintings per museum
WITH CubistCount AS (
    SELECT museum_id, COUNT(*) AS cubist_paintings
    FROM public.work
    WHERE style = 'Cubism'
    GROUP BY museum_id
),
-- Step 2: Looking at  the total number of paintings per museum
TotalPaintings AS (
    SELECT museum_id, COUNT(*) AS total_paintings
    FROM public.work
    GROUP BY museum_id
),
-- Step 3: Looking at  the proportion of Cubist paintings
ProportionCubism AS (
    SELECT c.museum_id, (c.cubist_paintings::DECIMAL / t.total_paintings) AS proportion
    FROM CubistCount c
    JOIN TotalPaintings t ON c.museum_id = t.museum_id
)
-- Step 4: Looking at museums with the highest proportion of Cubist paintings
SELECT m.name AS museum_name, p.proportion
FROM ProportionCubism p
JOIN public.museum m ON p.museum_id = m.museum_id
ORDER BY p.proportion DESC
LIMIT 10;



--Question 1-B: What other styles of art do these museums typically display?


WITH CubistCount AS (
    SELECT museum_id, COUNT(*) AS cubist_paintings
    FROM public.work
    WHERE style = 'Cubism'
    GROUP BY museum_id
),
TotalPaintings AS (
    SELECT museum_id, COUNT(*) AS total_paintings
    FROM public.work
    GROUP BY museum_id
),
ProportionCubism AS (
    SELECT c.museum_id, (c.cubist_paintings::DECIMAL / t.total_paintings) AS proportion
    FROM CubistCount c
    JOIN TotalPaintings t ON c.museum_id = t.museum_id
)
-- looking at other art styles displayed by these museums
SELECT DISTINCT m.name AS museum_name, w.style
FROM ProportionCubism pc
JOIN public.work w ON pc.museum_id = w.museum_id
JOIN public.museum m ON pc.museum_id = m.museum_id
ORDER BY m.name, w.style;


--Question 2- Which artists have their work displayed in museums in many different countries?


-- Looking at numbers of countries per artist

SELECT a.full_name AS artist_name, COUNT(DISTINCT mu.country) AS country_count
FROM public.work w
JOIN public.artist a ON w.artist_id = a.artist_id
JOIN public.museum mu ON w.museum_id = mu.museum_id
GROUP BY a.full_name
ORDER BY country_count DESC;

/*--Question 3- Create a table that shows the most frequently painted subject
for each style of painting, how many paintings there were for the most 
frequently painted subject in that style, how many paintings there are in 
that style overall, and the percent of paintings in that style with the 
most frequent subject.*/



--Looking at numbers of subjects per style
WITH SubjectCounts AS (
    SELECT style, subject, COUNT(*) AS subject_count
    FROM public.work w
    JOIN public.subject s ON w.work_id = s.work_id
    WHERE s.subject IS NOT NULL
    GROUP BY style, subject
),
--Looking at max subject count per style
MaxSubject AS (
    SELECT style, MAX(subject_count) AS max_count
    FROM SubjectCounts
    GROUP BY style
),
--Looking at most frequent subject and percentages
MostFrequentSubject AS (
    SELECT sc.style, sc.subject, sc.subject_count AS most_frequent_subject_count
    FROM SubjectCounts sc
    JOIN MaxSubject ms ON sc.style = ms.style AND sc.subject_count = ms.max_count
),
--Looking at total painting per style
TotalPaintings AS (
    SELECT style, COUNT(*) AS total_paintings
    FROM public.work
    GROUP BY style
)
-- Looking at all combined 
SELECT 
    mfs.style,
    mfs.subject,
    mfs.most_frequent_subject_count,
    tp.total_paintings,
    (mfs.most_frequent_subject_count::DECIMAL / tp.total_paintings) * 100 AS percentage
FROM MostFrequentSubject mfs
JOIN TotalPaintings tp ON mfs.style = tp.style;


