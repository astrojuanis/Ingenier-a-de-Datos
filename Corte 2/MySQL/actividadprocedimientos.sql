
## RETO 1 
CREATE DATABASE IF NOT EXISTS tienda2;
USE tienda2;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS detalle_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS departamento;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE departamento (
	idDepartamento INT PRIMARY KEY AUTO_INCREMENT,
	nombreDepartamento VARCHAR(120) NOT NULL
);

CREATE TABLE empleados (
	idEmpleados INT PRIMARY KEY AUTO_INCREMENT,
	nombreEmpleado VARCHAR(100) NOT NULL,
	deptoIdFK INT NULL,
	salarioEmpleado DECIMAL(10,2) NOT NULL DEFAULT 0,
	CONSTRAINT FKEmpleadoDepto
		FOREIGN KEY (deptoIdFK)
		REFERENCES departamento(idDepartamento)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

CREATE TABLE productos (
	idProducto INT PRIMARY KEY AUTO_INCREMENT,
	nombre_producto VARCHAR(120) NOT NULL,
	precioProducto DECIMAL(10,2) NOT NULL DEFAULT 0,
	categoriaProducto VARCHAR(60),
	stock INT NOT NULL DEFAULT 0
);

CREATE TABLE pedidos (
	idPedido INT PRIMARY KEY AUTO_INCREMENT,
	idEmpleado INT NOT NULL,
	fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	estado ENUM('pendiente','enviado','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
	total DECIMAL(10,2) NOT NULL DEFAULT 0,
	CONSTRAINT FKPedidoEmpleado
		FOREIGN KEY (idEmpleado)
		REFERENCES empleados(idEmpleados)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
);

CREATE TABLE detalle_pedido (
	idDetalle INT PRIMARY KEY AUTO_INCREMENT,
	idPedidoFK INT NOT NULL,
	idProductoFK INT NOT NULL,
	cantidad INT NOT NULL,
	precioUnitario DECIMAL(10,2) NOT NULL,
	subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precioUnitario) STORED,

	CONSTRAINT FKDetallePedido
		FOREIGN KEY (idPedidoFK)
		REFERENCES pedidos(idPedido)
		ON UPDATE CASCADE
		ON DELETE CASCADE,

	CONSTRAINT FKDetalleProducto
		FOREIGN KEY (idProductoFK)
		REFERENCES productos(idProducto)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
);


##RETO 2 (INSERTS)

INSERT INTO departamento (nombreDepartamento) VALUES
('Administrativo'),
('Ventas'),
('Gerencia');

INSERT INTO empleados (nombreEmpleado, deptoIdFK, salarioEmpleado) VALUES
('Ana Garcia', 1, 2300000),
('Julian Medina', 2, 3200000),
('Ana Gara', 3, 250000),
('Carolina Jimenez', 1, 4000000),
('Alejandro Palacios', 2, 5000000);

INSERT INTO productos (nombre_producto, precioProducto, categoriaProducto, stock) VALUES
('Laptop Pro',    1200000, 'Electrónica',  5),
('Mouse USB',       50000, 'Accesorios',  20),
('Monitor 32"',    500000, 'Electrónica',  7),
('Iphone 17Pro',  3800000, 'Electrónica',  3),
('Teclados',       100000, 'Accesorios',  10);

INSERT INTO pedidos (idEmpleado, estado) VALUES
(1, 'pendiente'),
(2, 'enviado');

INSERT INTO detalle_pedido (idPedidoFK, idProductoFK, cantidad, precioUnitario) VALUES
(1, 1, 1, 1200000),
(1, 2, 2,   50000),
(2, 4, 1, 3800000),
(2, 5, 1,  100000);

-- Actualizar total del pedido (opcional pero recomendado)
UPDATE pedidos p
SET total = (
	SELECT COALESCE(SUM(dp.subtotal),0)
	FROM detalle_pedido dp
	WHERE dp.idPedidoFK = p.idPedido
);


##SUBCONSULTAS Y JOINS 

-- empleados con salario > promedio
SELECT nombreEmpleado, salarioEmpleado
FROM empleados
WHERE salarioEmpleado > (
	SELECT AVG(salarioEmpleado) FROM empleados
);

-- empleados cuyo depto está en Gerencia o Ventas
SELECT nombreEmpleado, salarioEmpleado
FROM empleados
WHERE deptoIdFK IN (
	SELECT idDepartamento
	FROM departamento
	WHERE nombreDepartamento IN ('Gerencia','Ventas')
);

-- tabla derivada: promedios por depto y filtro
SELECT deptoIdFK, prom_salario
FROM (
	SELECT deptoIdFK, AVG(salarioEmpleado) AS prom_salario
	FROM empleados
	GROUP BY deptoIdFK
) AS promedios
WHERE prom_salario > 450000;

-- desviación respecto al promedio general
SELECT
	nombreEmpleado,
	salarioEmpleado AS salario,
	(SELECT AVG(salarioEmpleado) FROM empleados) AS promedioGeneral,
	salarioEmpleado - (SELECT AVG(salarioEmpleado) FROM empleados) AS desviacion
FROM empleados;

-- productos con precio > promedio, ordenados
SELECT nombre_producto, categoriaProducto, precioProducto
FROM productos
WHERE precioProducto > (SELECT AVG(precioProducto) FROM productos)
ORDER BY precioProducto DESC;

-- pedido con nombre del empleado
SELECT
	p.idPedido,
	e.nombreEmpleado
FROM pedidos p
INNER JOIN empleados e ON p.idEmpleado = e.idEmpleados;

-- detalle de pedidos con varios joins
SELECT
	e.nombreEmpleado,
	p.idPedido,
	p.fecha_pedido,
	p.estado,
	pr.nombre_producto,
	dp.cantidad,
	dp.precioUnitario,
	dp.subtotal
FROM detalle_pedido dp
INNER JOIN pedidos p   ON dp.idPedidoFK = p.idPedido
INNER JOIN empleados e ON p.idEmpleado = e.idEmpleados
INNER JOIN productos pr ON dp.idProductoFK = pr.idProducto;


##PROCEDIMIENTO ALMACENADO 

DELIMITER //

CREATE PROCEDURE crearPedido (
	IN  p_idEmpleado INT,
	IN  p_idProducto INT,
	IN  p_cantidadProducto INT,
	OUT p_idPedido INT,
	OUT p_mensaje VARCHAR(200)
)
BEGIN
	DECLARE v_stock INT DEFAULT 0;
	DECLARE v_precio DECIMAL(10,2) DEFAULT 0;
	DECLARE v_total DECIMAL(10,2) DEFAULT 0;

	-- Handler de error
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET p_mensaje = 'Error: Transacción no realizada';
		SET p_idPedido = -1;
	END;

	-- Traer stock y precio del producto
	SELECT stock, precioProducto
	INTO v_stock, v_precio
	FROM productos
	WHERE idProducto = p_idProducto;

	IF v_stock IS NULL THEN
		SET p_mensaje = 'Error: Producto no existe';
		SET p_idPedido = -1;

	ELSEIF v_stock < p_cantidadProducto THEN
		SET p_mensaje = CONCAT('Stock insuficiente. Disponible: ', v_stock);
		SET p_idPedido = 0;

	ELSE
		START TRANSACTION;

		SET v_total = v_precio * p_cantidadProducto;

		-- Crear pedido
		INSERT INTO pedidos (idEmpleado, total, estado)
		VALUES (p_idEmpleado, v_total, 'pendiente');

		SET p_idPedido = LAST_INSERT_ID();

		-- Insertar detalle
		INSERT INTO detalle_pedido (idPedidoFK, idProductoFK, cantidad, precioUnitario)
		VALUES (p_idPedido, p_idProducto, p_cantidadProducto, v_precio);

		-- Descontar stock
		UPDATE productos
		SET stock = stock - p_cantidadProducto
		WHERE idProducto = p_idProducto;

		COMMIT;

		SET p_mensaje = CONCAT('Pedido #', p_idPedido, ' creado correctamente');
	END IF;
END//

DELIMITER ;

-- Llamar procedimiento
CALL crearPedido(1, 3, 2, @pedido_id, @msg);
SELECT @pedido_id AS pedido_id, @msg AS mensaje;
select * from pedidos;
select * from detalle_pedido;

##Crear un procedimiento almacenado que permita cancelar un pedido, el procedimiento debe recibir como parametro de entrada el id del pedido y el id del empleado para validar el pedido si pertenece a ese empleado 
##Debe validar que el pedido exista y pertenezca al empleado indicado, si no pertenece debe mostrar mensaje de error 
#Debe validar que el pedido no este cancelado ni entregado solo se va a poder cancelar pedidos que esten en estado pendientes o enviados
#Actualizar el estado del pedido a cancelado 
#Actualizar o restaurar el stock de cada producto de ese pedido (detalle_pedido)
#Retornar como parametro de salida un mensaje que diga 'pedido # x: cancelado' stock restaurado para n productos 
#1. Exitosa pedido # x: cancelado' stock restaurado para n productos 
# 2. No exitoso el pedido no existe o no pertenece al cliente 
 

DELIMITER //

CREATE PROCEDURE cancelarPedido (
	IN  p_idPedido INT,
	IN  p_idEmpleado INT,
	OUT p_mensaje VARCHAR(200)
)
BEGIN
	DECLARE v_estado varchar (20);
    declare v_stockProducto int default 0;
    DECLARE v_countProductos INT DEFAULT 0;

	-- error
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET p_mensaje = 'Error: Transacción no realizada';
	END;

	-- Validar que el pedido exista y pertenezca al empleado 
	SELECT estado
	INTO v_estado
	FROM pedidos
	WHERE idPedido = p_idPedido
    and  idEmpleado = p_idEmpleado;

	IF v_estado IS NULL THEN
		SET p_mensaje = 'No exitoso: el pedido no existe';

-- Validar estados permitidos 
	ELSEIF v_estado IN ('cancelado', 'entregado') THEN
			SET p_mensaje = CONCAT('No exitoso: el pedido #', p_idPedido,
				' no se puede cancelar (estado: ', v_estado, ')');
		
		ELSEIF v_estado NOT IN ('pendiente', 'enviado') THEN
			SET p_mensaje = CONCAT('No exitoso: el pedido #', p_idPedido,
				' solo se puede cancelar si está pendiente o enviado (estado: ', v_estado, ')');
	

	ELSE
		START TRANSACTION;
 -- Restaurar el stock de cada producto 
 
		UPDATE productos pr
		INNER JOIN detalle_pedido dp
			ON dp.idProductoFK = pr.idProducto
		SET pr.stock = pr.stock + dp.cantidad
		WHERE dp.idPedidoFK = p_idPedido;

-- Contar cuantos productos fueron restaurado su stock 

	SELECT COUNT(*)
		INTO v_countProductos
		FROM detalle_pedido
		WHERE idPedidoFK = p_idPedido;

-- Actualizar el estado del pedido 
	UPDATE pedidos
		SET estado = 'cancelado'
		WHERE idPedido = p_idPedido
		  AND idEmpleado = p_idEmpleado;

		COMMIT;
-- Mesaje de salida 
		SET p_mensaje = CONCAT('Exitoso: pedido #', p_idPedido,
			' cancelado; stock restaurado para ', v_countProductos, ' productos');
	END IF;
END//

DELIMITER ;
use tienda2;
-- Llamar el proceso
CALL cancelarPedido(10, 3, @msg);
SELECT @msg;