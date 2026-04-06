#Reto 1 
##
##    dos (id, nombre, deptoId, salario) roducto (idproducto, nombreproducto, precioproducto, categoriaproducto)
##partamento (idDepartamento, nombreDepartamento) ##
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


  
##Subconsulta
select nombreEmpleado, salarioEmpleado as salario,
(select avg(salarioEmpleado) from empleados) as promedioGeneral,
salarioEmpleado - (select avg(salarioEmpleado) from empleados) AS Desviacion from empleados;
