  --QUESTIONS:
  --Who are the top directors by movie earnings?
  --What are the top earning movies?
  --What are the top years ranked by earnings?
  --Who are the highest grossing stars?
  --Is there a correlation between runtime and earnings?
  --Which actors have starred in the most movies?
  --For the above #1 actor, what has the trend in meta_score and earnings been for their movies over time?
  --Who has directed the most movies?
  --For the above #1 director, what has the trend in meta score and earnings been for their movies over time?

  SELECT *
  FROM PortfolioProject.dbo.imdb1000

  --DATA CLEANING - replace null values for Certificate column

  SELECT certificate
  FROM PortfolioProject.dbo.imdb1000;

  UPDATE PortfolioProject.dbo.imdb1000
  SET certificate = 'No rating'
  WHERE certificate IS NULL

  UPDATE PortfolioProject.dbo.imdb1000
  SET certificate = 'N/A'
  WHERE certificate = 'No rating'

  --Who are the top directors by movie earnings?

   
  SELECT
	TOP(20) director,
	SUM(gross) sum_gross
  FROM PortfolioProject.dbo.imdb1000
	WHERE gross IS NOT NULL
	 GROUP BY director
	ORDER BY sum_gross desc

    --What are the top earning movies?

  SELECT
	TOP(20) series_title,
	gross
  FROM PortfolioProject.dbo.imdb1000
  ORDER BY gross desc

    --What are the top years ranked by earnings?

  SELECT
	TOP(20) released_year,
	SUM(gross) sum_gross
  FROM PortfolioProject.dbo.imdb1000
  WHERE gross IS NOT NULL
  GROUP BY released_year
  ORDER BY sum_gross desc

    --Is there a correlation between runtime and earnings?

  SELECT
	TOP(50) runtime,
	SUM(gross) sum_gross
  FROM PortfolioProject.dbo.imdb1000
  WHERE gross IS NOT NULL
  GROUP BY runtime
  ORDER BY sum_gross desc

    --Who are the highest grossing stars?

SELECT
	TOP(20)
	Star1,
	SUM(gross) sum_gross
FROM PortfolioProject.dbo.imdb1000
	WHERE gross IS NOT NULL
	GROUP BY Star1
	ORDER BY sum_gross desc


	  --Which actors have starred in the most movies? 

SELECT
	TOP(20) Star1,
	COUNT(series_title) number_features
FROM PortfolioProject.dbo.imdb1000
	GROUP BY Star1
	ORDER BY number_features desc


SELECT
	series_title,
	meta_score,
	gross,
	released_year
FROM PortfolioProject.dbo.imdb1000
	WHERE Star1 IN(
					SELECT
						TOP(1) Star1
					FROM
						PortfolioProject.dbo.imdb1000
					GROUP BY
						Star1
					ORDER BY COUNT(*) DESC
					)
	ORDER BY released_year

--NEED TO REPLACE NULL VALUE FOR APOLLO 13 RELEASED_YEAR FOR RESULTS IN PREV. QUERY

SELECT
	released_year
FROM
	PortfolioProject.dbo.imdb1000
WHERE
	series_title IN ('Apollo 13');
 
UPDATE
	PortfolioProject.dbo.imdb1000
SET
	released_year = 1995
WHERE
	series_title IN ('Apollo 13');


  --Who has directed the most movies? Top 5

SELECT
	TOP(5) director,
	COUNT(series_title) films_directed
FROM
	PortfolioProject.dbo.imdb1000
GROUP BY
	director
ORDER BY
	films_directed DESC


  --For the above #1 director by films directed, what has the trend in meta score and earnings been for their movies over time?

 SELECT
	series_title,
	meta_score,
	gross,
	released_year
FROM
	PortfolioProject.dbo.imdb1000
WHERE
	director IN(
				SELECT
					TOP 1(director)
				FROM
					PortfolioProject.dbo.imdb1000
				GROUP BY
					director
				ORDER BY COUNT(*) DESC
				)
ORDER BY
	released_year


