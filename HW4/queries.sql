
-- *************************************************************
-- Creating the schema
-- *************************************************************

create database hw4;
use hw4;


-- *************************************************************
-- Creating the tables
-- *************************************************************


-- Creating the category table
create table category (
	category_id integer(4) not null,
    name varchar(20),
    constraint category_constraint check(name in ('Animation', 'Comedy', 'Family', 
    'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 
    'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music')),
    primary key(category_id)
);




-- Creating the language table
create table language(
	language_id integer(2) not null,
    name varchar(10),
    primary key(language_id)
);




-- Creating the film table
create table film(
	film_id integer(4) not null,
    title varchar(100),
    description varchar(10000),
    release_year integer(4),
    language_id integer(2),
    rental_duration integer(2),
    rental_rate decimal(4,2),
    length integer(3),
    replacement_cost decimal(5,2),
    rating varchar(5),
    special_features varchar(20),   
    
    constraint release_year_constraint check(release_year between 1900 and 2023),
    constraint special_features_constraint check(special_features in('Behind the Scenes',
    'Commentaries', 'Deleted Scenes', 'Trailers')),
    constraint rental_duration_constraint check(rental_duration>0  and 
    (rental_duration between 2 and 8)),
    constraint rental_rate_constraint check(rental_rate between 0.99 and 6.99),
    constraint length_constraint check(length between 30 and 200),
    constraint rating_constraint check(rating in ('PG', 'G', 'NC-17', 'PG-13', 'R')),
    constraint replacement_cost_constraint check(replacement_cost between 5.00 and 100.00),
    
    
    primary key(film_id),
    foreign key(language_id) references language(language_id)
);







-- Creating the film_category table
create table film_category(
	film_id integer(4) not null,
    category_id integer(4) not null,
	foreign key(film_id) references film(film_id),
    foreign key(category_id) references category(category_id),
    primary key(film_id, category_id)
);





-- Creating the actor table
create table actor(
	actor_id integer(3) not null,
    first_name varchar(20),
    last_name varchar(20),
    primary key(actor_id)
);





-- Creating the country table
create table country(
	country_id integer(3) not null,
    country varchar(40),
    primary key(country_id)
);




-- Creating the film_actor table
create table film_actor(
	actor_id integer(3) not null,
	film_id integer(4) not null,
	foreign key(actor_id) references actor(actor_id),
    foreign key(film_id) references film(film_id),
    primary key(actor_id, film_id)
);



-- Creating the city table
create table city(
	city_id integer(3) not null,
    city varchar(60),
    country_id integer(3),
    primary key(city_id),
    foreign key(country_id) references country(country_id)
);




-- Creating the address table
create table address(
	address_id integer(3) not null,
    address varchar(10000),
    address2 varchar(1000),
	district varchar(40),
    city_id integer(3),
    postal_code varchar(10),
    phone varchar(12),
	primary key(address_id),
    foreign key(city_id) references city(city_id)
);


-- Creating the store table
create table store(
	store_id integer(3) not null,
    address_id integer(3),
    primary key(store_id),
    foreign key(address_id) references address(address_id)
);


-- Creating the staff table
create table staff(
	staff_id integer(3) not null,
    first_name varchar(20),
    last_name varchar(20),
    address_id integer(3),
    email varchar(40),
    store_id integer(3),
    active char(1),
    username varchar(20),
    password varchar(40),
    
    constraint active_constraint check(active in('0', '1')),
    primary key(staff_id),
	foreign key(address_id) references address(address_id),
    foreign key(store_id) references store(store_id)
);



-- Creating the customer table
create table customer(
	customer_id integer(3) not null,
    store_id integer(3),
    first_name varchar(20),
    last_name varchar(20),
    email varchar(40),
    address_id integer(3),
    active char(1),
    
    constraint active_costrant check(active in('0', '1')),
    primary key(customer_id),
    foreign key(store_id) references store(store_id),
    foreign key(address_id) references address(address_id)
);


-- Creating the inventory table
create table inventory(
	inventory_id integer(5) not null,
    film_id integer(4),
    store_id integer(3),
    primary key(inventory_id),
    foreign key(film_id) references film(film_id),
    foreign key(store_id) references store(store_id)
);



-- Creating the rental table
create table rental(
	rental_id integer(6) not null,
    rental_date datetime, 
    inventory_id integer(5),
    customer_id integer(3),
    return_date datetime,
    staff_id integer(3),
    
    primary key(rental_id),
    unique(rental_date, inventory_id, customer_id),
    foreign key(inventory_id) references inventory(inventory_id),
    foreign key(customer_id) references customer(customer_id),
    foreign key(staff_id) references staff(staff_id),
    constraint rental_date_constraint check (date(rental_date) between '1900-01-01' and '2024-12-31'),
    constraint return_date_constraint check (date(return_date) between date(rental_date) and '2024-12-31')
);


-- Creating the payment table
create table payment(
	payment_id integer(6) not null,
    customer_id integer(3),
    staff_id integer(3),
    rental_id integer(6),
    amount decimal(5,2),
    payment_date datetime,
    
    constraint amount_constraint check(amount >= 0),
    constraint payment_date_constraint check(date(payment_date) between '1900-01-01' and '2024-12-31'),
    primary key(payment_id),
    foreign key(customer_id) references customer(customer_id),
    foreign key(staff_id) references staff(staff_id),
    foreign key(rental_id) references rental(rental_id)
);




-- *************************************************************
-- The six queries
-- *************************************************************

-- Query1 
select category.name as category_name, avg(film.length) as average_length_of_films
from category join film_category using(category_id) join film using(film_id)
group by category.name
order by category.name;


-- Query2
with CategoryAverageFilmLength as
(
select category.name as category_name, avg(film.length) as average_film_length
from category join film_category using(category_id) join film using(film_id)
group by category.name
)
select category_name, average_film_length
from CategoryAverageFilmLength
where average_film_length = (select max(average_film_length) from CategoryAverageFilmLength)
UNION
select category_name, average_film_length
from CategoryAverageFilmLength
where average_film_length = (select min(average_film_length) from CategoryAverageFilmLength);




-- Query3
select customer.customer_id, customer.first_name, customer.last_name
from customer
where customer.customer_id in
	(select customer.customer_id
     from customer join rental using(customer_id)
	 join inventory using(inventory_id)
	 join film using(film_id)
	 join film_category using(film_id)
	 join category using(category_id)
     where category.name = 'Action')
and customer.customer_id not in
	 (select customer.customer_id
     from customer join rental using(customer_id)
	 join inventory using(inventory_id)
	 join film using(film_id)
	 join film_category using(film_id)
	 join category using(category_id)
     where category.name = 'Comedy' or category.name = 'Classics');





-- Query4
select actor.actor_id, actor.first_name, actor.last_name, count(*)
from actor join film_actor using(actor_id)
join film using(film_id)
join language using(language_id)
where language.name = 'English'
group by actor.actor_id, actor.first_name, actor.last_name
having count(*) >=  all(select count(*)
						from actor join film_actor using(actor_id)
						join film using(film_id)
						join language using(language_id)
						where language.name = 'English'
						group by actor.actor_id, actor.first_name, actor.last_name);
					



-- Query 5
select count(distinct(inventory.film_id)) as num_distinct_movies 
from rental 
join staff using(staff_id)
join store using(store_id)
join inventory using(inventory_id)
join film using(film_id)
where staff.first_name='Mike' and datediff(date(rental.return_date), date(rental.rental_date)) = 10;



-- Query 6
select a.actor_id, a.first_name, a.last_name
from actor a join film_actor fa using(actor_id)
where fa.film_id = (select distinct(film_id)
							from film_actor 
							group by film_id
							order by count(distinct(actor_id)) desc
							limit 1)
order by a.first_name, a.last_name;
                        

