-- 1. Вывести сотрудников с зарплатой выше средней по компании

SELECT
	name,
    salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 2. Вывести продукты дороже среднего

SELECT
	name,
    price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 3. Вывести отделы, где есть хотя бы один сотрудник с зарплатой > 10 000

SELECT
	d.id,
	d.name
FROM departments as d
WHERE EXISTS (
  				SELECT 1
  				FROM employees as e
  				WHERE e.department_id = d.id AND e.salary > 70000
);

-- 4. Вывести продукты, которые чаще всего встречаются в заказах

SELECT
	pr.name,
	fr.frequency
FROM (
	SELECT
  		product_id,
  		COUNT(product_id) AS frequency,
  		RANK() OVER (ORDER BY COUNT(product_id) DESC)
  	FROM order_items
  	GROUP BY product_id
  ) AS fr
JOIN products AS pr ON fr.product_id = pr.id;

-- 5. Вывести для каждого клиента количество его заказов

SELECT
	customers.name,
	COUNT(orders.customer_id) OVER (PARTITION BY customers.id)
FROM orders
JOIN customers ON orders.customer_id = customers.id;

-- 6. Вывести топ 3 отдела по средней зарплате

SELECT
    DISTINCT(name),
    avg_salary
FROM (
    SELECT
        departments.name,
        AVG(employees.salary) OVER (PARTITION BY departments.id) AS avg_salary
    FROM departments
    JOIN employees ON departments.id = employees.department_id
)
ORDER BY avg_salary desc
LIMIT 3;

-- 7. Вывести клиентов без заказов

SELECT
	customers.name
FROM customers
WHERE NOT EXISTS (
	SELECT 1
  	FROM orders
	WHERE orders.customer_id = customers.id
);

-- 8. Вывести сотрудников, зарабатывающих больше, чем любой из менеджеров.

SELECT *
FROM employees
WHERE employees.salary > (SELECT
                          MAX(employees.salary)
                          FROM employees
                          WHERE manager_id IS NOT NULL
                         )

-- 9. Вывести отделы, где все сотрудники зарабатывают выше 5000.

SELECT
    departments.name
FROM
    departments
WHERE
    NOT EXISTS (
        SELECT 1
        FROM employees
        WHERE
            employees.department_id = departments.id
            AND (employees.salary <= 5000.00 OR employees.salary IS NULL)
    );