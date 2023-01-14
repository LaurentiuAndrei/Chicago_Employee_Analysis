-- Preview the dataset
select *
from playgroundDB.current_employee_names

-- Cleaning Task 1: Separate Name into First Name and Last Name, move them as 1st and 2nd column and then delete the original Name column

-- preview result
select substr(name, 1, position(',' in name)-1) FirstName,
substr(name, position(',' in name) + 1, character_length(name)) LastName  
from playgroundDB.current_employee_names

-- create the 2 new columns
alter table playgroundDB.current_employee_names 
add column FirstName nvarchar(50) not null

alter table playgroundDB.current_employee_names 
add column LastName  nvarchar(50) not null

-- Populate the name columns
update playgroundDB.current_employee_names 
set FirstName = substr(name, 1, position(',' in name)-1)

update playgroundDB.current_employee_names 
set LastName = substr(name, position(',' in name) + 1, character_length(name))

-- Change the order of the firstname, lastName columns
alter table playgroundDB.current_employee_names 
modify FirstName nvarchar(50) after `Name`

alter table playgroundDB.current_employee_names 
modify LastName nvarchar(50) after FirstName

-- Delete the original Name column
alter table playgroundDB.current_employee_names 
drop column Name

-- Cleaning task 2: Change the annual salary data type from double to int for easier reading.
alter table playgroundDB.current_employee_names 
modify column `Annual Salary` int

-- 1. What are the top 5 best paid job titles which are being paid annualy?
-- Excluding null salaries. Show job title and average salary.
with rankedYearlySlaries as (
select `Job Titles`, avg(`Annual Salary`) avgYearlySalary, rank() over(order by avg(`Annual Salary`) desc) salary_ranking
from playgroundDB.current_employee_names
where `Annual Salary` is not null
group by 1
order by 3) 

select `Job Titles`, avgYearlySalary
from rankedYearlySlaries
where salary_ranking <= 5

-- 2. What is the average salary for each department in Chicago?
-- Ordered by department ascending. Not including null values.
select Department, avg(`Annual Salary`) avg_Salary
from playgroundDB.current_employee_names
where `Annual Salary` is not null
group by Department
order by Department

-- 3. What is the distribution of salary vs hourly?
select
	case when `Full or Part-Time` = 'F' then 'Full Time'
	when `Full or Part-Time` = 'P' then 'Part Time' end `Full or Part-Time` ,
	round(count(*) / (select count(*) from playgroundDB.current_employee_names where `Full or Part-Time` <> '') * 100, 1) percentage_distribution
from playgroundDB.current_employee_names
where `Full or Part-Time` <> ''
group by 1


-- 4. Compare the paying schemes in terms of yearly average salary
-- People paid in Annual salary vs people paid per hour
select avg(`Annual Salary`) paid_annually, avg(`Typical Hours` * `Hourly Rate` * 51) paid_hourly
from playgroundDB.current_employee_names