-- Exploratory analysis using cleaned layoffs_staging table
-- Assumes data cleaning has been completed prior to running this file


-- 1. Total layoffs by year
select 
    year(`date`) as year,
    sum(total_laid_off) as total_layoffs
from layoffs_staging
group by year(`date`)
order by year;

-- 2. Monthly layoffs trend
select 
    date_format(`date`, '%Y-%m') as month,
    sum(total_laid_off) as total_layoffs
from layoffs_staging
group by date_format(`date`, '%Y-%m')
order by month;

-- 3. Total layoffs by country
select 
    country,
    sum(total_laid_off) as total_layoffs
from layoffs_staging
group by country
order by total_layoffs desc;

-- 4. Total layoffs by industry
select 
    industry,
    sum(total_laid_off) as total_layoffs
from layoffs_staging
where industry is not null
group by industry
order by total_layoffs desc;

-- 5. Top 10 companies by total layoffs
select 
    company,
    sum(total_laid_off) as total_layoffs
from layoffs_staging
group by company
order by total_layoffs desc
limit 10;

-- 7. Total layoffs by industry within each country
SELECT 
    country, 
    industry, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE industry IS NOT NULL
GROUP BY country, industry
ORDER BY country, total_layoffs DESC;


