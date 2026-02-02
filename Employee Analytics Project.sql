-- Project: Employee Analytics
-- Name: Arif Ansari
-- Role: Data Analyst
-- Tools: MySQL
-- Date: 2026


create database Employee_Analytics_DB
USE Employee_Analytics_DB;

create table employees (emp_id INT PRIMARY KEY, name VARCHAR(50), dept_id INT,
department VARCHAR(50), salary INT, hire_date DATE);

insert into employees values
(1, 'Aman', 10, 'IT', 60000, '2022-01-10'),
(2, 'Ravi', 10, 'IT', 75000, '2023-03-15'),
(3, 'Neha', 20, 'HR', 50000, '2021-07-20'),
(4, 'Pooja', 20, 'HR', 65000, '2023-01-05'),
(5, 'Karan', 30, 'Sales', 55000, '2022-11-12'),
(6, 'Rahul', 30, 'Sales', 70000, '2023-06-18'),
(7, 'Imran', 10, 'IT', 90000, '2024-02-01');

create table managers (manager_id int primary key,
name varchar(50), dept_id int);
insert into managers values
(1, 'Anil', 10),
(2, 'Sunita', 20),
(3, 'Vikram', 30);

-- Select * from employees;
-- Select * from managers;

-- Task 1: Find all employees working in the IT department with their name and salary.

Select name, salary, department from employees
where department = 'IT';

-- Task 2: Show department-wise employee count and total salary.

Select department, count(emp_id) as emp_count,
sum(salary) as total_salary
from employees
group by department;

-- Task 3:  Find the company’s average salary and show employees earning more than the company average.

Select name, salary from employees
where salary > (Select avg(salary) from employees);

-- Task 4: Find the average salary of each department using a CTE.

With dept_avg as (Select department, avg(salary) as avg_salary
from employees
group by department)
Select department, avg_salary from dept_avg;

-- Task 5: Find employees whose salary is higher than their own department’s average salary.

with emp_dep_avg as (Select name, salary, department,
avg(salary) over (partition by department) as dept_avg
from employees)
Select name, salary, dept_avg, department
from emp_dep_avg
where salary > dept_avg;

-- Task 6: Find the top 2 highest-paid employees in each department.

With high_pay_emp as (Select name, department, salary,
dense_rank() over (partition by department order by salary desc) as rnk
from employees)
Select name, salary, department, rnk
from high_pay_emp
where rnk <= 2;

-- Task 7: Compare each employee’s salary with the previous employee hired in the same department.

with pre_dept_emp as (select name, salary, department, hire_date,
COALESCE(salary - lag(salary) over (partition by department order by hire_date), 0) as diff_salary
from employees)
select name, salary, diff_salary, department
from pre_dept_emp;

-- Task 8: Find employees whose salary is less than the next hired employee in the same department.

Select name, salary, department from (Select name, salary, department,
lead(salary) over (partition by department order by hire_date) as next_sal
from employees)t
where salary < next_sal;

-- Task 9: Find departments whose average salary is greater than the company average salary.

select distinct department from (Select department,
avg(salary) over (partition by department) as dept_avg,
avg(salary) over () as avg_salary
from employees)t
where dept_avg > avg_salary;

-- Task 10: Show each employee’s name, department, salary, 
-- and their manager’s name. Include all employees even if a department has no manager.

select a.name as employees_name, b.name as managers_name,
a.salary, a.department from employees a
left join managers b
on a.dept_id = b.dept_id;

-- Task 11: Show only employees who have a manager, along with the manager’s name and department.

Select a.name as employees_name,
b.name as managers_name, a.department
from employees a
inner join managers b
on a.dept_id = b.dept_id;

-- Task 12: Classify employees as ‘High’, ‘Medium’, or ‘Low’ salary compared to their department average.

with employees_level as (Select name, salary, department,
avg(salary) over (partition by department) as dept_avg
from employees)
Select name, salary, dept_avg,
	case
		when salary > dept_avg then 'High'
		when salary = dept_avg then 'Medium'
		else 'Low'
	end as emp_levels
from employees_level;