USE sakila;

/* 1a. Display the first and last names of all actors from the table actor*/
SELECT first_name, last_name FROM actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/
ALTER TABLE actor ADD COLUMN Actor_Name VARCHAR(75);
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET Actor_Name = CONCAT(
	UPPER(first_name), ' ', UPPER(last_name));
SET SQL_SAFE_UPDATES = 1;

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

/*2b. Find all actors whose last name contain the letters GEN:*/
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

/*Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order:*/
SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

/*Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT country_id, country FROM country WHERE country IN('Afghanistan', 'Bangladesh', 'China');

/*You want to keep a description of each actor. 
You don't think you will be performing queries on a description, so create a column in the table actor named 
description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR 
are significant).*/
ALTER TABLE actor ADD COLUMN description BLOB;

/*Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
ALTER TABLE actor DROP COLUMN description;

/*List the last names of actors, as well as how many actors have that last name.*/
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;

/*List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors*/
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name HAVING COUNT(*) > 1;

/*The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

/*Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE actor SET first_name = 'GROUCHO' where first_name = 'HARPO' and last_name = 'WILLIAMS';
SET SQL_SAFE_UPDATES = 1;

/*You cannot locate the schema of the address table. Which query would you use to re-create it?*/
SHOW CREATE TABLE address;

/*Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and addres*/
SELECT staff.first_name, staff.last_name, address.address FROM staff LEFT JOIN address ON staff.address_id = address.address_id;

/*Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.*/
SELECT SUM(payment.amount), staff.username FROM staff LEFT JOIN payment 
	ON staff.staff_id = payment.staff_id GROUP BY staff.staff_id;

/*List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/
SELECT film.title, COUNT(film_actor.film_id) FROM film LEFT JOIN film_actor
	ON film.film_id = film_actor.film_id GROUP BY film.film_id;
    
/*How many copies of the film Hunchback Impossible exist in the inventory system?*/
SELECT COUNT(film_id) FROM inventory WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

/*sing the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/
SELECT customer.first_name, customer.last_name, SUM(payment.amount) FROM customer LEFT JOIN payment
	ON customer.customer_id = payment.customer_id GROUP BY customer.customer_id ORDER BY customer.last_name;
    
/*The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id =
	(SELECT language_id FROM `language` WHERE NAME = 'English');

/*Use subqueries to display all actors who appear in the film Alone Trip.*/    
SELECT Actor_Name FROM actor WHERE actor_id IN 
	(SELECT actor_id FROM film_actor WHERE film_id =
		(SELECT film_id FROM film WHERE title = 'Alone Trip'));
        
/*You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
Canadian customers. Use joins to retrieve this information.*/
SELECT first_name, last_name, email FROM customer 
	JOIN address ON customer.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id WHERE country.country = 'Canada';

/*Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
SELECT title FROM film join film_category ON film.film_id = film_category.film_id 
	JOIN category ON film_category.category_id = category.category_id WHERE category.`name` = 'Family';

/*Display the most frequently rented movies in descending order.*/
SELECT  rental.inventory_id, COUNT(rental.inventory_id), film.title FROM rental 
	JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id GROUP BY rental.inventory_id
    ORDER BY COUNT(rental.inventory_id) DESC;
    
/*Write a query to display how much business, in dollars, each store brought in.*/
SELECT  store.store_id, sum(payment.amount) FROM payment join staff ON payment.staff_id = staff.staff_id
	JOIN store ON staff.store_id = store.store_id GROUP BY store.store_id;

/*Write a query to display for each store its store ID, city, and country.*/
SELECT store.store_id, city.city, country.country FROM store JOIN address ON store.address_id = address.address_id
	JOIN city ON address.city_id = city.city_id 
    JOIN country ON city.country_id = country.country_id;

/*List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/    
SELECT category.`name`, sum(payment.amount) FROM payment JOIN rental ON payment.rental_id = rental.rental_id
	JOIN inventory ON rental.inventory_id = inventory.inventory_id 
    JOIN film_category ON inventory.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    GROUP BY category.`name` ORDER BY SUM(payment.amount) DESC LIMIT 5;

/*In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/    
CREATE VIEW v AS
SELECT category.`name`, sum(payment.amount) FROM payment JOIN rental ON payment.rental_id = rental.rental_id
	JOIN inventory ON rental.inventory_id = inventory.inventory_id 
    JOIN film_category ON inventory.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    group by category.`name` ORDER BY SUM(payment.amount) DESC LIMIT 5;

/*How would you display the view that you created in 8a?*/
SELECT * FROM sakila.v;

/*You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW IF EXISTS v;

