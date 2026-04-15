-- =====================================================
-- DDL: CREACION DE BASE DE DATOS Y TABLAS
-- =====================================================
DROP DATABASE IF EXISTS tienda_tech;
CREATE DATABASE tienda_tech CHARACTER SET utf8mb4;
USE tienda_tech;

CREATE TABLE clientes (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    ciudad          VARCHAR(60),
    fecha_registro  DATE 
);

CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria    VARCHAR(60),
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock        INT DEFAULT 0
);

CREATE TABLE pedidos (
    pedido_id    INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT NOT NULL,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL CHECK (cantidad > 0),
    fecha_pedido DATE,
    estado       VARCHAR(20) DEFAULT "pendiente"
        CHECK (estado IN ("pendiente","entregado","cancelado")),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- =====================================================
-- DML: DATOS DE PRUEBA
-- =====================================================
INSERT INTO clientes (nombreCliente, email, ciudad, fecha_registro)
 VALUES
 ("Ana Lopez","ana@mail.com","Bogota","2023-01-15"),
 ("Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"),
 ("Maria Torres","maria@mail.com","Cali","2023-05-10"),
 ("Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"),
 ("Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"),
 ("Luis Martinez","luis@mail.com","Bogota","2024-01-20"),
 ("Camila Vargas","camila@mail.com","Cali","2024-02-14"),
 ("Diego Morales","diego@mail.com","Medellin","2024-03-30");

INSERT INTO productos (nombreProducto, categoria, precio, stock)
VALUES
 ("Laptop Pro 15","Computadores",3500000.00,12),
 ("Mouse Inalambrico","Perifericos",85000.00,50),
 ("Teclado Mecanico","Perifericos",220000.00,30),
 ("Monitor 27","Pantallas",1200000.00,8),
 ("Auriculares BT","Audio",350000.00,25),
 ("Webcam HD","Perifericos",180000.00,20),
 ("Disco SSD 1TB","Almacenamiento",420000.00,40),
 ("Tablet 10","Moviles",1800000.00,6);
 

INSERT INTO pedidos (cliente_id, producto_id, cantidad, fecha_pedido, estado) VALUES
(1,1,1,"2024-01-10","entregado"),(1,2,2,"2024-01-15","entregado"),
 (2,3,1,"2024-02-05","entregado"),(2,5,1,"2024-02-20","cancelado"),
 (3,4,1,"2024-03-01","entregado"),(3,7,2,"2024-03-15","pendiente"),
 (4,2,3,"2024-04-02","entregado"),(4,6,1,"2024-04-10","pendiente"),
 (5,8,1,"2024-04-18","entregado"),(6,1,2,"2024-05-05","entregado"),
 (6,3,1,"2024-05-12","pendiente"),(7,5,2,"2024-05-20","entregado"),
 (1,7,1,"2024-06-01","entregado"),(8,4,1,"2024-06-10","cancelado"),
 (5,2,4,"2024-06-15","entregado"),(3,1,1,"2024-07-01","pendiente");
 
/* 
1. Cree la funcion fn_clasificar_producto(p_producto_id INT) que retorne: 
PREMIUM si el precio > 1,000,000; 
ESTANDAR si esta entre 200,000 y 1,000,000; 
BASICO si es menor a 200,000. */

create function fn_clasificar_producto (p_producto_id INT)
returns varchar (50)
begin 
case 
WHEN precio > 1000000  THEN 'Premium'
       if ELSE  precio > 200000 < 10000000000 then 'ESTANDAR' 
       ELSE  precio < 200000 then 'BASICO'
       return clasificacion;
end
DELIMITER ;


/*2. Luego cree la vista vista_catalogo_clasificado 
que muestre nombre, categoria, precio, clasificacion (usando la funcion) y stock para todos los productos. */
CREATE OR REPLACE VIEW vista_catalogo_clasificado AS 
SELECT 
    nombre
    categoria, 
    precio, 
    clasificarProducto,
    fecha_pedido, 
    stock
FROM pedidos;

/*3. Finalmente, consulte la vista mostrando solo los productos PREMIUM con stock > 5.*/
CREATE OR REPLACE VIEW vista_catalogo_premium as 
SELECT 
    nombre, 
    precio, 
    clasificarProducto,
    stock
    FROM productos
	Where clasificarProducto = 'PREMIUM'
    group by stock > 5;
