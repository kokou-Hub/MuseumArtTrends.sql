# Museum Art Analysis - SQL Project

## **Project Overview**
This project explores **art collections in museums** using SQL queries to analyze painting styles, artists, and subject matter. The goal is to **uncover trends in museum art collections**, including the prevalence of **Cubist paintings, diverse artist representations, and the most frequently painted subjects.**

## **Data Source & Technologies Used**
- **Database:** PostgreSQL  
- **Data Tables:** `public.work`, `public.museum`, `public.artist`, `public.subject`  
- **Skills Utilized:** SQL queries, Common Table Expressions (CTEs), Aggregations, Joins, and Data Filtering  

## **Key Questions Answered & Queries Used**

### **1️⃣ Museums with the Highest Proportion of Cubist Paintings**
- **Objective:** Identify museums with the largest proportion of Cubist paintings relative to their total collections.  
- **Approach:**  
  - Counted the total number of Cubist paintings per museum.
  - Counted the total number of paintings per museum.
  - Calculated the proportion of Cubist paintings.  
  - Ranked museums by Cubist proportion.  
- **Query:**
  ```sql
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
  SELECT m.name AS museum_name, p.proportion
  FROM ProportionCubism p
  JOIN public.museum m ON p.museum_id = m.museum_id
  ORDER BY p.proportion DESC
  LIMIT 10;
  ```

### **2️⃣ Other Styles of Art Displayed by These Museums**
- **Objective:** Identify what other art styles are exhibited in the museums with a high proportion of Cubist paintings.  
- **Query Highlights:**  
  - Selected distinct art styles in these museums.  
  - Used `JOIN` to merge museum and artwork tables.  
- **Query:**
  ```sql
  SELECT DISTINCT m.name AS museum_name, w.style
  FROM ProportionCubism pc
  JOIN public.work w ON pc.museum_id = w.museum_id
  JOIN public.museum m ON pc.museum_id = m.museum_id
  ORDER BY m.name, w.style;
  ```

### **3️⃣ Artists Displayed in Museums Across Multiple Countries**
- **Objective:** Identify artists whose works are displayed in museums across the most countries.  
- **Query Highlights:**  
  - Counted distinct countries where each artist's work is displayed.  
  - Ordered artists by the number of unique countries.  
- **Query:**
  ```sql
  SELECT a.full_name AS artist_name, COUNT(DISTINCT mu.country) AS country_count
  FROM public.work w
  JOIN public.artist a ON w.artist_id = a.artist_id
  JOIN public.museum mu ON w.museum_id = mu.museum_id
  GROUP BY a.full_name
  ORDER BY country_count DESC;
  ```

### **4️⃣ Most Frequently Painted Subjects for Each Style**
- **Objective:** Find the most common subject for each painting style and its percentage of total works in that style.  
- **Query Highlights:**  
  - Used `JOIN` between `work` and `subject` tables.  
  - Used CTEs to calculate subject counts and percentages.  
- **Query:**
  ```sql
  WITH SubjectCounts AS (
      SELECT style, subject, COUNT(*) AS subject_count
      FROM public.work w
      JOIN public.subject s ON w.work_id = s.work_id
      WHERE s.subject IS NOT NULL
      GROUP BY style, subject
  ),
  MaxSubject AS (
      SELECT style, MAX(subject_count) AS max_count
      FROM SubjectCounts
      GROUP BY style
  ),
  MostFrequentSubject AS (
      SELECT sc.style, sc.subject, sc.subject_count AS most_frequent_subject_count
      FROM SubjectCounts sc
      JOIN MaxSubject ms ON sc.style = ms.style AND sc.subject_count = ms.max_count
  ),
  TotalPaintings AS (
      SELECT style, COUNT(*) AS total_paintings
      FROM public.work
      GROUP BY style
  )
  SELECT 
      mfs.style,
      mfs.subject,
      mfs.most_frequent_subject_count,
      tp.total_paintings,
      (mfs.most_frequent_subject_count::DECIMAL / tp.total_paintings) * 100 AS percentage
  FROM MostFrequentSubject mfs
  JOIN TotalPaintings tp ON mfs.style = tp.style;
  ```

## **Results & Insights**
 **Key Findings:**
- Certain **museums specialize in Cubism**, with proportions reaching over **30% of their collection**.
- Museums that exhibit Cubist paintings also tend to showcase **Surrealism and Impressionism**.
- **Famous artists** such as **Picasso** and **Van Gogh** have works displayed across multiple countries.
- The **most frequently painted subjects vary by style**, with some themes dominating entire artistic movements.


