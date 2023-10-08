-- query 1
select p.name as name_of_product, m.name as seller_of_product
from merchants m join sell s on m.mid = s.mid join products p on s.pid = p.pid
where s.quantity_available = 0;


-- query 2
select p.name, p.description
from products p left join sell s on p.pid = s.pid
where s.pid is null;


– query 3 
select count(distinct(customers.cid)) as number_of_customers
from customers join place on customers.cid = place.cid
join orders on place.oid = orders.oid
join contain on orders.oid = contain.oid
join products on contain.pid = products.pid
where products.description like '%SATA%' and products.description not like '%Router%';


– query 4 
part1:
update sell
set price = price * 0.8
where mid = (select mid from merchants where name = 'HP')
and pid in (select pid from products where category = 'Networking');
part2:
select * 
from merchants m join sell s on m.mid = s.mid
join products p on s.pid = p.pid
where m.name = 'HP' and p.category = 'Networking';


-- query 5
select products.name, sell.price
from customers join place on customers.cid = place.cid
join orders on place.oid = orders.oid
join contain on orders.oid = contain.oid
join products on contain.pid = products.pid
join sell on products.pid = sell.pid
join merchants on sell.mid = merchants.mid
where customers.fullname = 'Uriel Whitney' and merchants.name = 'Acer';


-- query 6
select m.name as company_name, 
YEAR(p2.order_date) as year, sum(s.price*s.quantity_available) as annual_total_sales
from merchants m join sell s on m.mid = s.mid
join products p on s.pid = p.pid
join contain c on p.pid = c.pid
join orders o on c.oid = o.oid
join place p2 on o.oid = p2.oid
group by m.name, YEAR(p2.order_date)
order by m.name, YEAR(p2.order_date);


– query 7
select m.name as company_name, 
YEAR(p2.order_date) as year, sum(s.price*s.quantity_available) as annual_total_sales
from merchants m join sell s on m.mid = s.mid
join products p on s.pid = p.pid
join contain c on p.pid = c.pid
join orders o on c.oid = o.oid
join place p2 on o.oid = p2.oid
group by m.name, YEAR(p2.order_date)
order by annual_total_sales desc
LIMIT 1;


– query 8
select shipping_method, avg(shipping_cost)
from orders 
group by shipping_method 
having avg(shipping_cost) <= all (
							select avg(shipping_cost)
                            from orders
							group by shipping_method
                            );









– query 9
select m.mid, m.name, p.category, sum(s.price*s.quantity_available) as total_sales
from merchants m join sell s on m.mid = s.mid
join products p on s.pid = p.pid
group by m.mid, m.name, p.category
having total_sales = (
						select max(total_sales) from
							(
							select m2.mid, m2.name, p2.category, sum(s2.price*s2.quantity_available) as total_sales
							from merchants m2 join sell s2 on m2.mid = s2.mid
							join products p2 on s2.pid = p2.pid
							group by m2.mid, m2.name, p2.category 
							) subtable
                            where subtable.mid = m.mid
					);

– query 10
WITH my_table AS (
select m.name as company_name, cr.fullname as customer_name,
sum(s.price*s.quantity_available) as amnt_spent
from merchants m join sell s on m.mid = s.mid
join products p on s.pid = p.pid
join contain c on p.pid = c.pid
join orders o on c.oid = o.oid
join place p2 on o.oid = p2.oid
join customers cr on p2.cid = cr.cid
group by company_name, customer_name
order by company_name
)

select company_name, customer_name, amnt_spent 
from my_table 
where amnt_spent = (
					select min(amnt_spent)
                    from my_table as t1 
                    where t1.company_name = my_table.company_name
                    )
or amnt_spent = (
					select max(amnt_spent)
                    from my_table t2
                    where t2.company_name = my_table.company_name
                    );














                    


