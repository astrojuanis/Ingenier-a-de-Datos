CREATE DATABASE IF NOT EXISTS tiendaOnline;
USE tiendaOnline;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS cliente_backup;
DROP TABLE IF EXISTS cliente_cbackup;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE clientes (
  idClientes        INT          PRIMARY KEY AUTO_INCREMENT,
  nombreCliente     VARCHAR(100) NOT NULL,
  emailCliente      VARCHAR(100) UNIQUE,
  ciudad            VARCHAR(100) NULL,
  creado_en         DATETIME     DEFAULT NOW()
);

CREATE TABLE productos (
  idProducto        INT          PRIMARY KEY AUTO_INCREMENT,
  nombre_producto   VARCHAR(120) NOT NULL,
  precioProducto    DECIMAL(10,2),
  stockProducto     INT          DEFAULT 0,
  categoriaProducto VARCHAR(60)
);

CREATE TABLE pedido (
  idPedido          INT  PRIMARY KEY AUTO_INCREMENT,
  cantidadProducto  INT  NOT NULL,
  fechaPedido       DATE,
  idClienteFK       INT,
  idProductoFK      INT,
  FOREIGN KEY (idClienteFK)  REFERENCES clientes(idClientes),
  FOREIGN KEY (idProductoFK) REFERENCES productos(idProducto)
);

CREATE TABLE cliente_cbackup (
  idClienteBack INT          PRIMARY KEY AUTO_INCREMENT,
  nombreCliente VARCHAR(100),
  emailCliente  VARCHAR(150),
  copiado_en    DATETIME     DEFAULT NOW()
);

SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM pedido;


DESCRIBE clientes;
INSERT INTO clientes(nombreCliente, emailCliente, ciudad) 
VALUES ('Ana Garcia', 'ana@mail.com', 'Madrid');
INSERT INTO clientes(nombreCliente, emailCliente, ciudad) 
VALUES ('Pedro Perez', 'pedro@mail.com', 'Barcelona');
SELECT * FROM clientes;

DESCRIBE productos;
INSERT INTO productos (nombre_producto, precioProducto, stockProducto, categoriaProducto)
VALUES 
  ('Laptop Pro',   1200000, 15, 'Electrónica'),
  ('Mouse USB',      50000, 80, 'Accesorios'),
  ('Monitor 32"',  500000,  20, 'Electrónica'),
  ('Teclados',     100000,  35, 'Accesorios');
SELECT * FROM productos;

RENAME TABLE cliente_cbackup TO cliente_backup;

INSERT INTO cliente_backup (nombreCliente, emailCliente)
SELECT nombreCliente, emailCliente
FROM clientes
WHERE creado_en < '2026-03-20';

SELECT * FROM cliente_backup;
DESCRIBE cliente_backup;

SELECT * FROM clientes;
UPDATE clientes
SET ciudad = 'Valencia'
WHERE idClientes = 1;

SELECT * FROM productos;
UPDATE productos
SET precioProducto = 1099000,
    stockProducto  = 10
WHERE idProducto = 1;

UPDATE productos
SET precioProducto = precioProducto * 1.10
WHERE categoriaProducto = 'Accesorios';

SELECT * FROM clientes;
DELETE FROM clientes WHERE idClientes = 2;  -- ✅ idClientes con S

SELECT * FROM productos;
DELETE FROM productos
WHERE stockProducto = 0 AND categoriaProducto = 'Descatalogado';

-- EJERCICIOS

-- 1. Insertar 3 clientes
INSERT INTO clientes (nombreCliente, emailCliente, ciudad)
VALUES
  ('Luisa Lopez',      'luisa@mail.com',    'Bogota'),
  ('Daniel Mejia',     'daniel@mail.com',   'Medellin'),
  ('Cristina Cardona', 'cristina@mail.com', 'Cali');
SELECT * FROM clientes;

-- 2. Insertar 2 productos
INSERT INTO productos (nombre_producto, precioProducto, stockProducto, categoriaProducto)
VALUES
  ('Audifonos Bluetooth', 180000, 25, 'Accesorios'),
  ('Tablet 10"',          750000,  8, 'Electronica');
SELECT * FROM productos;

-- 3. Insertar 1 pedido
INSERT INTO pedido (cantidadProducto, fechaPedido, idClienteFK, idProductoFK)
VALUES (2, '2026-03-19', 3, 5);
SELECT * FROM pedido;

-- 4. Cambiar ciudad
UPDATE clientes
SET ciudad = 'Barranquilla'
WHERE idClientes = 3;
SELECT * FROM clientes;

-- 5. Aumentar stock
UPDATE productos
SET stockProducto = stockProducto + 5
WHERE idProducto = 5;
SELECT * FROM productos;

-- 6. Aplicar descuento 10%
UPDATE productos
SET precioProducto = precioProducto * 0.90
WHERE idProducto = 6;
SELECT * FROM productos;

-- 7. Eliminar pedido
DELETE FROM pedido WHERE idPedido = 1;
SELECT * FROM pedido;

-- 8. Eliminar cliente
DELETE FROM clientes WHERE idClientes = 3;
SELECT * FROM clientes;

-- 9. Eliminar productos con stock menor a 3
DELETE FROM productos WHERE stockProducto < 3;
SELECT * FROM productos;

SET SQL_SAFE_UPDATES = 1;

##Diccionario de datos 
use tiendaOnline;
describe productos;

##Cambiar campo
alter table productos 
change stockProducto stoProdT int;

#Consulta Nombre del producto y stock 
select nombre_Producto, stoProdT from productos;

#Alias
select nombre_Producto as nombreProducto , stoProdT as Stock from productos;

#Consulta con Where 
select nombre_Producto, stoProdT from productos where nombre_Producto ='Laptop Pro';

##Ordenar Tabla ascendente 
select nombre_Producto as nombreProducto , stoProdT as Stock
from productos order by idProducto ASC;

##Ordenar Tabla descendente 
select nombre_Producto as nombreProducto , stoProdT as Stock
from productos order by stoProdT DESC;

## Or
select nombre_Producto as nombreProducto , stoProdT as Stock from productos where stoProdT >= 25 or idProducto = 1;

## Between 
## select * from nombre_tabla between val01 and val02 

select nombre_Producto as nombreProducto , stoProdT as Stock
from productos where precioProducto between 50000 and 10000 and stoProdT>3 order by precioProducto desc;

##Like inicien
select * from productos where nombre_Producto like 'm%';
#Like que contengan
select * from productos where nombre_Producto like '%o%' order by precioProducto asc limit 5;
#Like que terminen
select * from productos where nombre_Producto like '%o';

##no contengan
select * from productos where nombre_Producto not like '%o';

##Tarea

## Consultas tipo STRING/VARCHAR
## Consulta 1
select
nombre_producto,
precioProducto
from productos 
where nombre_producto like '%pro%';

##consulta 2 Texto varchar en mayusculas
select
upper(nombreCliente) AS nombre_mayuscula,
emailCliente,
ciudad
from clientes;

## Consultas con metodos numericos
## 1. Consulta el stock de unidades de todos los productos 
select sum(stoProdT) as total_inventario
from productos;

## 2. Cuantos pedidos tienen más de dos cantidades
select 
count(*) as pedidos_cantidad_alta
from pedido
where cantidadProducto >= 2;

##Cargar archivos en csv
## se importa desde schemas clic derecho en tablas 
#y en codigo
##load data infile 'localizacion del csv'
##into table clientes
## fields terminated by ','
## enclosed by '"'
## lines terminated by 'n\'
## ignore 1 rows; 
## set foreing_key_checks=0;  Para desactivar llaves foraneas  
## set foreing_key_checks=1;  Para activar llaves foraneas  

/* agrupar group by */
describe productos;
select * from productos group by categoriaProducto;

##Funciones calculadas y el having 
select categoriaProducto,
 count(*) as Cantidad,
 avg(precioProducto) as promedioMedio
 from productos
 group by categoriaProducto
 having  avg(precioProducto) > 5000
 order by promedioMedio desc;
 
## Formato precio
select format(precioProducto,2,'es_CO') as precio 
 from productos;
 ## Funciones calculadas
 select
 count(*) as Total,
avg(precioProducto) as promedioPrecio ,
 max(precioProducto) as precioMaximo,
 min(precioProducto) as precioMinimo,
 sum(stoProdT) as StockTotal
from productos;

##todos los nombres de clientes y concatenar nombre de cliente con el mail 
select
upper(nombreCliente) AS nombre_mayuscula,
concat(nombreCliente,' ',emailCliente) as email ##Se usa para creado por
from clientes;
