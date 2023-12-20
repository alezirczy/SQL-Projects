
<img src="">

# Welcome to the analysis of the:

<center><img src="https://github.com/alezirczy/Images/blob/main/%231%20-%20Soccer%20Leagues%20-%20European%20Leagues.png"></center>


## Entity Relationship Diagram
<img src="https://github.com/alezirczy/Images/blob/main/%231%20-%20Soccer%20Leagues%20-%20Tables.png">

## Questions


1. In the "match" table, find the season with the highest average goal difference per game. Shows the season and the average goal difference (goals for - goals against) rounded to two decimal places.
***
2. In the "team" table, find the name of the team (team_long_name) that has the highest average number of goals scored (as a home or away team) in the 2011/2012 season. It also shows the average goals rounded to two decimal places.
***
3. In the "team" table, find the name of the team (team_long_name) that has the highest average number of goals scored (as a home or away team) in the 2013/2014 season. It also shows the average goals rounded to two decimal places.
***
4. Find the season with the highest total number of goals in history. Returns the season and the total number of goals scored in that season.
***
5. For each country, find the team that has won the most home games in the '2011/2012' season. Returns the country name and team name.
***
6. In a pivot table, ¿How many games per season are there in England?
***
7. In a pivot table, ¿How many teams per season are there in each of the following countries: Germany, Italy?
***
8. For each season ('2011/2012', '2012/2013', '2013/2014', '2014/2015'), find the team that has the best average of goals scored (both home and away) ). Returns the team name ***
and goal average. Sort the results by season.
***
9. Find the country with the greatest absolute goal difference between teams in the '2011/2012' season. Returns the country name and goal difference.
***
10. Find the team that has had the most draws at home in the '2012/2013' season. Returns the team name and the number of home draws.
***
11. Use a trigger for a function that dynamically updates a results table, reflecting the final performance of the teams in each season, considering that the names of the countries correspond to their respective leagues.

## Answers

**1. In the "match" table, find the season with the highest average goal difference per game. Shows the season and the average goal difference (goals for - goals against) rounded to two decimal places.**
````sql

SELECT
    m2.season,
    round(AVG(m2.home_goal) - AVG(m2.away_goal),2) AS goal_difference_avg
FROM
    match AS m2
GROUP BY
    m2.season;
````
<img src="https://github.com/alezirczy/Images/blob/main/%231%20-%20Soccer%20Leagues%20-%201.png">

***

**2. In the "team" table, find the name of the team (team_long_name) that has the highest average number of goals scored (as a home or away team) in the 2011/2012 season. It also shows the average goals rounded to two decimal places.** 
````sql
SELECT
    t.team_long_name,
    ROUND(
	GREATEST(
        COALESCE(
            (SELECT AVG(home_goal) 
             FROM match AS m1
             WHERE m1.season = '2011/2012' AND m1.hometeam_id = t.team_api_id),
            0  -- Default value for home_goal average
        ),
        COALESCE(
            (SELECT AVG(away_goal) 
             FROM match AS m2
             WHERE m2.season = '2011/2012' AND m2.awayteam_id = t.team_api_id),
            0  -- Default value for away_goal average
        )
    ),2) AS greatest_goal
FROM
    team AS t
ORDER BY
    greatest_goal DESC
limit 1;
````
<img src="https://github.com/alezirczy/Images/blob/main/%231%20-%20Soccer%20Leagues%20-%202.png">
***

**3. Get the name of the team that has had the highest goal difference in a specific season (for example, '2013/2014'). The goal difference is calculated as the sum of the goals scored at home minus the goals conceded at home and the goals scored as away minus the goals conceded as a visitor.** 
````sql
select team_long_name ,coalesce(round(greatest(
	    coalesce(
		(select abs(sum(home_goal) - sum(away_goal))
		 from match as m1
		 where season= '2013/2014' and m1.hometeam_id=t.team_api_id)
				)
		 , 
		coalesce(
		(select abs(sum(away_goal) - sum(home_goal))
		 from match as m2
		 where season= '2013/2014' and m2.awayteam_id=t.team_api_id)
				)

                                       ),0),0) as max_diff_goals

from team as t
order by max_diff_goals desc
LIMIT 1
````
<img src="">

***

**4. Find the season with the highest total number of goals in history. Returns the season and the total number of goals scored in that season.** 
````sql
select season, sum(home_goal+away_goal) as goals_per_season
from match
group by season
order by goals_per_season desc
limit 1;

````
<img src="">
***

**5. For each country, find the team that has won the most home games in the '2011/2012' season. Returns the country name and team name.** 
````sql
select team_long_name, count(*)
from match as mhome
inner join team as t
on mhome.hometeam_id=t.team_api_id
where home_goal>away_goal
group by team_long_name
order by count desc
limit 3;
````
<img src="">
***

**6. In a pivot table, ¿How many games per season are there in England?** 
````sql
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT *
FROM crosstab(
    'SELECT DISTINCT c.name, m.season, count(t.team_long_name)
     FROM match AS m
     LEFT JOIN country AS c ON m.country_id = c.id
     FULL JOIN team AS t ON m.hometeam_id = t.team_api_id
     WHERE c.name = ''England''  
     GROUP BY c.name, m.season
     ORDER BY c.name, m.season',
    'SELECT DISTINCT season FROM match ORDER BY season'
) AS ct(name text, "2011/2012" bigint, "2012/2013" bigint, "2013/2014" bigint, "2014/2015" bigint);

````
<img src="">

***

**7. In a pivot table, ¿How many teams per season are there in each of the following countries: Germany, Italy?** 
````sql

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT *
FROM (
    SELECT *
    FROM crosstab(
        $$SELECT DISTINCT c.name, m.season, count(DISTINCT t.team_long_name)
        FROM match AS m
        LEFT JOIN country AS c ON m.country_id = c.id
        FULL JOIN team AS t ON m.hometeam_id = t.team_api_id
        GROUP BY c.name, m.season
        ORDER BY c.name, m.season$$,
        $$SELECT DISTINCT season FROM match ORDER BY season$$
    ) AS ct(name text, "2011/2012" bigint, "2012/2013" bigint, "2013/2014" bigint, "2014/2015"  bigint)
) AS result
WHERE result.name IN ('Germany', 'Italy');

````
<img src="">

***

**8. For each season ('2011/2012', '2012/2013', '2013/2014', '2014/2015'), find the team that has the best average of goals scored (both home and away) ). Returns the team name and goal average. Sort the results by season.**

````sql
WITH TeamSeasonStats AS (
    SELECT
        m.season,
        t.team_long_name,
        ROUND(AVG(m.home_goal + m.away_goal),1) AS avg_goals,
        RANK() OVER (PARTITION BY m.season ORDER BY AVG(m.home_goal + m.away_goal) DESC) AS goal_rank
    FROM
        match AS m
    JOIN
        team AS t ON m.hometeam_id = t.team_api_id OR m.awayteam_id = t.team_api_id
    GROUP BY
        m.season,
        t.team_long_name
)

SELECT
    season,
    team_long_name,
    avg_goals
FROM
    TeamSeasonStats
WHERE
    goal_rank = 1
ORDER BY
    season;
````


<img src="">

***

**9. Find the country with the greatest absolute goal difference between teams in the '2011/2012' season. Returns the country name and goal difference.** 
````sql
SELECT c.name,sum(abs(home_goal-away_goal)) 
FROM match as m
LEFT JOIN country as c 
ON m.country_id=c.id 
WHERE m.season = '2011/2012'
GROUP BY c.name
ORDER BY sum DESC
````
<img src="">

***

**10. Find the team that has had the most draws at home in the '2012/2013' season. Returns the team name and the number of home draws.** 
````sql
SELECT t.team_long_name, count(*)
FROM  match as m 
LEFT JOIN team as t 
ON m.hometeam_id=t.team_api_id
WHERE season= '2012/2013' AND home_goal=away_goal  
GROUP BY t.team_long_name
ORDER BY count DESC
````
<img src="">

***

**11. Use a trigger for a function that dynamically updates a results table, reflecting the final performance of the teams in each season, considering that the names of the countries correspond to their respective leagues.** 
````sql

CREATE OR REPLACE FUNCTION country_team_rank_by_season(country_name VARCHAR) RETURNS TABLE (
    country TEXT,
    team TEXT,
    season TEXT,
    pts NUMERIC, -- Cambiado de INT a NUMERIC
    rank BIGINT
) AS $$
BEGIN
    RETURN QUERY
    WITH home AS (	
        SELECT c.name, t.team_long_name, m.home_goal, m.away_goal, m.season,
            SUM(CASE WHEN m.home_goal > m.away_goal THEN 3
                     WHEN m.home_goal < m.away_goal THEN 0
                     ELSE 1 END) AS scores
        FROM match AS m
        LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id
        LEFT JOIN country AS c ON m.country_id = c.id
        GROUP BY c.name, t.team_long_name, m.home_goal, m.away_goal, m.season
    ),
    away AS (
        SELECT c.name, t.team_long_name, m.home_goal, m.away_goal, m.season,
            SUM(CASE WHEN m.home_goal < m.away_goal THEN 3
                     WHEN m.home_goal > m.away_goal THEN 0
                     ELSE 1 END) AS scores
        FROM match AS m
        LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id
        LEFT JOIN country AS c ON m.country_id = c.id
        GROUP BY c.name, t.team_long_name, m.home_goal, m.away_goal, m.season
    ),
    joining AS (
        SELECT
            home.name,
            home.team_long_name,
            home.season,
            SUM(home.scores) AS pts
        FROM
            home
        GROUP BY
            home.name,
            home.team_long_name,
            home.season
        UNION
        SELECT
            away.name,
            away.team_long_name,
            away.season,
            SUM(away.scores)
        FROM
            away
        GROUP BY
            away.name,
            away.team_long_name,
            away.season
    ),
    summary AS (
        SELECT
            joining.name,
            joining.team_long_name,
            joining.season,
            SUM(joining.pts) AS pts2
        FROM
            joining
        GROUP BY
            joining.name,
            joining.team_long_name,
            joining.season
        ORDER BY
            joining.season,
            pts2 DESC
    )
    
    SELECT
        summary.name,
        summary.team_long_name,
        summary.season,
        summary.pts2,
        RANK() OVER (PARTITION BY summary.name, summary.season ORDER BY summary.pts2 DESC, summary.season DESC) AS rank
    FROM
        summary
    WHERE
        summary.name = country_name;
END;
$$ LANGUAGE plpgsql;

-- Calling Function
SELECT * FROM country_team_rank_by_season('England');
<img src="">
````

