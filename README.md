This project cleans and explores a real-world layoffs dataset using MySQL. The workflow follows a typical analytics process, starting from raw data and ending with an analysis-ready table.

The raw dataset is first duplicated into a staging table so that all transformations can be applied without modifying the source. Records are checked for duplication, text fields are standardised, country names are cleaned, and date values are converted from text into DATE format. Missing industry values are corrected where possible using other observations for the same company, and rows with no layoff magnitude information are removed.

Exploratory queries are then run on the cleaned table to summarise layoffs over time, across countries and industries, and at the company level. The resulting dataset provides a clean foundation for further analysis or visualisation.
