use classicmodels;

-- 1. Devuelva la oficina con mayor número de empleados.

WITH 
officesWithEmpCount AS (SELECT o.*, count(e.employeeNumber) AS emp_count
FROM offices o
INNER JOIN employees e
WHERE e.officeCode = o.officeCode
GROUP BY o.officeCode)
SELECT *
FROM officesWithEmpCount o
WHERE o.emp_count >= ALL (SELECT emp_count
FROM officesWithEmpCount);

-- 2. ¿Cuál es el promedio de órdenes hechas por oficina?, 
-- ¿Qué oficina vendió la mayor cantidad de productos?
CREATE VIEW orders_per_office AS (
SELECT e.officeCode, count(DISTINCT o2.orderNumber) AS order_count
FROM employees e
INNER JOIN customers c ON
c.salesRepEmployeeNumber = e.employeeNumber
INNER JOIN orders o2 ON
c.customerNumber = o2.customerNumber
GROUP BY e.officeCode )

SELECT avg(order_count) FROM orders_per_office;

SELECT e.officeCode, e.order_count FROM orders_per_office e
ORDER BY e.order_count DESC
LIMIT 1;

-- 3. Devolver el valor promedio, 
-- máximo y mínimo de pagos que se hacen por mes.

SELECT max(amount), min(amount), avg(amount) FROM payments p
GROUP BY MONTH(p.paymentDate);

-- 4. Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.
delimiter //
CREATE PROCEDURE IF NOT EXISTS update_credit(IN updatedCustomerNumber int, IN newLimit int)
BEGIN 
    UPDATE customers
    SET creditLimit = newLimit
    WHERE customerNumber = updatedCustomerNumber;
END//
delimiter ;

-- 5. Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.

CREATE VIEW premium_customers AS (
    SELECT c.customerName, o.city, sum(p.amount) AS `Total gastado` FROM customers c 
    INNER JOIN payments p ON p.customerNumber = c.customerNumber
    INNER JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
    INNER JOIN offices o   ON o.officeCode = e.officeCode
    GROUP BY c.customerNumber
    ORDER BY `Total gastado` DESC
    LIMIT 10
)


-- 6. Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.

delimiter //
CREATE FUNCTION employee_of_the_month(yr int, mnth int)
RETURNS varchar(256)
DETERMINISTIC 
BEGIN
    DECLARE employee varchar(256);
    SELECT concat(e.firstName, " ", e.lastName) INTO employee
    FROM employees e
    INNER JOIN customers c ON
    c.salesRepEmployeeNumber = e.employeeNumber
    INNER JOIN orders o ON
    o.customerNumber = c.customerNumber 
    WHERE MONTH(o.orderDate) = mnth AND YEAR (o.orderDate) = yr
    GROUP BY e.employeeNumber
    ORDER BY count(DISTINCT o.orderNumber) DESC
    LIMIT 1;
    RETURN employee;
END//
delimiter ;


SELECT employee_of_the_month() FROM [()]

SELECT a, b, c, d
FROM (
    SELECT 1 AS a, 2 AS b, 3 AS c, 4 AS d
    UNION ALL 
    SELECT 5 , 6, 7, 8
) AS temp;

