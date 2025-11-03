--1. Вывести employee.id, employee.name, department.name — сотрудники без отдела должны показать No Department.

SELECT employees.id, employees.name, COALESCE(departments.name, 'No Department')
FROM employees
LEFT JOIN departments ON employees.department_id = departments.id;

--2. Сотрудники, у которых есть менеджер (показать имя сотрудника и имя менеджера).

SELECT e1.name, e2.name
FROM employees AS e1
JOIN employees AS e2 ON e1.manager_id = e2.id
WHERE e1.manager_id IS NOT NULL;

--3. Отделы без сотрудников.

SELECT departments.name, COUNT(employees.id) FROM employees
FULL JOIN departments on employees.department_id = departments.id
GROUP BY departments.name
HAVING COUNT(employees.id) = 0;

--4. Все заказы с именем сотрудника и именем клиента — если employee или customer отсутствует, показывать No Employee / No Customer.

SELECT COALESCE(emp.name, 'No Employee'), COALESCE(cus.name, 'No Customer'), o.amount FROM orders AS o
FULL JOIN employees AS emp ON o.employee_id = emp.id
FULL JOIN customers AS cus ON o.customer_id = cus.id
WHERE o.id IS NOT NULL;

--5. Список заказов с товарами: для каждого заказа вывести order_id, product_name, quantity. Показать также заказы без позиций.

SELECT o.id, pr.name, oi.quantity FROM order_items AS oi
FULL JOIN orders AS o ON oi.order_id = o.id
FULL JOIN products AS pr ON oi.product_id = pr.id
WHERE o.id IS NOT NULL;

--6. Для каждого отдела — все заказы (через сотрудников этого отдела); включать отделы с нулём заказов.

SELECT departments.name, COALESCE(orders.id, 0) FROM employees
JOIN departments ON employees.department_id = departments.id
FULL JOIN orders ON employees.id = orders.employee_id
WHERE departments.name IS NOT NULL
ORDER BY departments.name, orders.id;

--7. Найти пары клиентов и продуктов, которые этот клиент никогда не покупал (т.е. построить Cartesian клиент×продукт и исключить реальные покупки).

SELECT customers.name, products.name FROM customers
CROSS JOIN products
LEFT JOIN (
  SELECT cs.id as cs_id, pr.id as pr_id
  FROM order_items AS oi
  JOIN orders AS o ON oi.order_id = o.id
  JOIN products AS pr ON oi.product_id = pr.id
  JOIN customers AS cs ON o.customer_id = cs.id
) AS rs on customers.id = rs.cs_id AND products.id = rs.pr_id
WHERE rs.cs_id IS NULL;

--8. Показать, какие продукты никогда не продавались.

SELECT products.name FROM products
FULL JOIN order_items ON products.id = order_items.product_id
WHERE order_items.product_id IS NULL;

--9. Для каждого менеджера — показать суммарную сумму заказов, оформленных его подчинёнными.

SELECT mn.name, SUM(ord.amount) FROM employees as em
JOIN employees AS mn ON em.id = mn.manager_id
JOIN orders as ord ON ord.employee_id = em.id
GROUP BY mn.name;

--10. Общее количество заказов и суммарная выручка (amount).

SELECT COUNT(id), SUM(amount) FROM orders;

--11. Средняя и максимальная зарплата по отделам.

SELECT departments.name, ROUND(AVG(employees.salary), 2), MAX(employees.salary) FROM departments
LEFT JOIN employees ON departments.id = employees.department_id
GROUP BY departments.name;

--12. Для каждого заказа — общее количество товаров (sum quantity) и уникальных позиций (count distinct product_id).

SELECT orders.id, COALESCE(SUM(order_items.quantity), 0), COUNT(DISTINCT order_items.product_id) FROM orders
LEFT JOIN order_items ON orders.id = order_items.order_id
GROUP BY orders.id;

--13. Топ-3 продукта по суммарной выручке (price*quantity).

SELECT products.name, SUM(order_items.quantity * products.price) as sm FROM products
JOIN order_items ON products.id = order_items.product_id
GROUP BY products.name
ORDER BY sm DESC
LIMIT 3;

--14. Количество клиентов, у которых есть хотя бы один заказ.

SELECT COUNT(DISTINCT customer_id) FROM orders
WHERE customer_id IS NOT NULL;

--15. Для каждого отдела — количество сотрудников, средняя зарплата, суммарная сумма заказов (через сотрудников этого отдела).

SELECT
    departments.name,
    COUNT(employees.id) emp_count,
    COALESCE(ROUND(AVG(employees.salary), 2), 0) as average_salary,
    COALESCE(rs.total, 0) as total_sum_orders
FROM departments
LEFT JOIN employees ON departments.id = employees.department_id
LEFT JOIN (
  SELECT
  	employees.department_id,
  	SUM(orders.amount) as total
  FROM employees
  JOIN orders ON employees.id = orders.employee_id
  GROUP BY employees.department_id
) AS rs ON departments.id = rs.department_id
GROUP BY departments.id, departments.name, total_sum_orders

--16. Найти клиентов, чья средняя сумма заказа выше средней по всем заказам.

SELECT customers.name, ROUND(AVG(orders.amount), 2) FROM customers
JOIN orders ON customers.id = orders.customer_id
GROUP BY customers.name
HAVING AVG(orders.amount) > (SELECT AVG(orders.amount) FROM orders);

--17. Сформировать полное имя сотрудника

SELECT name FROM employees;

--18. Вывести дату заказа в формате DD.MM.YYYY HH24:MI.

SELECT ID, TO_CHAR(order_date, 'DD.MM.YYYY HH24:MI') AS order_date FROM orders;

--19. Найти заказы старше N дней (параметр) 

SELECT * FROM orders
WHERE order_date < (CURRENT_DATE - INTERVAL '750 days');

--20. Для таблицы employees: заменить NULL в salary на 0 в вычислениях и вывести salary + bonus (bonus = 10% для определённой позиции).

SELECT
  name,
  position,
  COALESCE(salary, 0) AS salary,
  CASE
    WHEN position = 'CEO' THEN COALESCE(salary, 0) * 1.10
    ELSE COALESCE(salary, 0)
  END AS salary_with_bonus
FROM employees;