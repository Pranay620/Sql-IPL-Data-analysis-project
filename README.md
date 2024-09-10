# Sql-IPL-Data-analysis-project

# Project Overview:  
-This project involved analyzing the Indian Premier League (IPL) dataset to assist stakeholders in identifying key players to target for the upcoming IPL auction. Using SQL, we performed data extraction, transformation, and analysis to provide actionable insights for player selection.


# Objectives:
1.	To analyze historical IPL data to identify key players to target for the upcoming auction.
2.	To help stakeholders make informed decisions based on comprehensive data analysis.
3.	To create a set of criteria and recommendations for selecting players based on their performance metrics.


1.	Top 10 batsman with average more than 30 and Strike Rate greater than 130 (Player Should have played minimum 10 matches)

Query:- with no_of_matches as (
select batsman,COUNT(distinct id) as no_of_matches
from ballsnew
group by batsman),

batting_stats as
(select ballsnew.batsman,
SUM(batsman_runs) as Total_runs ,SUM(is_wicket) as No_of_wickets,
COUNT(*)  as No_of_balls
from ballsnew
join no_of_matches
on ballsnew.batsman = no_of_matches.batsman
where no_of_matches>10 
group by ballsnew.batsman),

avg_sr as (
select batting_stats.batsman,
case when No_of_wickets = 0 then Total_runs
else round(cast(Total_runs as float)/cast( No_of_wickets as float),2) end as Average,
round(cast (Total_runs as float)/(cast (No_of_balls as float))*100,2) as StrikeRate
from batting_stats)

select * 
from avg_sr
where Average>=30 and StrikeRate>=130

   
