/*1.  Provide the list of markets in which customer  "Atliq  Exclusive"  operates its 
business in the  APAC  region. */
select * from gdb023.dim_customer;
select distinct market from gdb023.dim_customer
where customer ="Atliq Exclusive" and region ="APAC";


/*2.  What is the percentage of unique product increase in 2021 vs. 2020? The 
final output contains these fields, 
unique_products_2020 
unique_products_2021 
percentage_chg */
SELECT X.A AS unique_product_2020, Y.B AS unique_products_2021, ROUND((B-A)*100/A, 2) AS percentage_chg
FROM
     (
      (SELECT COUNT(DISTINCT(product_code)) AS A FROM fact_sales_monthly
      WHERE fiscal_year = 2020) X,
      (SELECT COUNT(DISTINCT(product_code)) AS B FROM fact_sales_monthly
      WHERE fiscal_year = 2021) Y 
	 )



/*3.  Provide a report with all the unique product counts for each  segment  and 
sort them in descending order of product counts. The final output contains 
2 fields, 
segment 
product_count */
select   distinct(segment) , count(product)  from gdb023.dim_product
group by segment  order by count(product) desc;




/*4.  Follow-up: Which segment had the most increase in unique products in 
2021 vs 2020? The final output contains these fields, 
segment 
product_count_2020 
product_count_2021 
difference */
WITH unique_product AS
(
 SELECT
      p.segment AS segment,
      COUNT(DISTINCT
          (CASE 
              WHEN fiscal_year = 2020 THEN s.product_code END)) AS product_count_2020,
       COUNT(DISTINCT
          (CASE 
              WHEN fiscal_year = 2021 THEN s.product_code END)) AS product_count_2021        
 FROM fact_sales_monthly AS s
 INNER JOIN dim_product AS p
 ON s.product_code = p.product_code
 GROUP BY p.segment
)
SELECT segment, product_count_2020, product_count_2021, (product_count_2021-product_count_2020) AS difference
FROM unique_product
ORDER BY difference DESC;


/*5.  Get the products that have the highest and lowest manufacturing costs. 
The final output should contain these fields, 
product_code 
product 
manufacturing_cost */
select p.product_code , p.product , m.manufacturing_cost
from gdb023.dim_product p
join fact_manufacturing_cost as m
using(product_code)
where 
	manufacturing_cost=(select max(manufacturing_cost) from fact_manufacturing_cost) or 
	manufacturing_cost=(select min(manufacturing_cost) from fact_manufacturing_cost)
order by manufacturing_cost desc;



/*6.  Generate a report which contains the top 5 customers who received an 
average high  pre_invoice_discount_pct  for the  fiscal  year 2021  and in the 
Indian  market. The final output contains these fields, 
customer_code 
customer 
average_discount_percentage */
select c.customer_code , c.customer , 
CONCAT(ROUND(AVG(p.pre_invoice_discount_pct)*100,2),'%') AS average_discount_percentage
from gdb023.dim_customer c
join gdb023.fact_pre_invoice_deductions p on c.customer_code = p.customer_code
WHERE market = 'India'
AND fiscal_year = 2021
GROUP BY customer, customer_code
ORDER BY AVG(pre_invoice_discount_pct) DESC
LIMIT 5;



/*7.  Get the complete report of the Gross sales amount for the customer  “Atliq 
Exclusive”  for each month  .  This analysis helps to  get an idea of low and 
high-performing months and take strategic decisions. 
The final report contains these columns: 
Month 
Year 
Gross sales Amount */
SELECT 
       MONTHNAME(date) AS month_name,
       YEAR(date) AS year_, 
       CONCAT('$',ROUND(SUM(s.sold_quantity * g.gross_price)/1000000,2)) AS gross_sales_amount
FROM fact_sales_monthly AS s
INNER JOIN fact_gross_price AS g
ON g.product_code = s.product_code
AND g.fiscal_year = s.fiscal_year
INNER JOIN dim_customer AS c
ON c.customer_code = s.customer_code
WHERE c.customer = 'Atliq Exclusive'
GROUP BY month_name, year_
ORDER BY year_;


/*8.  In which quarter of 2020, got the maximum total_sold_quantity? The final 
output contains these fields sorted by the total_sold_quantity, 
Quarter 
total_sold_quantity */


/*9.  Which channel helped to bring more gross sales in the fiscal year 2021 
and the percentage of contribution?  The final output  contains these fields, 
channel 
gross_sales_mln 
percentage */



/*10.  Get the Top 3 products in each division that have a high 
total_sold_quantity in the fiscal_year 2021? The final output contains these 
fields, 
division 
product_code 
codebasics.io 
product 
total_sold_quantity 
rank_order */
