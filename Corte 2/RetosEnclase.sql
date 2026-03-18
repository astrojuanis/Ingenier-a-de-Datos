##Reto1 
create database tienda_online;
use tienda_online;

##Reto 2
create table productos (
id_producto 		int 	AUTO_INCREMENT,
nombre_producto 	varchar(10),
precio_producto				decimal,
Stock_producto				int,	
fecha_creacion_producto  	datetime 	current_data_sta 	
categoria_producto			varchar(50)
);


##Reto3
create table clientes (
id_cliente 	int 	not null,
nombre_cliente 	varchar(20) 	not null,
email_cliente 	varchar(50)		unique,
telefono_cliente 	int 		null
);

create table pedidos (
id_pedido int 	 not null,
id_cliente int   not null,
fecha_pedido date not null,
total_pendido 	decimal	 not null,
FOREIGN KEY (id_cliente)
);

##Reto 4
alter table productos
add column categoria_producto;

alter table clientes;
##Como cambio el tipo de dato a varchar 15

alter table pedidos
rename to 
##Como se cambia el nombre de los campos 

describe productos;
