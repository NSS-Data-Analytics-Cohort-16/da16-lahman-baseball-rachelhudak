-- **Directions:**  
-- * Within your repository, create a directory named "scripts" which will hold your scripts.
-- * Create a branch to hold your work.
-- * For each question, write a query to answer.
-- * Complete the initial ten questions before working on the open-ended ones.

-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT 
    MIN(yearID) AS first_year,
    MAX(yearID) AS last_year
FROM teams;



-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
  --  find shortest player, name, how many gamesplayed, name of the team -- teams table, player table, appearances
  		-- 1) shortest player - people tableon
		-- 2) name and height - people table
		-- 3) how many games played - appearances 
		-- 4) team name - teams
	-- select, games, from, whee
-- 1) shortest player - people tableon
SELECT
	p.namefirst || '' || p.namelast AS fullname,
	MIN (p.height) AS shortest.player,
		(SELECT playerid, a.g_all
			FROM appearances AS a
			join (SELECT MIN (height) FROM people LIMIT 1)
			) AS total_games

FROM people AS p
GROUP BY p.namefirst, p.namelast

-- 2) name and height - people table
SELECT 
    p.name.first,
    p.name.last,
    p.height,
    SUM(a.g_all) AS total_games,
    t.name AS team_name
FROM player.id
JOIN appearances a 
    ON p.playerid = a.playerid
JOIN teams t 
    ON a.teamid = t.teamid AND a.yearid = t.yearid
WHERE p.height = (
    SELECT MIN(height)
    FROM people
)
GROUP BY p.name.first, p.name.last, p.height, t.name;

















-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- SELECT 
--     p.namefirst,
--     p.namelast,
--     SUM(s.salary) AS total_salary
-- FROM people p
-- JOIN collegeplaying c 
--     ON p.playerid = c.playerid
-- JOIN salaries s 
--     ON p.playerid = s.playerid
-- WHERE c.schoolid = 'vandy'  -- or use LIKE '%Vanderbilt%'
-- GROUP BY p.name_first, p.name_last
-- ORDER BY total_salary DESC;

SELECT
	c.playerid,
	c.schoolid,
	SUM(s.salary)::NUMERIC::MONEY AS total_salary,
	s.lgid AS league
FROM collegeplaying c
INNER JOIN salaries s USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY c.playerid,
	c.schoolid,
	s.lgid
ORDER BY total_salary DESC;






-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT
  CASE
    WHEN pos = 'OF' THEN 'Outfield'
    WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
    WHEN pos IN ('P', 'C') THEN 'Battery'
  END AS position_group,
  SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position_group;





-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT
  (yearid / 10) * 10 AS decade,
  ROUND(SUM(so) * 1.0 / SUM(g), 2) AS avg_strikeouts_per_game,
  ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS avg_homeruns_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;









-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	
SELECT
  playerid,
  (sb * 1.0) / (sb + cs) AS success_rate,
  sb,
  cs,
  (sb + cs) AS attempts
FROM batting
WHERE yearid = 2016
  AND (sb + cs) >= 20
ORDER BY success_rate DESC
LIMIT 1;








-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
WITH most_wins AS (
	SELECT
		yearid,
		MAX(w) AS w
	FROM teams
	WHERE yearid >= 1970
	GROUP BY yearid
	ORDER BY yearid
	),
most_win_teams AS (
	SELECT 
		yearid,
		name,
		wswin
	FROM teams
	INNER JOIN most_wins
	USING(yearid, w)
)
SELECT 
	(SELECT COUNT(*)
	 FROM most_win_teams
	 WHERE wswin = 'N'
	) * 100.0 /
	(SELECT COUNT(*)
	 FROM most_win_teams
	);

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT 
	--(SELECT park_name FROM parks),
	p.park_name,
	h.attendance,
	t.name,
	h.games,
	h.attendance/ h.games AS attendance_per_game
FROM homegames h
INNER JOIN parks p ON p.park = h.park
INNER JOIN teams t ON t.teamidlahman45 = h.team AND t.yearid = h.year
WHERE h.year = 2016
AND games >=10
ORDER BY attendance_per_game DESC
LIMIT 5










-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
WITH both_league_winners AS (
	SELECT
		playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('AL', 'NL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2
	) -- there are only 2 people that fit this criteria.

-- SELECT 
-- 	* 
-- FROM awardsmanagers 
-- WHERE awardid = 'TSN Manager of the Year' 
-- 	AND  lgid IN ('AL', 'NL')
-- G-- 100 rows total --60 rows won in both

SELECT
	namefirst || ' ' || namelast AS full_name,
	yearid,
	lgid,
	name
FROM people
INNER JOIN both_league_winners
	USING(playerid)
INNER JOIN awardsmanagers
	USING(playerid)
INNER JOIN managers
	USING(playerid, yearid, lgid)
INNER JOIN teams
	USING(teamid,yearid,lgid)
WHERE awardid = 'TSN Manager of the Year'
ORDER BY full_name, yearid;

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--   *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
--   *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
