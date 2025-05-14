Select * from sales

--Data Cleaning 
--Step 1:- To Check For Duplicate

select transaction_id, count(*)
from sales
group by transaction_id
having count(transaction_id)>1;

with cte as (
    select *,
	ROW_NUMBER() over(partition by transaction_id order by transaction_id)as Row_Num
	from sales
)
--delete from cte
--where Row_Num =2

select * from cte

--Step 2:- Correction for Headers
Select * from sales

EXEC sp_rename'sales.quantiy', 'quantity' 
EXEC sp_rename'sales.prce', 'price' 

--Step 3:- To Check Datatype 

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

--Step 4:- To Check Null Values
DECLARE @table_name NVARCHAR(MAX) = 'sales';
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @columns NVARCHAR(MAX) = '';

-- Get all column names
SELECT @columns = STRING_AGG(QUOTENAME(name) + ' IS NULL', ' OR ')
FROM sys.columns
WHERE object_id = OBJECT_ID(@table_name);

-- Build full SQL
SET @sql = 'SELECT * FROM ' + QUOTENAME(@table_name) + ' WHERE ' + @columns;

-- Execute
EXEC sp_executesql @sql;

-- Treading Null Values

select *
from sales 
where transaction_id is null
or
 customer_id is null 
or
customer_name is null
or 
customer_age is null
or
gender is null
or 
product_id is null
or 
product_name is null
or
 product_category is null
or 
quantity is null
or
 price is null
or 
payment_mode is null
or
purchase_date is null
or 
 time_of_purchase is null
or 
 status is null

 select * from sales
 
delete from sales 
where transaction_id is null;

select * from sales
where customer_name='Ehsaan Ram'

update sales
set customer_id='CUST9494'
where transaction_id='TXN977900'

select * from sales
where customer_name='Damini Raju'

update sales
set customer_id='CUST1401'
where transaction_id='TXN985663'

select * from sales
where customer_id='CUST1003'

update sales
set customer_name='Mahika Saini', customer_age=35, gender='Male'
where transaction_id='TXN432798'

select * from sales

-- Steep 5:- Data Cleaning

select * from sales

update sales
set gender ='Male'
Where gender ='M'

update sales
set gender ='Female'
Where gender ='F'

--Payment_Mode Cleaning 
select distinct payment_mode from sales

update sales
set payment_mode ='Credit Card'
Where payment_mode ='CC'

-- Data Analysis --
 
-- 1 What are the top 5 most selling products by quantity?

select * from sales

select distinct status from sales

select top 5 product_name, sum(quantity) as total_quantity_sold
from sales 
where status = 'delivered'
group by product_name
order by total_quantity_sold desc
 
 --	Business Problem: We Don't know which products are most in demand.

-- Business Impact: Helps prioritze stock and boost sales through the target promotions.

---------------------------------------------------------------------------------------------------

-- 2. Which products are most frequently cancelled?


select top 5 product_name, sum(quantity) as total_Cancelled
from sales 
where status = 'cancelled'
group by product_name
order by total_Cancelled desc

 --	Business Problem: Frequent cancelleations affect revenue and customer trust.

-- Business Impact: Identify Poor-Performing products to imporve quality or remove from catalog.
---------------------------------------------------------------------------------------------------

-- 3. What time of the day has the highest number of purchases?

select * from sales

select 
      case 
	       when datepart(hour, time_of_purchase) between 0 and 5 then 'NIGHT'
		   when datepart(hour, time_of_purchase) between 6 and 11 then 'MORNING'
		   when datepart(hour, time_of_purchase) between 12 and 17 then 'AFTERNOON'
		   when datepart(hour, time_of_purchase) between 18 and 23 then 'EVENING'
        End as time_of_day,
		count(*) as total_orders
   from sales
   group by 
          case 
	       when datepart(hour, time_of_purchase) between 0 and 5 then 'NIGHT'
		   when datepart(hour, time_of_purchase) between 6 and 11 then 'MORNING'
		   when datepart(hour, time_of_purchase) between 12 and 17 then 'AFTERNOON'
		   when datepart(hour, time_of_purchase) between 18 and 23 then 'EVENING'
		   end
   order by total_orders desc


 --	Business Problem Solved: Find peak sales times.

-- Business Impact: Optimize staffing, Promotions, and server loads.
------------------------------------------------------------------------

-- Step 4:- Who are the top 5 highest spending customers?

SELECT TOP 5 
    customer_name, 
     NCHAR(8377) + ' ' + FORMAT(SUM(CAST(price AS INT) * CAST(quantity AS INT)), 'N0', 'en-IN') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(CAST(price AS INT) * CAST(quantity AS INT)) DESC;

 --	Business Problem Solved: Identity VIP Customers.

-- Business Impact: Personalized offers, loyalty rewards, and retention.

--------------------------------------------------------------------------------

-- Step 5:- Which product categories generate the highest revenue?

SELECT 
    product_category , 
     NCHAR(8377) + ' ' + FORMAT(SUM(CAST(price AS INT) * CAST(quantity AS INT)), 'N0', 'en-IN') AS Revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(CAST(price AS INT) * CAST(quantity AS INT)) DESC;


 --	Business Problem Solved: Identify top-performing product categories.

-- Business Impact: Refine product strategy, supply chain, and promotions.
-- Allowing the business to invest more in high-margin or high-demand categories.
------------------------------------------------------------------------------------

-- Step 6:- What is the return/cancellation rate per product category?

--cancellation
SELECT 
    product_category,
    format(COUNT(CASE WHEN status IN ( 'Cancelled') THEN 1 END) * 100.0 / COUNT(*), 'N3')+ ' %' AS Cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY Cancelled_percent DESC;

--return 

SELECT 
    product_category,
    format(COUNT(CASE WHEN status IN ('Returned') THEN 1 END) * 100.0 / COUNT(*), 'N3')+ ' %' AS Return_percent
FROM sales
GROUP BY product_category
ORDER BY Return_percent DESC;

 --	Business Problem Solved: Montior dissatifaction trends per category.

-- Business Impact: Reduce return, imporve product describtions/expectations.
-- Helps identfiy and fix product or logistics issues.

-------------------------------------------------------------------------------------

-- Step 7:- What is the most prefferd payment mode?

select payment_mode, count(payment_mode) as total_count
from sales 
group by payment_mode
order by total_count desc;

 --	Business Problem Solved: Know which payment options customers prefer.

-- Business Impact: Streamline payment processing, prioritize popular modes.

-----------------------------------------------------------------------------------

-- Step 8:- How does age group affect purchasing behavior?

select 
     case 
	     when customer_age between 18 and 25 then '18-25'
		 when customer_age between 26 and 35 then '26-35'
	     when customer_age between 36 and 50 then '36-50'
		 else '51+'
		 end as customer_age,
		 NCHAR(8377) + ' ' + FORMAT(SUM(CAST(price AS INT) * CAST(quantity AS INT)), 'N0', 'en-IN') AS total_purchase 
		 from sales
		 group by case
		 when customer_age between 18 and 25 then '18-25'
		 when customer_age between 26 and 35 then '26-35'
	     when customer_age between 36 and 50 then '36-50'
		 else '51+'  
		end
	order by total_purchase desc;	

 --	Business Problem Solved: Understand customer demographics.

-- Business Impact: Targeted marketing and product recommedations by age group.

--------------------------------------------------------------------------------------------

-- Step 9:- What's the monthly sales trend?

select * from sales

select 
      format(purchase_date, 'yyyy-MM') AS Month_year, 
	  NCHAR(8377) + ' ' + FORMAT(SUM(CAST(price AS INT) * CAST(quantity AS INT)), 'N0', 'en-IN') AS Total_sales,
	  sum(quantity) as Total_quantity
	  from sales
	  group by format(purchase_date, 'yyyy-MM')


 --	Business Problem Solved: Sales flucctuations go unnoticed.

-- Business Impact: Plan inventory and marketing according to seasional trend.

---------------------------------------------------------------------------------------

-- Step 10:- Are certain gender buying more specific product categories?

select gender, product_category, count(product_category) as Total_purchase
from sales
group by gender, product_category
order by Total_purchase;


 --	Business Problem Solved: Gender-based product preferences.

-- Business Impact: Personalized ads, gender-focused campaiagns.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


































