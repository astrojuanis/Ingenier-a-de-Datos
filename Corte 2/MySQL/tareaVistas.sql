# Abril 08 - Proyecto Tienda2 Corregido
CREATE DATABASE IF NOT EXISTS tienda2_0;
USE tienda2_0;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS departamento;
SET FOREIGN_KEY_CHECKS = 1;

##Creación de tablas
CREATE TABLE departamento (
  idDepartamento INT PRIMARY KEY AUTO_INCREMENT,
  nombreDepartamento VARCHAR(120) NOT NULL
);

CREATE TABLE empleados (
  idEmpleados INT PRIMARY KEY AUTO_INCREMENT,
  nombreEmpleado VARCHAR(100) NOT NULL,
  deptoIdFK INT NULL,
  salarioEmpleado DECIMAL(10,2),
  FOREIGN KEY (deptoIdFK) REFERENCES departamento (idDepartamento)
);

CREATE TABLE productos (
  idProducto INT PRIMARY KEY AUTO_INCREMENT,
  nombre_producto VARCHAR(120) NOT NULL,
  precioProducto DECIMAL(10,2),
  categoriaProducto VARCHAR(60),
  stock INT DEFAULT 0 -- Unificado a 'stock' para compatibilidad
);

CREATE TABLE pedidos (
  idPedido INT PRIMARY KEY AUTO_INCREMENT,
  idEmpleado INT NOT NULL,
  fecha_pedido DATETIME DEFAULT NOW(),
  estado ENUM('pendiente', 'enviado', 'entregado', 'cancelado'),
  total DECIMAL(10,2) DEFAULT 0,
  CONSTRAINT FKPedidoEmpleado FOREIGN KEY (idEmpleado) REFERENCES empleados (idEmpleados)
);

CREATE TABLE detalle_pedido (
  idDetalle INT PRIMARY KEY AUTO_INCREMENT,
  idPedidoFK INT NOT NULL,
  idProductoFK INT NOT NULL,
  cantidad INT NOT NULL,
  precioUnitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precioUnitario) STORED,
  CONSTRAINT FKDetallePedido FOREIGN KEY (idPedidoFK) REFERENCES pedidos(idPedido) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT FKDetalleProducto FOREIGN KEY (idProductoFK) REFERENCES productos(idProducto)
);

##Inserción de Datos
INSERT INTO departamento(idDepartamento, nombreDepartamento)
VALUES (1220,'Administrativo'), (3330,'Ventas'), (10,'Gerencia');

INSERT INTO empleados(nombreEmpleado, deptoIdFK, salarioEmpleado)
VALUES ('Ana Garcia', 1220, 2300000), ('Julian Medina', 3330, 3200000), ('Ana Gara', 10, 250000), ('Carolina Jimenez', 1220, 4000000), ('Alejandro Palacios', 3330, 5000000);

INSERT INTO productos (nombre_producto, precioProducto, categoriaProducto, stock)
VALUES ('Laptop Pro', 1200000, 'Electrónica', 18), ('Mouse USB', 50000, 'Accesorios', 50), ('Monitor 32"', 500000, 'Electrónica', 10), ('Iphone 17Pro', 3800000, 'Electrónica', 50), ('Teclados', 100000, 'Accesorios', 50);

##Procedimiento Crear Pedido
DELIMITER //
CREATE PROCEDURE crearPedido (
    IN p_idEmpleado INT,
    IN p_idProducto INT,
    IN p_cantidadProducto INT,
    OUT p_idPedido INT,
    OUT p_mensaje VARCHAR(200)
)
BEGIN
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_precio DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error: Transacción no realizada';
        SET p_idPedido = -1;
    END;

    SELECT stock, precioProducto INTO v_stock, v_precio FROM productos WHERE idProducto = p_idProducto;

    IF v_stock IS NULL THEN
        SET p_mensaje = 'Error: Producto no existe';
    ELSEIF v_stock < p_cantidadProducto THEN
        SET p_mensaje = CONCAT('Stock insuficiente. Disponible: ', v_stock);
    ELSE
        START TRANSACTION;
        SET v_total = v_precio * p_cantidadProducto;
        INSERT INTO pedidos (idEmpleado, total, estado) VALUES (p_idEmpleado, v_total, 'pendiente');
        SET p_idPedido = LAST_INSERT_ID();
        INSERT INTO detalle_pedido (idPedidoFK, idProductoFK, cantidad, precioUnitario) VALUES (p_idPedido, p_idProducto, p_cantidadProducto, v_precio);
        UPDATE productos SET stock = stock - p_cantidadProducto WHERE idProducto = p_idProducto;
        COMMIT;
        SET p_mensaje = CONCAT('Pedido #', p_idPedido, ' creado correctamente');
    END IF;
END//
DELIMITER ;

##Procedimiento Cancelar Pedido
DELIMITER //
CREATE PROCEDURE cancelarPedido (
    IN p_idPedido INT,
    IN p_idEmpleado INT,
    OUT p_mensaje VARCHAR(200)
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_countProductos INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error: Transacción no realizada';
    END;

    SELECT estado INTO v_estado FROM pedidos WHERE idPedido = p_idPedido AND idEmpleado = p_idEmpleado;

    IF v_estado IS NULL THEN
        SET p_mensaje = 'No exitoso: el pedido no existe o no pertenece al empleado';
    ELSEIF v_estado IN ('cancelado', 'entregado') THEN
        SET p_mensaje = CONCAT('No exitoso: el pedido #', p_idPedido, ' ya está ', v_estado);
    ELSE
        START TRANSACTION;
        UPDATE productos pr
        INNER JOIN detalle_pedido dp ON dp.idProductoFK = pr.idProducto
        SET pr.stock = pr.stock + dp.cantidad
        WHERE dp.idPedidoFK = p_idPedido;

        SELECT COUNT(*) INTO v_countProductos FROM detalle_pedido WHERE idPedidoFK = p_idPedido;

        UPDATE pedidos SET estado = 'cancelado' WHERE idPedido = p_idPedido;
        COMMIT;
        SET p_mensaje = CONCAT('Exitoso: pedido #', p_idPedido, ' cancelado; stock restaurado para ', v_countProductos, ' productos');
    END IF;
END//
DELIMITER ;

##Creación de Vistas
CREATE OR REPLACE VIEW pedidosCreados AS 
SELECT 
    p.idPedido, 
    e.nombreEmpleado AS atendidoPor, 
    pr.nombre_producto AS Producto, 
    dp.cantidad AS cantidad_vendida, 
    p.total AS total_venta, 
    p.estado AS estadoActual 
FROM pedidos p 
INNER JOIN empleados e ON p.idEmpleado = e.idEmpleados 
INNER JOIN detalle_pedido dp ON p.idPedido = dp.idPedidoFK 
INNER JOIN productos pr ON dp.idProductoFK = pr.idProducto;

CREATE OR REPLACE VIEW pedidosCancelados AS 
SELECT 
    idPedido, 
    idEmpleado, 
    estado, 
    fecha_pedido, 
    CASE 
        WHEN estado IN ('pendiente' , 'enviado') THEN 'Permitido Cancelar' 
        ELSE 'No cancelable' 
    END AS Accion_permitida 
FROM pedidos;

CREATE OR REPLACE VIEW vista_Stock AS 
SELECT 
    idProducto, 
    nombre_producto, 
    stock AS StockActual, 
    categoriaProducto 
FROM productos;

##Pruebas de funcionamiento
CALL crearPedido(1, 3, 2, @pedido_id, @msg);
SELECT @msg;
SELECT * FROM pedidosCreados;
SELECT * FROM vista_Stock;