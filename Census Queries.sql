-- to count number of rows-- 
SELECT COUNT(*) FROM dataset1;
SELECT COUNT(*) FROM dataset2;

-- dataset for Jharkhand and Bihar--
SELECT * FROM census.dataset1
WHERE State IN ('Jharkhand' , 'Bihar') ORDER BY State, District;

-- to calculate the total population of india--
SELECT SUM(Population) AS TotalPopulation FROM dataset2 ;

-- calculate average growth--
SELECT ROUND(AVG(Growth)*100,2) AS AvgGrowth FROM dataset1;



-- calculate average growth of each state--
SELECT State, ROUND(AVG(Growth)*100,2) AS AvgGrowth FROM dataset1 group by State;

-- avg sex ratio--
SELECT ROUND(avg(Sex_Ratio),2) AS Avg_SexRatio FROM dataset1; 

-- calculate average sex ratio of each state--
SELECT State, ROUND(AVG(Sex_Ratio),0) AS Avg_SexRatio FROM census.dataset1 GROUP BY State ORDER BY Avg_SexRatio DESC;

-- avg literacy rate--
SELECT ROUND(avg(Literacy),2) AS Avg_Literacy FROM dataset1; 

-- calculate average literacy rate of each state--
SELECT State, ROUND(AVG(Literacy),0) AS Avg_Literacy FROM census.dataset1 GROUP BY State ORDER BY Avg_Literacy DESC;

-- calculate average literacy rate of each state having rate>90--
SELECT State, ROUND(AVG(Literacy),0) AS Avg_Literacy FROM census.dataset1 GROUP BY State HAVING Avg_Literacy>90 ORDER BY Avg_Literacy DESC ;

-- top 3 states showing highest growth ratio--
SELECT State, ROUND(AVG(Growth)*100,2) AS AvgGrowth FROM dataset1 group by State ORDER BY AvgGrowth DESC LIMIT 3 ;

-- TOP 3 states showing lowest sex ratio--
SELECT State, ROUND(AVG(Sex_Ratio),0) AS Avg_SexRatio FROM census.dataset1 GROUP BY State ORDER BY Avg_SexRatio LIMIT 3;

-- Top 3 and Bottom 3 state in literacy rate--
-- making a temp table--
CREATE TEMPORARY TABLE topstates(
State varchar(255),
TopState float
);

INSERT INTO topstates
SELECT State, round(AVG(Literacy),0) AS Avg_Literacy
FROM census.dataset1
GROUP BY State
ORDER BY Avg_Literacy DESC;

SELECT * FROM topstates ORDER BY TopState DESC LIMIT 3; 

CREATE TEMPORARY TABLE bottomstates(
State varchar(255),
BottomState float
);

INSERT INTO bottomstates
SELECT State, round(AVG(Literacy),0) AS Avg_Literacy
FROM census.dataset1
GROUP BY State
ORDER BY Avg_Literacy DESC;

SELECT * FROM bottomstates ORDER BY BottomState LIMIT 3; 
-- UNION OF THE TWO RESULT--
-- SELECT * FROM --
-- need to make a subquery --
(SELECT * FROM topstates ORDER BY TopState DESC LIMIT 3) 
UNION
-- SELECT * FROM --
(SELECT * FROM bottomstates ORDER BY BottomState LIMIT 3) ; 

-- select states with letter a -- 
SELECT DISTINCT State FROM dataset1 WHERE State LIKE 'A%' ;

-- select states with letter a or b--
SELECT DISTINCT State FROM dataset1 WHERE LOWER(State) LIKE 'a%' OR LOWER(State) LIKE 'b%';

-- select states with letter a and ending with d--
SELECT DISTINCT State FROM dataset1 WHERE LOWER(State) LIKE 'a%' AND LOWER(State) LIKE '%d';

-- joining both table

-- total males and females--
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) AS males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) AS females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from census.dataset1 AS a inner join census.dataset2 AS b on a.district=b.district ) AS c) AS d
group by d.state;

-- total literacy rate--
select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from census.dataset1 AS a 
inner join census.dataset2 AS b on a.district=b.district)AS d)AS c
group by c.state;

-- population in previous census--
select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from census.dataset1 AS a inner join census.dataset2 AS b on a.district=b.district) AS d)AS e
group by e.state) AS m;


-- population vs area--
select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (
select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from census.dataset1 a inner join census.dataset2 AS b on a.district=b.district) AS d) AS e
group by e.state)AS m) AS n)AS  q inner join (
select '1' as keyy,z.* from (
select sum(area_km2) total_area from census.dataset2)z)AS r on q.keyy=r.keyy) AS g

-- window 
output top 3 districts from each state with highest literacy rate 
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1) a

where a.rnk in (1,2,3) order by state;