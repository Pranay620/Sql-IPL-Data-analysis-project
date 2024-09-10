# Sql-IPL-Data-analysis-project

# Project Overview:  
-This project involved analyzing the Indian Premier League (IPL) dataset to assist stakeholders in identifying key players to target for the upcoming IPL auction. Using SQL, we performed data extraction, transformation, and analysis to provide actionable insights for player selection.


# Objectives:
1.	To analyze historical IPL data to identify key players to target for the upcoming auction.
2.	To help stakeholders make informed decisions based on comprehensive data analysis.
3.	To create a set of criteria and recommendations for selecting players based on their performance metrics.

   Methodology:
1.	Data collection:
•	Dataset : The IPL dataset used includes historical records of all matches played between teams, featuring detailed ball-by-ball data.
•	Source: Data was sourced from Kaggle.

2.	SQL Queries and Data Manipulation Techniques Used:
I.	Data Retrieval and Basic Queries:
•	Objective: Extract raw data and essential statistics from the dataset.
•	Technique: Utilized SELECT statements to pull specific fields such as player names, match dates, and performance metrics.
II.	Aggregation and Summarization:
•	Objective: Summarize player performance metrics for comprehensive analysis.
•	Technique: Employed aggregation functions such as SUM() and COUNT() to calculate total runs, wickets, and other cumulative statistics.
III.	Joining Tables:
•	Objective: Combine related data from multiple tables for integrated insights.
•	Technique: Used JOIN operations to merge different cte’s having player statistics.

IV.	Subqueries for Comparative Analysis:
•	Objective: Perform comparative analysis by isolating and evaluating subsets of data.
•	Technique: Applied subqueries to filter and compare player performance across different conditions.


V.	Window Functions for Ranking:
•	Objective: Rank players based on performance metrics to identify top performers.
•	Technique: Implemented window functions such as RANK() , MAX() etc. to assign ranks based on aggregated performance data.

VI.	Conditional Logic for Categorization:
•	Objective: Categorize players based on their performance levels.
•	Technique: Utilized CASE statements to create performance categories such as ‘High Performer’ and ‘Low Performer’.

