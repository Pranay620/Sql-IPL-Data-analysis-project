--1.	Top 10 batsman with average more than 30 and Strike Rate greater than 130 (Player Should have played minimum 10 matches)

with no_of_matches as (
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

--2.	Top batsman with average more than 30 and Strike Rate greater than 140 in power plays (overs less than 6) (Player Should have played minimum 10 matches)

with no_of_matches as (
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
where no_of_matches>=10 and overs<6
group by ballsnew.batsman),

avg_sr as (
select batting_stats.batsman,
case when No_of_wickets = 0 then Total_runs
else round(cast(Total_runs as float)/cast( No_of_wickets as float),2) end as Average,
round(cast (Total_runs as float)/(cast (No_of_balls as float))*100,2) as StrikeRate
from batting_stats)

select * 
from avg_sr
where Average>=30 and StrikeRate>=140
order by Average desc, StrikeRate desc

--3.	Top batsman with average more than 30 and Strike Rate greater than 180 in death overs (overs greater  than 15) (Player Should have played minimum 10 matches)

with no_of_matches as (
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
where no_of_matches>=10 and overs>14
group by ballsnew.batsman),

avg_sr as (
select batting_stats.batsman,
case when No_of_wickets = 0 then Total_runs
else round(cast(Total_runs as float)/cast( No_of_wickets as float),2) end as Average,
round(cast (Total_runs as float)/(cast (No_of_balls as float))*100,2) as StrikeRate
from batting_stats)

select * 
from avg_sr
where Average>=30 and StrikeRate>=180
order by Average desc, StrikeRate desc

--4.	Batsman who have scored 50s consecutively in more than 2 matches.

with cte as (
select id,batsman,SUM(batsman_runs) as runs
from ballsnew
group by id, batsman),

cte2 as(
select *, 
ROW_NUMBER()over(partition by batsman order by id) as rnk
from cte),


cte3 as (
select *,rnk-
ROW_NUMBER()over(partition by batsman order by id) as con
from cte2
where runs >=50),

cte4 as(
select *,
count(*) over (partition by batsman, con) as no_
from cte3)

select distinct batsman
from cte4
where no_ >=3
group by  batsman,no_
order by batsman


--5.	Top 10 economical bowlers.


select  top 10 bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
group by id, bowler)a
group by bowler
having SUM(matches)>10
order by economy


--6.	Top 10 economical bowlers in death overs (Overs greater than 14).


select Top 10 bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
where overs>14
group by id, bowler)a
group by bowler
having SUM(matches)>10
order by economy


--7.	Top 10 economical bowlers in power play overs (Overs less than 7).


select  top 10 bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
where overs<6
group by id, bowler)a
group by bowler
having SUM(matches)>10
order by economy


--8.	List of players wo have taken hatricks.


with cte as(
select id,bowler,overs,ball-
ROW_NUMBER()over(partition by bowler,id,overs order by ball) as wickets
from ballsnew
where is_wicket =1)
,cte2 as(
select *,
COUNT(*)over ( partition by id,bowler, overs , wickets order by overs) as no_of_con_wickets
from cte)

select bowler from cte2
where no_of_con_wickets >2
group by bowler


--9.	What is the least score defended by a bowler and his name?


with cte as(
select id,inning,max(overs) as last_over from ballsnew
where inning =2
group by id,inning),

cte2 as(
select ballsnew.id,ballsnew.bowler,SUM(ballsnew.total_runs)as total_runs_spend from ballsnew
join cte 
on ballsnew.id=cte.id and ballsnew.inning=cte.inning and ballsnew.overs=cte.last_over
group by ballsnew.id,ballsnew.bowler)

select TOP 1 bowler,total_runs_spend+result_margin AS runs_defended from cte2
join matchesnew
on cte2.id=matchesnew.id
where result = 'runs' and total_runs_spend+result_margin<20
order by runs_defended

--10.	How many times less than 20 runs is defended by any bowler?


with cte as(
select id,inning,max(overs) as last_over from ballsnew
where inning =2
group by id,inning),

cte2 as(
select ballsnew.id,ballsnew.bowler,SUM(ballsnew.total_runs)as total_runs_spend from ballsnew
join cte 
on ballsnew.id=cte.id and ballsnew.inning=cte.inning and ballsnew.overs=cte.last_over
group by ballsnew.id,ballsnew.bowler)

select  bowler,count(*) as no_of_times from cte2
join matchesnew
on cte2.id=matchesnew.id
where result = 'runs' and total_runs_spend+result_margin<=20
group by bowler
order by no_of_times desc


--11.	Best Allrounder. Player who has economy less than 8 and strike rate > 140 (Should have played atleast 10 matches)


with player_batting_stats as(
select batsman,cast(sum(batsman_runs)*1.0/sum(is_wicket)as decimal(4,2)) as Average,cast(sum(batsman_runs)*1.0/count(*)*100 as decimal(6,2))as Strike_rate, count(distinct(id)) as No_of_matches 
from ballsnew
group by batsman
having sum(is_wicket)>0),
 bowling_stats as(select bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy,SUM(matches) as no_of_matches
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
group by id, bowler)a
group by bowler)

,cte3 as(
select bowling_stats.bowler,player_batting_stats.Average ,player_batting_stats.Strike_rate,player_batting_stats.No_of_matches as Batting_matches,
bowling_stats.economy,bowling_stats.no_of_matches as bowling_matches
from player_batting_stats
join bowling_stats
on player_batting_stats.batsman= bowling_stats.bowler)

select bowler as player, Average, Strike_rate, economy from cte3
where economy<8 and Batting_matches >=10 and bowling_matches>=10 and Strike_rate>= 140
order by Average desc, Strike_rate desc
