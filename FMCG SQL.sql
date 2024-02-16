/*1. Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.*/


select distinct market 
from dim_customer
where customer="Atliq Exclusive" and region = "APAC";

/*2. What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg*/


with x as 
       (select count(distinct product_code) as A from fact_sales_monthly
       where fiscal_year=2020),
y as   (select count(distinct product_code) as B from fact_sales_monthly
       where fiscal_year=2021)
       select x. A as unique_products_2020,y.B as unique_products_2021,
       round((B-A)*100/A,2) as percentage_chg
       from x,y;
	
/*3. Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count*/


select segment, count(distinct product_code) as product_count
       from dim_product
       group by segment
       order by product_count desc;
       
/*4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference*/


with x as
(select segment, count(distinct p.product_code) as product_count_2020
       from dim_product p 
       join fact_gross_price f 
       on p.product_code = f.product_code
       where fiscal_year="2020"
       group by segment),
y as
       (select segment, count(distinct p.product_code) as product_count_2021
       from dim_product p 
       join fact_gross_price f 
       on p.product_code = f.product_code
       where fiscal_year="2021"
       group by segment)
select x.segment,x.product_count_2020,y.product_count_2021,
	   (y.product_count_2021-x.product_count_2020) as difference
       from x
       join y
       on x.segment = y.segment;
       
/*5. Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost*/


select  p.product_code,p.product,f.manufacturing_cost as "manufacturing_cost in Rs"
      from fact_manufacturing_cost f
      join dim_product p 
	  on p.product_code=f.product_code
      where manufacturing_cost in ((select max(manufacturing_cost) from fact_manufacturing_cost), 
								   (select min(manufacturing_cost) from fact_manufacturing_cost))
                                   
/*6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage*/


Select c.customer, c.customer_code, round(avg(pre_invoice_discount_pct),3)as average_discount_percentage
     from fact_pre_invoice_deductions f
     join dim_customer c
	 on c.customer_code = f.customer_code
     where fiscal_year="2021"
     group by c.customer_code , c.customer
     order by average_discount_percentage desc
     limit 5;

/*7. Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount*/
use gdb023;
select monthname(m.date) as month ,m.fiscal_year as year,
	  round(sum(g.gross_price*m.sold_quantity)/1000000,2)as Gross_Sales_Amount_mln
	   from fact_sales_monthly m
       join fact_gross_price g
	   on  m.product_code=g.product_code
       join dim_customer c 
       on c.customer_code = m.customer_code
       where c.customer="Atliq Exclusive"
       group by month,year;
       
       
/*8. In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity*/


select 
	case
	 when date between '2019-09-01' and '2019-11-01' then 1  
     when date between '2019-12-01' and '2020-02-01' then 2
     when date between '2020-03-01' and '2020-05-01' then 3
	 when date between  '2020-06-01' and '2020-08-01' then 4
    end as Quarters , 
         sum(sold_quantity) as Total_sold_Quantity
          from fact_sales_monthly
          where fiscal_year="2020"
          group by Quarters
          order by Total_sold_Quantity desc;
          
/*10. Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
product
total_sold_quantity
rank_order*/ 



with x as (
      select p.division,p.product_code,p.product,sum(s.sold_quantity) as total_sold_quantity
      from dim_product p 
      join fact_sales_monthly s 
      on p.product_code = s. product_code
      where fiscal_year = "2021"
      group by p.division,p.product_code,p.product),
   y as   
      (select * ,dense_rank() over(partition by division order by total_sold_quantity desc) as rank_order
      from x)
	   select * from y
       where rank_order<=3;          
       