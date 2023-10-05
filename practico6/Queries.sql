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




