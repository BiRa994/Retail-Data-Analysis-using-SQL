create database Retail_DA


-----------Retail_DA database-----------


use Retail_DA

---------Converting to Suitable Datatypes-----------

------Qty,Rate,Tax,total_amt.

Select * from Transactions


Alter Table Transactions
Alter column total_amt Numeric

------------------------------------------------------------------------------------------------------------------

--------------------------Data Preparation and Understanding------------------------------------------------------

/* Q-1. What is the total number of rows in each of the 3 tables in database ? */

-------BEGIN

SElect count(*)[Customer Row Count] from Customer
SElect count(*)[Prod Row Count] from prod_cat_info
SElect count(*)[Transactions Row Count] from Transactions

--------END


/* Q-2. What is the total no. of transactions that have a return? */

--------BEGIN

Select count(transaction_id) [ Product RETURN Transactions] from Transactions
Where total_amt<0

---------END


/* Q-3. As you have noticed, date provided across the dataset are not in a correct format.
As first step,convert the date variables into valid date formats before proceeding ahead ? */

--------BEGIN

update Transactions
set tran_date = convert(datetime2,tran_date,105)

Alter table Transactions
alter column tran_date datetime2


update Customer
set DOB = convert(datetime2,DOB,105)
select month(DOB) from Customer

Alter table Customer
alter column DOB datetime2

--------END


/* Q-4. What is the time range of the transaction data available for analysis?
Show the output in number of days,month and years simultaneously in different columns. */

-------BEGIN

Select Datediff(year,min(tran_date),max(tran_date))[Year Range],
Datediff(month,min(tran_date),max(tran_date))[Month Range],
Datediff(Day,min(tran_date),max(tran_date))[Day Range]
from transactions

--------END


/* Q-5. Which product category does the sub-category 'diy' belongs to? */

-------BEGIN

Select prod_cat from prod_cat_info
Where prod_subcat ='DIY'

--------END


-----------------------------------Data Analysis-------------------------------------------------------

/* Q-1. Which channel is most frequently used for transactions? */

---------BEGIN

Select Top 1 Store_type,Sum(total_amt)[Total Sales] from Transactions
group by Store_type
order by [Total Sales] desc

---------END

/* Q-2. What is the count of male and female customers in the database? */

--------BEGIN

Select Gender,count(customer_Id) from Customer
group by Gender

-------END

/* Q-3.  From which city do we have maximum number of customers and how many? */

-------BEGIN

Select Top 1 city_code,count(customer_id)[Customer Count] from Customer
group by city_code
order by [Customer Count]Desc

--------END

/* Q-4.How many sub-categories are there under the books category? */

-------BEGIN

Select Count(prod_subcat)[Book Sub-Categories] from prod_cat_info
where prod_cat='Books'

-------END


/* Q-5. What is the maximum quantity of products ever ordered? */

-------BEGIN

Select Top 1 Sum(qty)[Quantity],tran_date from Transactions
group by tran_date
order by [Quantity] desc

-------END


/*Q-6. What is the net total revenue generated in categories 'Electronics and  Books'? */

------BEGIN

Select Prod_cat,Sum(total_amt-Tax) [Net Revenue] from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code 
And t.prod_subcat_code = p.prod_sub_cat_code
group by prod_cat
having prod_cat in ('Electronics','Books')

------END

/* Q-7. How many customers have >10 transactions with us, excluding returns? */

------BEGIN

Select count(cust_id)[Customers with greater than 10 transactions] from 
(select cust_id from Transactions
where total_amt>0
group by cust_id
having count(transaction_id)>10 ) s1

------END

/* Q-8. What is the combined revenue earned from "Electronics" and "clothing" categories, from "Flagship stores" ? */

---------BEGIN

SELECT SUM(TOTAL_AMT) AS COMBINED_REVENUE
FROM Transactions T
INNER JOIN prod_cat_info p
ON T.prod_cat_code = p.prod_cat_code AND prod_sub_cat_code = PROD_SUBCAT_CODE
WHERE PROD_CAT IN ('CLOTHING','ELECTRONICS') AND STORE_TYPE = 'FLAGSHIP STORE'

---------END



/* Q-9.  What is total revenue generated from "Male" customers in "Electronics"  category? 
Output should display total revenue by product sub category ? */

---------BEGIN

Select prod_subcat,Sum(total_amt)[Total Revenue]
from Customer c inner join Transactions t on c.customer_Id=t.cust_id
inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
where  Gender='M' and prod_cat='Electronics'
group by prod_subcat

---------END




/* Q-10. What is the % of sales and return by product sub category; 
dispaly only top 5 sub categories in terms of sales? */

--------BEGIN

Select top 5 (select sum(total_amt) from transactions where total_amt>0)/sum(total_amt)*100 [Percentage of sales],
(select sum(total_amt) from Transactions where total_amt<0)/sum(total_amt)*100 [Percentage of returns]
from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
group by prod_sub_cat_code 
order by sum(total_amt) desc

---------END


/* Q-11. For all customers aged between 25 to 35 years find what is the net total revenue
generated by these consumers in last 30 days of transactions from max transactions
date available in the data? */

-------BEGIN

Select  c.customer_Id,C.DOB,Datediff(year,DOB,getdate()) [Age],sum(total_amt-Tax) [Net Revenue]
from Customer c inner join Transactions t on c.Customer_id=t.cust_id
where datediff(year,DOB,getdate())  between 25 and 35 and tran_date>dateadd(day,-30,(select max(tran_date)from transactions))
group by customer_Id ,DOB
order by [Net Revenue] desc

-------END

/* Q-12. Which product category has seen maximum value of returns in the last 
3 months of transactions? */

--------BEGIN

Select top 1 prod_cat,sum(total_amt)[MAX Product Returned] 
from prod_cat_info p inner join Transactions T on p.prod_cat_code=t.prod_cat_code
AND p.prod_sub_cat_code=t.prod_subcat_code
where total_amt<0 and tran_date > DATEADD(Day,-90,(select max(tran_date) from transactions))
group by prod_cat
order by [MAX Product Returned]

--------END




/* Q-13. Which store-type sells the maximum products; by value of sales amount and
by quantity sold ? */

--------BEGIN

Select top 1 Store_type, sum(total_amt)[MAX Sales] ,sum(Qty)[Max.QTY]
from prod_cat_info p inner join Transactions T on p.prod_cat_code=t.prod_cat_code
ANd p.prod_sub_cat_code=t.prod_subcat_code
group by Store_type
order by [MAX Sales] desc,[Max.QTY] desc

--------END


/* Q-14. What are the categories for which revenues are above the overall average? */

---------BEGIN

Select Prod_cat,avg(total_amt)[Average REvenue] 
from (select t.*, avg(total_amt) over() [Overall Average] from Transactions t) T inner join
prod_cat_info p  on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
group by prod_cat,  [Overall Average]
having avg(total_amt) >[Overall Average]

---------END



/* Q-15. Find the average and total revenue by each sub category for the category
which are among 5 categories in terms of quantity sold? */

---------BEGIN

Select top 5 p.prod_cat,p.prod_subcat, avg(total_amt)[Average Rvenue],sum(total_amt)[Total Revenue]
from prod_cat_info p inner join Transactions t on  p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code 
where prod_cat in (select top 5 prod_cat from prod_cat_info p inner join transactions t 
on p.prod_cat_code =t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
group by prod_cat
order by sum(Qty) Desc)
group by prod_cat,prod_subcat

---------END



Select * from prod_cat_info
Select * from Transactions

Select * from Customer