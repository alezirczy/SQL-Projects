https://chat.openai.com/share/79c10afb-8d51-4ac9-9bb2-2ba80841119d
https://campus.datacamp.com/courses/data-manipulation-in-sql/short-and-simple-subqueries?ex=2






select season, round(avg(home_goal+away_goal),2) as max_goals_per_season
from match
group by season 
order by  2 desc
limit 1


select id, round(avg(home_goal+away_goal),0) as avg_match_goals
from match
group by id
order by avg_match_goals desc

season		round
2013/2014	2.77
2012/2013	2.77
2014/2015	2.68
2011/2012	2.72

id	avg_match_goals
9211	11
14224	10
3566	10
3369	10
24123	10





select hometeam_id,awayteam_id, count(*)
from match
where season='2011/2012'
group by hometeam_id,awayteam_id
order by count desc

hometeam_id	awayteam_id	count
8467	8548	3
9927	8467	3
8467	9938	3
9925	8467	3


select hometeam_id, count(*)
from match
where season='2011/2012'
group by hometeam_id
order by count desc

hometeam_id	count
8597	20
9850	19
8558	19
10205	19

select awayteam_id, count(*)
from match
where season='2011/2012'
group by awayteam_id
order by count desc

awayteam_id	count
8467	20
9851	19
9850	19
9853	19



4
with home_m as (
		select hometeam_id, count(*) as home_total_matches
		from match
		where season='2011/2012'
		group by hometeam_id
		order by home_total_matches desc
),

	  away_m as(
		select awayteam_id, count(*) as away_total_matches
		from match
		where season='2011/2012'
		group by awayteam_id
		order by away_total_matches desc
)

select away_m.awayteam_id, away_m.away_total_matches,
	   home_m.hometeam_id, home_m.home_total_matches
from home_m,away_m

5
En la tabla "match", encuentra la temporada (season) con la mayor diferencia promedio de goles por partido. Muestra la temporada y la diferencia promedio de goles (goles a favor - goles en contra) redondeada a dos decimales.
select season,

SELECT
    m2.season,
    round(AVG(m2.home_goal) - AVG(m2.away_goal),2) AS goal_difference_avg
FROM
    match AS m2
GROUP BY
    m2.season;



6


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


7
select team_long_name ,coalesce(round(greatest(
	    coalesce(
		(select abs(sum(home_goal) - sum(away_goal))
		 from match as m1
		 where season= '2011/2012' and m1.hometeam_id=t.team_api_id)
				)
		 , 
		coalesce(
		(select abs(sum(away_goal) - sum(home_goal))
		 from match as m2
		 where season= '2011/2012' and m2.awayteam_id=t.team_api_id)
				)

                                       ),0),0) as max_diff_goals

from team as t
order by max_diff_goals desc


8
select season, sum(home_goal+away_goal) as goals_per_season
from match
group by season
order by goals_per_season desc




9
select team_long_name, count(*)
from match as mhome
inner join team as t
on mhome.hometeam_id=t.team_api_id
where home_goal>away_goal
group by team_long_name
order by count desc



---se puiede hacer esto ---

	----- respuesta abarcativa
select *,

		(select max(abs(home_goal-away_goal)) 
		from match as m1
		where m1.id=m2.id) as max_difference_goals

from match  as m2
order by max_difference_goals desc




-- hay partidos que se jugaron en distinto paises al que pertenecen?

select name, count(*)
from country as c 
full outer join match as m
on c.id=m.country_id 
group by name
order by count desc

name	count
Spain	1520
England	1520
France	1520
Italy	1497
Netherlands	1224
Germany	1224
Portugal	1026
Poland	960
Scotland	912
Belgium	732
Switzerland	702


-- cuantos equipos por temporada hay en cada pais

select distinct c.name, m.season, count(*)
from country as c 
full outer join match as m
on c.id=m.country_id 
full outer join team as t
on m.hometeam_id=t.team_api_id
group by c.name, m.season






-- cuantos equipos por temporada hay en cada pais
select sum(num_teams)
from (
		SELECT
			c.name AS country_name,
			m.season,
			COUNT(DISTINCT t.team_api_id) AS num_teams
		FROM
			match AS m
		JOIN
			team AS t ON m.hometeam_id = t.team_api_id
		JOIN
			country AS c ON m.country_id = c.id
		GROUP BY
			c.name, m.season
		ORDER BY
			c.name, m.season) as alias







-- cuantos partidos por temporada hay en cada pais
select distinct c.name,m.season ,count(t.team_long_name)
from match as m
left join country as c
on m.country_id=c.id
full join team as t 
on m.hometeam_id=t.team_api_id
group by c.name,m.season
order by name, season



--pivot TABLE
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab(
    'SELECT DISTINCT c.name, m.season, count(t.team_long_name)
     FROM match AS m
     LEFT JOIN country AS c ON m.country_id = c.id
     FULL JOIN team AS t ON m.hometeam_id = t.team_api_id
     GROUP BY c.name, m.season
     ORDER BY c.name, m.season',
    'SELECT DISTINCT season FROM match ORDER BY season'
) AS ct(name text, "2011/2012" bigint, "2012/2013" bigint, "2013/2014" bigint, "2014/2015" bigint);

name	2011/2012	2012/2013	2013/2014	2014/2015
Belgium	240	240	12	240
England	380	380	380	380
France	380	380	380	380
Germany	306	306	306	306
Italy	358	380	380	379
Netherlands	306	306	306	306
Poland	240	240	240	240
Portugal	240	240	240	306
Scotland	228	228	228	228
Spain	380	380	380	380
Switzerland	162	180	180	180
null	null	null	null	null


---cuandtos equipos temporada en cada pais


select distinct c.name,m.season ,count(distinct t.team_long_name)
from match as m
inner join country as c
on m.country_id=c.id
inner join team as t 
on m.hometeam_id=t.team_api_id
group by c.name,m.season
order by name, season
      
	 
--pivot TABLE

CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab(
    'SELECT DISTINCT c.name, m.season, count(distinct t.team_long_name)
     FROM match AS m
     LEFT JOIN country AS c ON m.country_id = c.id
     FULL JOIN team AS t ON m.hometeam_id = t.team_api_id
     GROUP BY c.name, m.season
     ORDER BY c.name, m.season',
    'SELECT DISTINCT season FROM match ORDER BY season'
) AS ct(name text, "2011/2012" bigint, "2012/2013" bigint, "2013/2014" bigint, "2014/2015" bigint);

name	2011/2012	2012/2013	2013/2014	2014/2015
Belgium	16	16	4	16
England	20	20	20	20
France	20	20	20	20
Germany	18	18	18	18
Italy	20	20	20	20
Netherlands	18	18	18	18
Poland	15	16	16	16
Portugal	16	16	16	18
Scotland	12	12	12	12
Spain	20	20	20	20
Switzerland	10	10	10	10
null	null	null	null	null


-- filtrando pivot table y aplicando en where 'result'
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
WHERE result.name IN ('England', 'France', 'Germany', 'Italy', 'Spain');


-----Ejercicio 1:
Para cada temporada ('2011/2012', '2012/2013', '2013/2014', '2014/2015'), encuentra el equipo que tiene el mejor promedio de goles marcados (tanto en casa como fuera de casa). Devuelve el nombre del equipo y el promedio de goles. Ordena los resultados por temporada.

WITH TeamSeasonStats AS (
    SELECT
        m.season,
        t.team_long_name,
        AVG(m.home_goal + m.away_goal) AS avg_goals,
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


season	team_long_name	avg_goals
2011/2012	SC Heerenveen	4.0588235294117647
2012/2013	PSV	4.2941176470588235
2013/2014	TSG 1899 Hoffenheim	4.1764705882352941
2014/2015	Real Madrid CF	4.1052631578947368


-----Ejercicio 2:
Encuentra el país con la mayor diferencia absoluta de goles entre equipos en la temporada '2011/2012'. Devuelve el nombre del país y la diferencia de goles.

SELECT c.name,sum(abs(home_goal-away_goal)) 
FROM match as m
LEFT JOIN country as c 
ON m.country_id=c.id 
WHERE m.season = '2011/2012'
GROUP BY c.name
ORDER BY sum DESC


-----Ejercicio 3:
Encuentra el equipo que ha tenido la mayor cantidad de empates en casa en la temporada '2012/2013'. Devuelve el nombre del equipo y la cantidad de empates en casa.
SELECT t.team_long_name, count(*)
FROM  match as m 
LEFT JOIN team as t 
ON m.hometeam_id=t.team_api_id
WHERE season= '2012/2013' AND home_goal=away_goal  
GROUP BY t.team_long_name
ORDER BY count DESC


---- Ejercicio 1 55
Encuentra la posición de cada equipo en la liga para cada temporada, considerando la puntuación acumulada. Utiliza funciones de ventana para calcular la posición y subconsultas correlacionadas para manejar las temporadas.

WITH home AS(	

		SELECT c.name,t.team_long_name, home_goal, away_goal, season,	

			sum(CASE WHEN home_goal>away_goal THEN 3
					WHEN home_goal<away_goal THEN 0
					ELSE 1 END) AS scores	

		FROM match as m

		LEFT JOIN team as t 

		ON m.hometeam_id=t.team_api_id --OR m.awayteam_id=t.team_api_id 

		LEFT JOIN country as c 
		ON m.country_id=c.id

		--WHERE  c.id=21518 AND t.team_api_id=8634--AND stage=38 
	    
		group by c.name,t.team_long_name, home_goal, away_goal,season
 
     ),

	 
     away AS(	

		SELECT c.name,t.team_long_name, home_goal, away_goal, season,	

			sum(CASE WHEN home_goal<away_goal THEN 3
					WHEN home_goal>away_goal THEN 0
					ELSE 1 END) AS scores	

		FROM match as m

		LEFT JOIN team as t 

		ON  m.awayteam_id=t.team_api_id 

		LEFT JOIN country as c 
		ON m.country_id=c.id

		--WHERE  c.id=21518 AND t.team_api_id=8634--AND stage=38 
	    
		group by c.name,t.team_long_name, home_goal, away_goal,season
 
     ),


     uniendo AS  (SELECT 	home.name,
				home.team_long_name,
				--home.stage,
				home.season,
				sum(home.scores) as puntos
					
			    FROM home
				
				GROUP BY
							home.name,
							home.team_long_name,
							--home.stage,
							home.season
				UNION

				SELECT 	away.name,
						away.team_long_name,
						--away.stage,
						away.season,
						sum(away.scores) 
					
				FROM away
				GROUP BY	away.name,
						    away.team_long_name,
							--away.stage,
							away.season),


resumiendo as  (select  uniendo.name,uniendo.team_long_name,uniendo.season, sum(puntos) as puntos

				FROM uniendo
				

				group by  uniendo.name,uniendo.team_long_name,uniendo.season
				ORDER BY uniendo.season,puntos DESC)


				SELECT 	resumiendo.name,resumiendo.team_long_name,resumiendo.season, resumiendo.puntos,
						RANK() OVER(PARTITION BY resumiendo.name,resumiendo.season ORDER BY resumiendo.puntos DESC,resumiendo.season DESC)
				FROM resumiendo
				WHERE resumiendo.name = 'Spain'
				
--RANK CON ACUMULADO Y CROSSTAB
