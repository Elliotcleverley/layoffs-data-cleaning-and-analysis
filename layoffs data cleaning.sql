-- Layoffs Data Cleaning project

-- All transformations are performed on a staging table

Select *
From layoffs_raw;

-- Objectives
-- 1. Duplicate dataset
-- 2. Check for duplicate rows 
-- 3. Standardise the data
-- 4. Handle null or blank values 
-- 5. Data quality check 

-- 1.Duplicate the dataset 

-- Create a staging table for transformations
create table layoffs_staging
 Like layoffs_raw;
 
 Select *
 from layoffs_staging;
 Insert layoffs_staging
 select *
 from layoffs_raw;
 
 -- 2. Check for duplicate rows
 
  select *,
ROW_NUMBER() OVER(
partition by company, location, industry,total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_numbers  
from layoffs_staging;
 
 WITH duplicate_cte as 
 (
select *,
ROW_NUMBER() OVER(
partition by company, industry,total_laid_off, percentage_laid_off, `date`) as row_numbers  
from layoffs_staging
)
Select *
FROM duplicate_cte
where row_numbers > 1;
-- no duplicate rows to remove.

-- 3. Standardise the data

Select *
From layoffs_staging;

select company, trim(company)
From layoffs_staging;

-- Trim company names
Update layoffs_staging
set company = trim(company);

select distinct industry 
From layoffs_staging;

select distinct location
From layoffs_staging
order by 1;

select distinct country
From layoffs_staging
order by 1;

select distinct country, trim(trailing '.' from country)
from layoffs_staging
order by 1;

-- Remove trailing period
update layoffs_staging
set country = trim(trailing '.' from country)
where country like 'United States%';

select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging;

-- Convert date column from text to DATE type
update layoffs_staging
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

alter table layoffs_staging
modify column `date` DATE;

-- 4. Remove null values 

-- Identify rows with missing layoff information
select * 
from layoffs_staging
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging
where industry is null 
or industry = '';

-- Set blank industries to null 
update layoffs_staging
set industry = null 
where industry = '';

select *
from layoffs_staging
where company = 'Airbnb';

select *
From layoffs_staging t1
join layoffs_staging t2
on t1.company = t2.company
where t1.industry is null 
and t2.industry is not null;

-- Backfill missing industry values using other observations of the same company
update layoffs_staging t1
join layoffs_staging t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

select *
from layoffs_staging
where total_laid_off is null 
and percentage_laid_off is null;

-- Remove observations with no layoff magnitude information
delete 
from layoffs_staging
where total_laid_off is null 
and percentage_laid_off is null;

-- 5. Data quality check

-- Count missing values and calculate percentages
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) AS missing_industry,
    ROUND(SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END)/COUNT(*)*100, 2) AS pct_missing_industry,
    SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END) AS missing_total_laid_off,
    ROUND(SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END)/COUNT(*)*100, 2) AS pct_missing_total_laid_off,
    SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS missing_percentage_laid_off,
    ROUND(SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END)/COUNT(*)*100, 2) AS pct_missing_percentage_laid_off
FROM layoffs_staging;

-- Check for negative or zero layoffs
SELECT *
FROM layoffs_staging
WHERE total_laid_off <= 0 OR percentage_laid_off < 0;