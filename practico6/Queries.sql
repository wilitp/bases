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

DROP FUNCTION IF EXISTS employee_of_the_month;
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
    WHERE MONTH(o.orderDate) = mnth AND YEAR(o.orderDate) = yr
    GROUP BY e.employeeNumber
    ORDER BY count(DISTINCT o.orderNumber) DESC
    LIMIT 1;
    RETURN employee;
END//
delimiter ;

-- 7. Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.

DROP TABLE product_refillment ;
CREATE TABLE IF NOT EXISTS product_refillment (
    productCode varchar(15),
    refillmentID int AUTO_INCREMENT,
    orderDate date,
    quantity int,
    PRIMARY KEY (refillmentID)
);
ALTER TABLE product_refillment ADD FOREIGN KEY (productCode) REFERENCES products(productCode);

-- 8. Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.


delimiter //
CREATE TRIGGER IF NOT EXISTS restock_product AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN 
    DECLARE stock int;
    
    SELECT (quantityInStock - NEW.quantityOrdered) INTO stock
    FROM products
    WHERE productCode = NEW.productCode;
    
    IF (stock < 10)
    THEN
        INSERT INTO product_refillment (productCode, quantity, orderDate)
        VALUES (NEW.productCode, 10, curdate());
    END IF;

END//
delimiter ;

-- 9. Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas.

CREATE ROLE Empleado;
GRANT SELECT ON classicmodels.* TO Empleado;
GRANT CREATE VIEW ON classicmodels.* TO Empleado;

-- 1. consulta mas dificil 
-- Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia en días entre las fechas de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.

SELECT c.customerName, c.contactFirstName, max(abs(DATEDIFF(p.paymentDate, p2.paymentDate))), min(ABS(DATEDIFF(p.paymentDate, p2.paymentDate)))
FROM customers c
INNER JOIN payments p ON
c.customerNumber = p.customerNumber
INNER JOIN payments p2 ON
c.customerNumber = p.customerNumber
WHERE c.city LIKE "N%" AND p.checkNumber <> p2.checkNumber
GROUP BY c.customerNumber;

-- 2. consulta mas dificil
-- Encontrar el nombre y la cantidad vendida total de los 10 productos más vendidos que, a su vez, representen al menos el 4% del total de productos, contando unidad por unidad, de todas las órdenes donde intervienen. No utilizar LIMIT.

-- No me salio lo de no usar limit :(

SELECT p.productName, sum(o.quantityOrdered) totalProduct,
(SELECT sum(quantityOrdered)
FROM orderdetails o
JOIN 
(SELECT *
FROM orders o2
WHERE EXISTS (SELECT *
FROM orderdetails o
WHERE o.productCode = p.productCode
AND o2.orderNumber = o.orderNumber)) selected_orders ON
o.orderNumber = selected_orders.orderNumber) totalSales
FROM orderdetails o
JOIN products p
ON
o.productCode = p.productCode
GROUP BY p.productCode
HAVING totalProduct >= 0.04 * totalSales
ORDER BY totalProduct DESC
LIMIT 10


