CREATE schema olympic_dataset;
set search_path to olympic_dataset;

CREATE TABLE noc_regions
(noc varchar ,
 region varchar ,
 notes varchar );

SELECT * FROM noc_regions ;
SELECT * FROM OLYMPIC_HISTORY ;

DROP TABLE OLYMPIC_HISTORY;
DROP TABLE noc_regions;

CREATE TABLE OLYMPIC_HISTORY
(id    INT ,
 NAME  VARCHAR,
 sex   VARCHAR,
 age    VARCHAR,
 height VARCHAR,
 weight VARCHAR,
 team   VARCHAR,
 noc    VARCHAR,
 games  VARCHAR,
 year   int ,
 season VARCHAR,
 city   VARCHAR,
 sport  VARCHAR,
 event  VARCHAR,
 medal  VARCHAR );


--List of all the questions that can be answered using this dataset:
  /*How many olympics games have been held?
	List down all Olympics games held so far.
	Mention the total no of nations who participated in each olympics game?
	Which year saw the highest and lowest no of countries participating in olympics?
	Which nation has participated in all of the olympic games?
	Identify the sport which was played in all summer olympics.
	Which Sports were just played only once in the olympics?
	Fetch the total no of sports played in each olympic games.
	Fetch details of the oldest athletes to win a gold medal.
	Find the Ratio of male and female athletes participated in all olympic games.
	Fetch the top 5 athletes who have won the most gold medals.
	Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
	Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
	List down total gold, silver and broze medals won by each country.
	List down total gold, silver and broze medals won by each country corresponding to each olympic games.
	Identify which country won the most gold, most silver and most bronze medals in each olympic games.
	Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
	Which countries have never won gold medal but have won silver/bronze medals?
	In which Sport/event, India has won highest medals.
	Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.*/


-- Question 1.How many olympics games have been held?
	SELECT * FROM OLYMPIC_HISTORY  ;
	SELECT * FROM noc_regions;

	SELECT  COUNT(DISTINCT games) 
	FROM OLYMPIC_HISTORY ;


-- Question 2.List down all Olympics games held so far.
	SELECT DISTINCT games
	FROM OLYMPIC_HISTORY ;

-- Question 3.Mention the total no of nations who participated in each olympics game?
	SELECT games , count(DISTINCT team) as no_of_teams,
	MAX(count(DISTINCT team))over() as max_count,
	MIN(count(DISTINCT team))over() as min_count
	FROM OLYMPIC_HISTORY
	GROUP BY games ;

-- Question 4. Which year saw the highest and lowest no of countries participating in olympics?
	SELECT x.year ,no_of_teams
	FROM(
		SELECT year , count(DISTINCT team) as no_of_teams,
		MAX(count(DISTINCT team))over() as max_count,
		MIN(count(DISTINCT team))over() as min_count
		FROM OLYMPIC_HISTORY
		GROUP BY year ) x
	WHERE x.no_of_teams=x.min_count OR x.no_of_teams=x.max_count

-- Question 5. Which nation has participated in all of the olympic games?
	SELECT * FROM OLYMPIC_HISTORY  ;
	SELECT * FROM noc_regions;


	--1st Process (USING JOIN)
		SELECT nr.region  ,count(DISTINCT oh.games)as no_of_olympics_participated
		FROM OLYMPIC_HISTORY oh
		JOIN noc_regions nr ON oh.noc=nr.noc
		GROUP BY nr.region
		HAVING count(DISTINCT oh.games)=(SELECT  count(DISTINCT games) as total_no_of_games FROM OLYMPIC_HISTORY)
		ORDER BY nr.region

	--2nd Process (USING CTE)
		WITH CTE1 AS 
				( SELECT count(distinct games) as no_of_total_olympics
				FROM OLYMPIC_HISTORY)
		,    CTE2 AS
				(SELECT distinct team , games
				 FROM OLYMPIC_HISTORY
				 GROUP BY team , games
				 order by games)
		,	 CTE3 AS
				  (SELECT distinct team,
				  count(games)over(partition by team) as no_of_olympics_by_each_team
				  FROM CTE2
				  ORDER BY (count(games)over(partition by team) )desc)

		SELECT CTE3.team , CTE1.no_of_total_olympics,CTE3.no_of_olympics_by_each_team
		FROM CTE1,CTE3
		WHERE CTE3.no_of_olympics_by_each_team=CTE1.no_of_total_olympics


-- Question 6 Identify the sport which was played in all summer olympics .
	SELECT * FROM OLYMPIC_HISTORY  ;
	SELECT * FROM noc_regions;

	SELECT count(DISTINCT games) as games_in_summer FROM OLYMPIC_HISTORY WHERE season='Summer';


	--1st Process (USING CTE)
		WITH CTE1 AS
				(SELECT count(distinct year) as no_of_total_summer_olympics
				FROM OLYMPIC_HISTORY
				WHERE season='Summer')
		,     CTE2 AS 
				(SELECT DISTINCT sport ,year
				 --COUNT(YEAR)OVER(PARTITION BY SPORT )
				 FROM OLYMPIC_HISTORY
				 ORDER BY YEAR)
		,	 CTE3 AS 
				(SELECT sport ,COUNT(year) as sport_played_in_no_of_years
				 FROM CTE2
				GROUP BY sport
				ORDER BY COUNT(year) desc)  
		SELECT CTE3.sport ,CTE3.sport_played_in_no_of_years ,CTE1.no_of_total_summer_olympics
		FROM CTE1 ,CTE3
		WHERE CTE3.sport_played_in_no_of_years =CTE1.no_of_total_summer_olympics

	--2nd Process (USING GROUP BY AND HAVING CLAUSE)
		SELECT sport , count( DISTINCT games ) as no_of_summer_games
		FROM OLYMPIC_HISTORY
		WHERE season='Summer'
		GROUP BY sport 
		HAVING count( DISTINCT games )=(SELECT count(DISTINCT games) as games_in_summer FROM OLYMPIC_HISTORY WHERE season='Summer') 
		ORDER BY sport


-- Question 7 Which Sports were just played only once in the olympics?
	--1st Process 
		WITH CTE AS
				(SELECT sport  , count ( DISTINCT games ) as no_of_summer_games
				FROM OLYMPIC_HISTORY
				GROUP BY sport 
				HAVING count( DISTINCT games )=1 
				ORDER BY sport)
		SELECT DISTINCT x.sport,oh.games ,x.no_of_summer_games
		FROM OLYMPIC_HISTORY as oh
		JOIN CTE as x ON x.sport=oh.sport


	--2nd Process
		WITH  CTE1 AS 
				(SELECT DISTINCT sport ,year
				 --COUNT(YEAR)OVER(PARTITION BY SPORT )
				 FROM OLYMPIC_HISTORY
				 ORDER BY YEAR)
		,	 CTE2 AS 
				(SELECT sport ,COUNT(year) as sport_played_in_no_of_years
				 FROM CTE1
				 GROUP BY sport
				 ORDER BY COUNT(year) )

		SELECT CTE2.sport ,	CTE2.sport_played_in_no_of_years
		FROM CTE2
		WHERE CTE2.sport_played_in_no_of_years=1

-- Question 8 Fetch the total no of sports played in each olympic games.
	SELECT * FROM OLYMPIC_HISTORY  ;

	SELECT x.games ,count(x.sport)
	FROM (
			SELECT DISTINCT sport , games ,year 
			FROM OLYMPIC_HISTORY
			GROUP BY sport , games ,year
			ORDER BY year)x
	GROUP by x.games
	ORDER BY count(x.sport) desc
-- Question 9 Fetch details of the oldest athletes to win a gold medal.
	SELECT * FROM OLYMPIC_HISTORY  ;

	select id,name,sex,age,team,noc,games,year,sport,event,medal
	from(
		SELECT * ,
		RANK()over(ORDER BY AGE DESC)as rn
		FROM OLYMPIC_HISTORY
		WHERE age<>'NA' AND medal='Gold'
		ORDER BY AGE DESC)X
	where X.RN=1

-- Question 10 Find the Ratio of male and female athletes participated in all olympic games.
	SELECT * FROM OLYMPIC_HISTORY  ;

	--1st Process
		WITH CTE AS (SELECT sum(x.male_flag)as total_male , sum(x.female_flag)as total_female 
					FROM (SELECT  name,
						  CASE WHEN sex='M'THEN 1 ELSE 0 END as male_flag,
						  CASE WHEN sex='F'THEN 1 ELSE 0 END as female_flag
						  FROM OLYMPIC_HISTORY)x)
		SELECT concat('1 : ',ROUND((total_male::decimal/total_female),2)) as ratio
		FROM CTE

	--2nd Process
		 with t1 as
					(select sex, count(1) as cnt
					from OLYMPIC_HISTORY
					group by sex),
				t2 as
					(select *, row_number() over(order by cnt) as rn
					 from t1),
				min_cnt as
					(select cnt from t2	where rn = 1),
				max_cnt as
					(select cnt from t2	where rn = 2)
			select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
			from min_cnt, max_cnt;

-- Question 11 Fetch the top 5 athletes who have won the most gold medals.

	SELECT name,team,
	count(medal)as no_of_gold_medals
	FROM OLYMPIC_HISTORY
	WHERE medal ='Gold'
	GROUP BY name,team
	ORDER BY count(medal) desc
	LIMIT 6


-- Question 12 Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

	SELECT name,team,
	count(medal)as no_of_medals
	FROM OLYMPIC_HISTORY
	WHERE medal IN ('Gold','Silver','Bronze')
	GROUP BY name,team
	ORDER BY count(medal) desc
	LIMIT 7

-- Question 13 Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

	--1st Process
		SELECT nr.region,count(oh.medal)as no_of_medal
		FROM OLYMPIC_HISTORY oh 
		JOIN noc_regions nr ON oh.noc=nr.noc 
		WHERE oh.medal IN ('Gold','Silver','Bronze')
		GROUP by nr.region
		ORDER BY count(oh.medal) desc 
		limit(5)


	--2nd Process
		WITH CTE1 AS 
				(SELECT nr.region as country , count ( nr.region)as total_medals,
				 rank()over(ORDER BY count ( nr.region) desc) rnk
				FROM OLYMPIC_HISTORY oh 
				JOIN noc_regions as nr ON oh.noc=nr.noc
				WHERE oh.medal<>'NA'
				GROUP BY nr.region 
				ORDER BY count ( nr.region) desc)

		SELECT country , total_medals 
		FROM CTE1
		WHERE rnk <=5


-- Question 14 List down total gold, silver and broze medals won by each country.
	
	SELECT nr.region as country ,medal,count (nr.region)as total_medals
	FROM OLYMPIC_HISTORY oh 
	JOIN noc_regions as nr ON oh.noc=nr.noc
	WHERE oh.medal<>'NA'
	GROUP BY nr.region ,medal 
	ORDER BY nr.region ,medal	

	create extension tablefunc ;--in order to use the function crosstab we need to first enable the extension tablefunc

	SELECT country,
	coalesce(gold,0) as gold,coalesce(silver,0) as silver ,coalesce(bronze,0)as bronze
	FROM crosstab ( 'SELECT nr.region as country ,medal,count(nr.region)as total_medals
					FROM OLYMPIC_HISTORY oh 
					JOIN noc_regions as nr ON oh.noc=nr.noc
					WHERE medal<>''NA'' 
					GROUP BY nr.region ,medal 
					ORDER BY nr.region ,medal',
					'Values (''Bronze''),(''Gold''),(''Silver'')')
				as result (country varchar,Bronze bigint,Gold bigint , Silver bigint)
	ORDER BY gold desc , silver desc , bronze desc 
	limit 5;
--15 List down total gold, silver and broze medals won by each country corresponding to each olympic games.
	
	SELECT * 
	FROM(
	SELECT concat(oh.games,'-',nr.region) as games ,medal,count (nr.region)as total_medals
	FROM OLYMPIC_HISTORY oh 
	JOIN noc_regions as nr ON oh.noc=nr.noc
	WHERE oh.medal<>'NA'
	GROUP BY oh.games,nr.region ,medal 
	ORDER BY oh.games,nr.region ,medal) x 
	WHERE games='1896 Summer' AND country='Australia'

	WITH CTE AS
			(SELECT games ,
			coalesce(gold,0) as gold,coalesce(silver,0) as silver ,coalesce(bronze,0)as bronze
			FROM crosstab ( 'SELECT concat(oh.games,''-'',nr.region) as games ,medal,count(nr.region)as total_medals
							 FROM OLYMPIC_HISTORY oh 
							 JOIN noc_regions as nr ON oh.noc=nr.noc
							 WHERE oh.medal<>''NA''
							 GROUP BY oh.games,nr.region ,medal 
							 ORDER BY oh.games,nr.region ,medal',
							'Values (''Bronze''),(''Gold''),(''Silver'')')
						as result (games varchar ,Bronze bigint,Gold bigint , Silver bigint))
			--ORDER BY gold desc , silver desc , bronze desc	)

	SELECT SPLIT_PART(games::text,'-',1) as games,
		   SPLIT_PART(games::text,'-',2) as Region,
		   gold,silver,bronze
	FROM CTE




-- Question 16 Identify which country won the most gold, most silver and most bronze medals in each olympic games.

	SELECT games,medal,concat(region,'-',count)as region_with_medal
	FROM(
		SELECT x.games,x.medal,x.region ,x.count,
		CASE WHEN x.medal='Gold' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_gold,
		CASE WHEN x.medal='Silver' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_silver,
		CASE WHEN x.medal='Bronze' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_Bronze
		FROM (Select oh.games,oh.medal, nr.region,count(nr.region) as count
			FROM olympic_history oh
			JOIN noc_regions nr ON oh.noc=nr.noc
			WHERE medal<>'NA'
			GROUP BY oh.games,oh.medal,nr.region
			ORDER BY oh.games)as x)y
	WHERE count=max_gold OR count=max_silver OR count=max_bronze



	SELECT games,Bronze,Gold,Silver
	FROM CROSSTAB  ('SELECT games,medal,concat(region,''-'',count)as region_with_medal
					FROM(
						SELECT x.games,x.medal,x.region ,x.count,
						CASE WHEN x.medal=''Gold''  AND count=max(count)over(partition by x.games,medal) THEN count END AS max_gold,
						CASE WHEN x.medal=''Silver'' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_silver,
						CASE WHEN x.medal=''Bronze'' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_Bronze
						FROM (Select oh.games,oh.medal, nr.region,count(nr.region) as count
							FROM olympic_history oh
							JOIN noc_regions nr ON oh.noc=nr.noc
							WHERE medal<>''NA"''
							GROUP BY oh.games,oh.medal,nr.region
							ORDER BY oh.games)as x)y
					WHERE count=max_gold OR count=max_silver OR count=max_bronze',
					'Values (''Bronze''),(''Gold''),(''Silver'')')
					as result (games varchar ,Bronze varchar,Gold varchar , Silver varchar)



-- Question 17 Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
	
	WITH t1 AS
				(SELECT games,max_Gold,max_Silver,max_Bronze
				FROM CROSSTAB  ('SELECT games,medal,concat(region,''-'',count)as region_with_medal
								FROM(
									SELECT x.games,x.medal,x.region ,x.count,
									CASE WHEN x.medal=''Gold''  AND count=max(count)over(partition by x.games,medal) THEN count END AS max_gold,
									CASE WHEN x.medal=''Silver'' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_silver,
									CASE WHEN x.medal=''Bronze'' AND count=max(count)over(partition by x.games,medal) THEN count END AS max_Bronze
									FROM (Select oh.games,oh.medal, nr.region,count(nr.region) as count
										FROM olympic_history oh
										JOIN noc_regions nr ON oh.noc=nr.noc
										WHERE medal<>''NA"''
										GROUP BY oh.games,oh.medal,nr.region
										ORDER BY oh.games)as x)y
								WHERE count=max_gold OR count=max_silver OR count=max_bronze',
								'Values (''Bronze''),(''Gold''),(''Silver'')')
								as result (games varchar ,max_Bronze varchar,max_Gold varchar , max_Silver varchar)),
		t2 AS (SELECT x.games, concat(x.region,'-', x.total_medals)as max_medals
				 FROM (Select oh.games, nr.region,count(medal) as total_medals,
					  row_number()over(partition by games order by count(medal) desc)as rn
					  FROM olympic_history oh
					  JOIN noc_regions nr ON oh.noc=nr.noc
					  WHERE medal<>'NA'
					  GROUP BY oh.games,nr.region
					  ORDER BY oh.games)x
				 WHERE x.rn=1)					
	SELECT t1.games,t1.max_Gold,t1.max_Silver,t1.max_Bronze,t2.max_medals
	FROM t1 
	JOIN t2 ON t1.games=t2.games

-- Question 18 Which countries have never won gold medal but have won silver/bronze medals?
   
   select * from (
    	SELECT country, coalesce(gold,0) as gold, coalesce(silver,0) as silver, coalesce(bronze,0) as bronze
    		FROM CROSSTAB('SELECT nr.region as country
    					, medal, count(1) as total_medals
    					FROM olympic_history oh
    					JOIN noc_regions nr ON nr.noc=oh.noc
    					where medal <> ''NA''
    					GROUP BY nr.region,medal order BY nr.region,medal',
                    'values (''Bronze''), (''Gold''), (''Silver'')')
    		AS FINAL_RESULT(country varchar,
    		bronze bigint, gold bigint, silver bigint)) x
    where gold = 0 and (silver > 0 or bronze > 0)
    order by gold desc , silver desc , bronze desc ;




-- Question 19 In which Sport/event, India has won highest medals.

	Select oh.sport , count(medal) as total_medals				  
	FROM olympic_history oh
	JOIN noc_regions nr ON oh.noc=nr.noc
	WHERE medal<>'NA' AND nr.region='India'
	GROUP BY oh.sport
	ORDER BY count(medal) DESC
	LIMIT(1)

-- Question 20 Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.*/

	Select nr.region,oh.sport ,oh.games, count(medal) as total_medals				  
	FROM olympic_history oh
	JOIN noc_regions nr ON oh.noc=nr.noc
	WHERE medal<>'NA' AND nr.region='India' AND oh.sport='Hockey'
	GROUP BY nr.region,oh.sport ,oh.games
	ORDER BY count(medal) desc

