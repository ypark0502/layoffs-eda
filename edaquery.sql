ALTER TABLE layoffs_staging2
ALTER COLUMN total_laid_off int;

ALTER TABLE layoffs_staging2
ALTER COLUMN percentage_laid_off DECIMAL;

-- this column has NULL values that are actually strings ('NULL'), so need to convert those to actual NULL values before updating data type to int

UPDATE layoffs_staging2
SET funds_raised_millions = CASE
	WHEN funds_raised_millions = 'NULL' or funds_raised_millions = '' then NULL else funds_raised_millions
	END


ALTER TABLE layoffs_staging2
ALTER COLUMN funds_raised_millions DECIMAL;

SELECT 
	MAX(total_laid_off),
	MAX(percentage_laid_off)
FROM layoffs_staging2;

--companies that laid off all employees, order by to see largest company
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

--most funded companies that completely went under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- companies with highest total layoffs
SELECT 
	company,
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- date range
SELECT 
	MIN([date]),
	MAX([date])
FROM layoffs_Staging2;

-- industries with highest total layoffs
SELECT 
	industry,
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- countries with highest total layoffs
SELECT 
	country,
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- total layoffs by year
SELECT 
	YEAR([date]),
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR([date])
ORDER BY 1 DESC;

-- total layoffs by stage
SELECT 
	stage,
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- percent laid off by stage
SELECT 
	stage,
	ROUND(AVG(percentage_laid_off),2)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- rolling total layoffs by month
SELECT
	SUBSTRING(CAST([date] as NVARCHAR(50)), 1, 7) AS 'MONTH',
	SUM(total_laid_off)
FROM layoffs_staging2 as total_off
WHERE SUBSTRING(CAST([date] as NVARCHAR(50)), 1, 7) IS NOT NULL
GROUP BY SUBSTRING(CAST([date] as NVARCHAR(50)), 1, 7)
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT
	SUBSTRING(CAST([date] as NVARCHAR(50)), 1, 7) AS 'MONTH',
	SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE SUBSTRING(CAST([date] as NVARCHAR(50)), 1, 7) IS NOT NULL
GROUP BY SUBSTRING(CAST([date] as NVARCHAR(50)), 1, 7)
)
SELECT MONTH,
	total_off,
	SUM(total_off) OVER(ORDER BY MONTH) AS rolling_total
FROM Rolling_Total;

SELECT
	company,
	YEAR([date]),
	SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY
	company,
	YEAR([date])
ORDER BY 3 DESC;

-- Ranking of total layoffs by year, by company

WITH Company_Year AS 
(
SELECT
	company,
	YEAR([date]) as years,
	SUM(total_laid_off) as total_off
FROM layoffs_staging2
GROUP BY
	company,
	YEAR([date])
), Company_Year_Rank AS
(
SELECT *, 
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;

