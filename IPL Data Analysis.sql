/*---- creating a new table with last 3 years data
select * into ballsnew  from 
(select *
from balls
where id >= 1082591)a 
select * into matchesnew  from 
(select *
from matches
where id >= 1082591)a */



with bastman_stats_powerplay as(
select batsman,
SUM(batsman_runs) over (partition by batsman ) as total_runs,
SUM(is_wicket) over (partition by batsman) as no_of_time_dismissed,
count(*)over (partition by batsman) as no_of_balls_faced,
count(*) over (partition by inning ,batsman) as no_of_matches_played
from ballsnew
where overs<6),

cte2 as (
select batsman, 
case when max(no_of_time_dismissed) = 0 then round(max(total_runs),4) else round(MAX(total_runs) /MAX(no_of_time_dismissed)*1.0,4) end  as average, 
round(cast(MAX(total_runs) as float)/cast(MAX(no_of_balls_faced) as float)*100,2) as Strike_rate,
MAX(no_of_matches_played) as no_of_matches_played
from bastman_stats_powerplay
group by batsman)

select * from cte2
where Strike_rate>120 and no_of_matches_played >30
order by average desc, Strike_rate desc

--- batsmans who have played from start till end
select  batsman from(
select id,batsman,
max(overs) over (partition by id ,batsman)-min(overs) over (partition by id ,batsman) as max_overs_played
from ballsnew)a
where max_overs_played>18
group by  batsman

---- Most played matches
select  batsman,COUNT(distinct(id)) as no_of_matches_played
from ballsnew
group by batsman
order by no_of_matches_played desc

--- Economical bowler 

select top 5 bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy,SUM(matches) as no_of_matches
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
group by id, bowler)a
group by bowler
having SUM(matches)>30
order by economy


---Economical bowler in power play

select top 5 bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy,SUM(matches) as no_of_matches
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
where overs<6
group by id, bowler)a
group by bowler
having SUM(matches)>15
order by economy

-- Economical Bowler in death overs

select top 5 bowler,cast(SUM(runs_con)*1.0/sum(total_overs) as decimal(4,2)) as economy,SUM(matches) as no_of_matches
from(
select id,bowler,SUM(total_runs) as runs_con ,COUNT(distinct(overs)) as total_overs,count(distinct(id)) as matches
from ballsnew
where overs>14
group by id, bowler)a
group by bowler
having SUM(matches)>15
order by economy






----Most Valuable Player or Allrounder
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


---- hatrick
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


----least score defended in the last over


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

--- no of times less then 20 defended by bowler

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

---- 50 streaks
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

select batsman,no_ as no_of_consecutive
from cte4
where no_ >=3
group by  batsman,no_
order by batsman


	


















