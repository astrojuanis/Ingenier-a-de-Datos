#Abril 08
##Reto 1 
##
##  Crea las siguientes tablas empleados (id, nombre, deptoId, salario) producto (idproducto, nombreproducto, precioproducto, categoriaproducto)
##departamento (idDepartamento, nombreDepartamento) ##
CREATE DATABASE IF NOT EXISTS tienda2;
USE tienda2;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS departamento;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE departamento (
  idDepartamento 	INT primary key auto_increment,
  nombreDepartamento 	varchar(120) not null
);

	CREATE TABLE empleados (
  idEmpleados		Int       PRIMARY KEY AUTO_INCREMENT,
  nombreEmpleado	varchar (100) not null,
  deptoIdFK 		INT 		null,
  salarioEmpleado	decimal(10,2),
  FOREIGN KEY (deptoIdFK) REFERENCES departamento (idDepartamento)
);

CREATE TABLE productos (
  idProducto        INT          PRIMARY KEY AUTO_INCREMENT,
  nombre_producto   VARCHAR(120) NOT NULL,
  precioProducto    DECIMAL(10,2),
  categoriaProducto VARCHAR(60)
);

CREATE TABLE pedidos (
  idPedido        INT          PRIMARY KEY AUTO_INCREMENT,
  idEmpleado	INT NOT NULL,
  fecha_pedido    datetime default now(),
  estado 		enum('pendiente', 'enviado', 'entregado', 'cancelado'),
  total			decimal (10,2) default 0,
  constraint FKPedidoEmpleado
  foreign key (idEmpleado) references empleados (idEmpleados)
);

CREATE TABLE detalle_pedido (
  idDetalle INT PRIMARY KEY AUTO_INCREMENT,
  idPedidoFK INT NOT NULL,
  idProductoFK INT NOT NULL,
  cantidad INT NOT NULL,
  precioUnitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precioUnitario) STORED,

  CONSTRAINT FKDetallePedido
    FOREIGN KEY (idPedidoFK) REFERENCES pedidos(idPedido)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    
    constraint FKDetalleProducto
		foreign key (idProductoFK) references productos(idProducto)
    );

##Reto 2 
#Registrar 5 datos en empleados, 3 departamentos y 5 productos.

DESCRIBE departamento;
INSERT INTO departamento(idDepartamento, nombreDepartamento)
VALUES 
  (1220,'Administrativo'),
  (3330,  'Ventas'),
  (10, 'Gerencia');
  Select * from departamento;

DESCRIBE empleados;
INSERT INTO empleados(nombreEmpleado,deptoIdFK, salarioEmpleado)
VALUES ('Ana Garcia', 1220, 2300000),
		('Julian	Medina', 3330, 3200000),
         ('Ana Gara', 10, 250000),
		('Carolina Jimenez', 1220,4000000),
		('Alejandro Palacios', 3330,5000000);
SELECT * FROM empleados;

DESCRIBE productos;
INSERT INTO productos (nombre_producto, precioProducto, categoriaProducto)
VALUES 
  ('Laptop Pro',   1200000,  'Electrónica'),
  ('Mouse USB',      50000,  'Accesorios'),
  ('Monitor 32"',  500000,   'Electrónica'),
  ('Iphone 17Pro', 3800000,	'Electrónica'),
  ('Teclados',     100000,  'Accesorios');
  
SELECT * FROM productos;

INSERT INTO pedidos (idEmpleado, estado)
VALUES
(1, 'pendiente'),
(2, 'enviado');

select * from pedidos;

INSERT INTO detalle_pedido (idPedidoFK, idProductoFK, cantidad, precioUnitario)
VALUES
(1, 1, 1, 1200000),
(1, 2, 2, 50000);

INSERT INTO detalle_pedido (idPedidoFK, idProductoFK, cantidad, precioUnitario)
VALUES
(2, 4, 1, 3800000),
(2, 5, 1, 100000);

select * from detalle_pedido;

  
##Subconsulta
###----where---
select nombreEmpleado, salarioEmpleado
from empleados
where salarioEmpleado>
	(select AVG(salarioEmpleado)
	from empleados);
###----where+in----
select nombreEmpleado, salarioEmpleado
from empleados
where deptoIdFK in
	(select idDepartamento
	from departamento
    where nombreDepartamento in ('Gerencia','Ventas'));
    
###----tabla derivada----
select deptoIdFK, prom_salario
from 
  (select deptoIdFK, AVG(salarioEmpleado) as prom_salario
  from empleados
  group by deptoIdFK) as promedios
where prom_salario > 450000;

## Reto 
select nombreEmpleado, salarioEmpleado as salario,
(select avg(salarioEmpleado) from empleados) as promedioGeneral,
salarioEmpleado - (select avg(salarioEmpleado) from empleados) AS Desviacion from empleados;

##Tarea 

select nombre_Producto, categoriaProducto, precioProducto from productos
where precioProducto > 
	(select avg(precioProducto) from productos)
    order by (precioProducto) desc; 
    
select * from productos;
    
    select avg(precioProducto) from productos;
    
    ##pedido con nombre del empleado
select 
	p.idPedido,
    e. nombreEmpleado
from pedidos p 
inner join empleados e on p.idEmpleado = e.idEmpleados;

##Utilizando varios joins mostrar el detalle de los pedidos y el empleado asignado 
select 
	e.nombreEmpleado,
    p.idPedido,
    p.fecha_pedido,
    p.estado,
    pr.nombre_producto,
    dp.cantidad,
    dp.precioUnitario,
    dp.subtotal
from detalle_pedido dp
inner join pedidos p on dp.idPedidoFK = p.idPedido
inner join empleados e on p.idEmpleado = e.idEmpleados
inner join productos pr on dp.idProductoFK = pr.idProducto;