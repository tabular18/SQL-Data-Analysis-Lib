# SuperStore Analysis
#### Data Source
This repo analysis and prepares ETL scripts for the classic SuperStore dataset, downloaded from [Tableau here](https://www.tableau.com/sites/default/files/2021-05/Sample%20-%20Superstore.xls)

The raw SuperStore Excel file contains three sheets each corresponding to a different level of detail. These sheets have been loaded into a SQL Server database, DEMODATA : 

orders >> DEMODATA.dbo.superstore_order

People >> DEMODATA.dbo.superstore_person

Returns >> DEMODATA.dbo.superstore_return

These are referenced frequently throughout the EDA and ETL scripts.

#### ETL
The ETL process detailed in this folder aims to mimic the data preparation performed within Power Query in a separate repo which focusses on build of a Financial Overview dashboard -  [SuperStore - Power BI](https://github.com/tabular18/SuperStore-PowerBI)