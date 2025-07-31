-- view all the tables in world database

select table_name
from information_schema.tables
where table_schema= 'world';

-- inspect the city table

select *
from city;

-- make a copy of the city table and clean the table

create table city_staging
like city;

insert into city_staging
select *
from city;

-- check the number of columns and rows in the city staging table

-- fetch the number of columns

select count(*) as numOfColumn
from information_schema.columns
where table_name='city_staging';

-- fetch the number of rows
select count(*) as numOfRows
from city_staging;

-- the table contains 5 columms and 4079 rows

-- get the table descriptive statistics
select min(population) as minDistrictPopulation,
	   max(population) as maxDistrictPopulation,
       round(avg(population),2) as avgDistrictPopulation,
       round(stddev(population),2) as stdOfDistrictPopulation
from city_staging;

-- the least populated district has 42people and the most populated district has 10,500,000people
-- with average of 350,468people and variability of 723,686.

-- check for missing value and wrong spelling acrross the columns

-- check for distinct 
select distinct id
from city_staging
order by id asc;

-- check for unique names
select distinct name as uniqueName
from city_staging
order by name asc;

-- clean by replacement
select replace('[San Cristóbal de] la Laguna','[San Cristóbal de] la Laguna','San Cristóbal de la Laguna')
from city_staging
where name like '[San Cristóbal de] la Laguna%';

-- update the table
set sql_safe_updates= 0;

update city_staging
set name = replace('[San Cristóbal de] la Laguna','[San Cristóbal de] la Laguna','San Cristóbal de la Laguna')
where name like '[San Cristóbal de] la Laguna%';

set sql_safe_updates= 1;

-- check for missing values
select name
from city_staging
where name is null or name ='';

-- result show no missing value.

-- the next column country code

select distinct countrycode
from city_staging;

-- check for missing values

select countrycode
from city_staging
where countrycode is null or countrycode ='';

-- no missing rows

-- check the district column

select distinct district
from city_staging
order by district;

-- the is one blank row, need to remove
set sql_safe_updates =0;
update city_staging
set district= 'Oranjestad'
where id = 129;

update city_staging
set district= 'south Hill'
where id = 61;

update city_staging
set district= 'The Valley'
where id = 62;

set sql_safe_updates =1;

-- check the population

-- check missing values

select population as districtPopulation
from city_staging
where population is null;

-- rename column
alter table city_staging
rename column Population to districtPopulation;


-- no missing values.

-- check the final size of table
select count(*) as rowtotal
from city_staging;

-- have a final row tootal of 4075 from initial 4079.

-- clean city staging table
select *
from city_staging;

-- review and clean the country table

-- first copy the country table
create table country_staging
like country;

insert into country_staging
select *
from country;

select * from country_staging;

-- perform feature engineering by selecting the relevant columns.
alter table country_staging
drop column region;
alter table country_staging
drop column surfacearea;
alter table country_staging
drop column governmentform;
alter table country_staging
drop column headofstate;
alter table country_staging
drop column code2;

-- clean the columns
select *
from country_staging
where code is null or code=''
or name is null or name=''
or continent is null or continent=''
or population is null or population=''
or lifeexpectancy is null
or gnp is null
or capital is null;

-- count number of missing values per column

select
count(*) as totalRows,
count(if(code is null,1,null)) as missing_code,
count(if(name is null,1,null)) as missing_name,
count(if(continent is null,1,null)) as missing_continent,
count(if(population is null,1,null)) as missing_population,
count(if(lifeexpectancy is null,1,null)) as missing_lifeexpectancy,
count(if(gnp is null,1,null)) as missing_gnp,
count(if(capital is null,1,null)) as missing_capital
from country_staging;

-- shows we have 17 missing values in lifeexpectancy and 7 from capital making a total of 24
-- out of 239. since there is no substantial information on the column data we can drop the rows


set sql_safe_updates= 0;
delete from country_staging
where lifeexpectancy is null;
set sql_safe_updates= 1;

-- update the capital column missing values with average value

select avg(capital) as avgCapital
from country_staging;

-- the avreage capital is 2053.17
set sql_safe_updates= 0;
update country_staging
set capital= 2053.17
where capital is null;
set sql_safe_updates= 1;

-- clean country staging table



-- combined both table for further analysis
alter table country_staging
rename column name to contryName;

create temporary table combined_table as
select   *
from city_staging ct
join country_staging cy
	on ct.countrycode = cy.code;
    

select * from combined_table;    

				-- ANALYSING THE DATA    
-- Objective
-- top 5 populous district
-- correlation between life expectancy and country gnp

SELECT district, SUM(districtpopulation) AS total_population
FROM combined_table
GROUP BY district
ORDER BY total_population DESC
LIMIT 5;

-- shows Sao paulo is the most populous district in the world with 26,316,966people
-- followed by Maharasha(23,659,433),England(19,978,543),Punjab(19,708,438) and California(16,716,706)

-- correlation between life expectancy and Gnp
Select 
    (count(*) * sum(lifeexpectancy * gnp) 
     - sum(lifeexpectancy) * sum(gnp)) / 
    SQRT((count(*) * sum(power(lifeexpectancy, 2)) - power(sum(lifeexpectancy), 2)) * 
         (count(*) * SUM(power(gnp, 2)) - power(sum(gnp), 2))) AS correlation
from combined_table;

-- the correlation coefficient is 0.4262, indicating a positive relationship between Gnp and life expectancy.
-- A plausible inference from this is that, the richer a country is, the better she is able to provide basic needs 
-- such as good healthcare, hygiene environment, food and other life sustaining facilities.

					-- LIFE EXPECTANCY

-- country's ife expectancy relative to global average life expectancy

select round(avg(lifeexpectancy),1) into @avg_lifeexp
from combined_table;

select contryName, continent, lifeexpectancy, @avg_lifeexp as world_avg_lifeexpectancy
from combined_table
order by lifeexpectancy desc;

-- top 2 continent whose life expectancy is greater the global average

select round(avg(lifeexpectancy),1) into @avg_lifeexp
from combined_table;

select continent, lifeexpectancy, @avg_lifeexp as world_avg_lifeexpectancy
from combined_table
where lifeexpectancy > @avg_lifeexp 
order by lifeexpectancy desc
limit 2 ;

-- within the Europe continent, which country has the highest life expectancy

select round(avg(lifeexpectancy),1) into @avg_lifeexp
from combined_table;

select contryName, continent, lifeexpectancy, @avg_lifeexp as world_avg_lifeexpectancy
from combined_table
where continent='Europe' 
order by lifeexpectancy desc
limit 5 ;

-- within the country Andorra which district has the highest and lowest life expectancy

select round(avg(lifeexpectancy),1) into @avg_lifeexp
from combined_table;

select district,contryName, continent, lifeexpectancy, @avg_lifeexp as world_avg_lifeexpectancy
from combined_table
where contryName='Andorra' 
order by lifeexpectancy desc
limit 5 ;

-- The results show Europe has the highest life expectancy of 83.5, followed by Asia at 81.6 comparred to global average of 69.6.
-- Within Europe, people in Andorra generally live longer(approx 84years), particularly people from Andorra la Vella (83.5 years) 
-- than any where else in the world (70years approx.)


						-- POPULATION
-- country's population relative to the average world population

select round(avg(population),1) into @avg_population
from combined_table;

select id, contryName,population, @avg_population as avg_world_population
from combined_table;

-- top 5 country whose population is greater than the average global population
select round(avg(population),1) into @avg_population
from combined_table;
select id, contryName, population, @avg_population as avg_world_population, (population/@avg_population)*100 as percentageOfWorld
from combined_table
where population > @avg_population
order by population desc;

-- the result shows China population is approx 465.10% greater than the average world population










