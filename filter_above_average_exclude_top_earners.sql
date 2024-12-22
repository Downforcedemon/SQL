SELECT s.*
FROM SF_PUBLIC_SALARIES s
WHERE s.year = 2013
  -- Filter employees earning more than the average pay for 2013
  AND s.totalpay > (
      SELECT AVG(s.TOTALPAY) AS Average_PAY
      FROM SF_PUBLIC_SALARIES
      WHERE year = 2013
  )
  -- Exclude employees who are among the top 5 earners for their job title
  AND s.ID NOT IN (
      SELECT ID
      FROM (
          -- Assign a rank to employees within each job title based on total pay in descending order
          SELECT id, RANK() OVER (PARTITION BY JOBTITLE ORDER BY TOTALPAY DESC) AS rank
          FROM SF_PUBLIC_SALARIES
          WHERE year = 2013
      ) ranked_salaries
      -- Filter to only include the top 5 earners for each job title
      WHERE rank <= 5
  );
