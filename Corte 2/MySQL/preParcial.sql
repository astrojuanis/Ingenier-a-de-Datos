##PreParcial
-- =====================================================
-- DDL: CREACION DE BASE DE DATOS Y TABLAS
-- =====================================================
DROP DATABASE IF EXISTS preParcial;
CREATE DATABASE preParcial CHARACTER SET utf8mb4;
USE preParcial;

CREATE TABLE clientes (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombreCliente          VARCHAR(100) NOT NULL,
    emailCliente          VARCHAR(100) UNIQUE NOT NULL,
    ciudadCliente          VARCHAR(60),
    fecha_registroCliente  DATE
);

CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombreProducto       VARCHAR(100) NOT NULL,
    categoriaProducto    VARCHAR(60),
    precioProducto       DECIMAL(10,2) NOT NULL CHECK (precioProducto > 0),
    stockProducto        INT DEFAULT 0
);

CREATE TABLE pedidos (
    pedido_id    	INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   	INT NOT NULL,
    producto_id  	INT NOT NULL,
    cantidadPedido  INT NOT NULL CHECK (cantidadPedido > 0),
    fecha_pedido 	DATE,
    estadoPedido    VARCHAR(20) DEFAULT "pendiente" CHECK (estadoPedido IN ("pendiente","entregado","cancelado")),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- =====================================================
-- DML: DATOS DE PRUEBA
-- =====================================================
INSERT INTO clientes (nombreCliente, emailCliente, ciudadCliente, fecha_registroCliente) 
VALUES 
 ("Ana Lopez","ana@mail.com","Bogota","2023-01-15"),
 ("Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"),
 ("Maria Torres","maria@mail.com","Cali","2023-05-10"),
 ("Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"),
 ("Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"),
 ("Luis Martinez","luis@mail.com","Bogota","2024-01-20"),
 ("Camila Vargas","camila@mail.com","Cali","2024-02-14"),
 ("Diego Morales","diego@mail.com","Medellin","2024-03-30");

INSERT INTO productos (nombreProducto, categoriaProducto, precioProducto, stockProducto) 
VALUES 
 ("Laptop Pro 15","Computadores",3500000.00,12),
 ("Mouse Inalambrico","Perifericos",85000.00,50),
 ("Teclado Mecanico","Perifericos",220000.00,30),
 ("Monitor 27","Pantallas",1200000.00,8),
 ("Auriculares BT","Audio",350000.00,25),
 ("Webcam HD","Perifericos",180000.00,20),
 ("Disco SSD 1TB","Almacenamiento",420000.00,40),
 ("Tablet 10","Moviles",1800000.00,6);

INSERT INTO pedidos (cliente_id, producto_id, cantidadPedido, fecha_Pedido, estadoPedido)
 VALUES 
(1,1,1,"2024-01-10","entregado"),(1,2,2,"2024-01-15","entregado"),
(2,3,1,"2024-02-05","entregado"),(2,5,1,"2024-02-20","cancelado"),
(3,4,1,"2024-03-01","entregado"),(3,7,2,"2024-03-15","pendiente"),
(4,2,3,"2024-04-02","entregado"),(4,6,1,"2024-04-10","pendiente"),
(5,8,1,"2024-04-18","entregado"),(6,1,2,"2024-05-05","entregado"),
(6,3,1,"2024-05-12","pendiente"),(7,5,2,"2024-05-20","entregado"),
(1,7,1,"2024-06-01","entregado"),(8,4,1,"2024-06-10","cancelado"),
(5,2,4,"2024-06-15","entregado"),(3,1,1,"2024-07-01","pendiente");

/* Punto 1: Agregue a la tabla pedidos una columna total_valor 
DECIMAL(12,2) generada automáticamente como la multiplicacion 
de cantidad por el precio del producto (columna calculada 
persistida con AS ... STORED, o en su defecto agréguela 
como columna normal y luego actualice su valor mediante un 
UPDATE con JOIN entre pedidos y productos). 
Finalmente, agregue un índice sobre la columna estado.
Clausulas requeridas: ALTER TABLE, UPDATE ... JOIN, CREATE INDEX */

alter table pedidos add column totalValor decimal(12.2);

update pedidos p
join productos pr on p.producto_id = pr.producto_id
set p.totalValor = p.cantidadPedido * pr.precioProducto;

create index idxEstadoPedido
on pedidos (estadoPedido);

/* Punto 2: Cree la tabla log_cambios_estado (log_id PK AI, pedido_id FK, 
estado_anterior VARCHAR(20), estado_nuevo VARCHAR(20), 
fecha_cambio DATETIME DEFAULT NOW()). A continuación, cree una vista 
llamada vista_log_reciente que muestre los últimos 10 registros de 
log_cambios_estado ordenados por fecha_cambio descendente.
Clausula requeridas: CREATE TABLE, FOREIGN KEY, CREATE VIEW, ORDER BY, LIMIT
*/
create table log_cambios_estado (
logId	int primary key auto_increment,
pedido_id  int,
estadoAnterior varchar (20),
estadoNuevo varchar (20),
fechaCambio 	 datetime default now(),
FOREIGN KEY (pedido_id)  REFERENCES pedidos(pedido_id)
);

CREATE OR REPLACE VIEW vista_log_reciente  as 
SELECT * from log_cambios_estado
order by fechaCambio desc
limit 10;

/* Punto 3: Realice las siguientes operaciones en una misma sesión: 
(a) Inserte un nuevo cliente (nombre=Laura Rios, email=laura@mail.com, 
ciudad=Manizales). (b) Inserte un pedido para ese cliente del 
producto_id=3 con cantidad=2 y estado=pendiente. 
(c) Actualice el stock del producto_id=3 decrementandolo en 2. 
(d) Consulte con un JOIN el nombre del cliente, nombre del producto 
y estado del pedido recién creado.
Clausula requeridas: INSERT, UPDATE, SELECT con JOIN, WHERE*/
-- Punto a 
insert into clientes (nombreCliente, emailCliente, ciudadCliente) 
VALUES 
 ("Laura Rios","alaura@mail.com","Manizales");
-- Punto b
insert into pedidos (cliente_id, producto_id, cantidadPedido, estadoPedido)
 VALUES 
 (9,3,2,'pendiente');
 
 -- Punto c
 update productos
 set stockProducto = StockProducto - 2
 where producto_id = 3;
 -- Punto d 
select 
	c.nombreCliente, 
	pr.nombreProducto,
	p.estadoPedido
from pedidos p 
join clientes c on p.cliente_id = c.cliente_id
join productos pr on p.producto_id = pr.producto_id
where c.emailCliente = 'alaura@mail.com'	
	and p.producto_id = 3
    order by p.pedido_id desc
    limit 1;
    
/* Punto 4: Actualice el precio de todos los productos cuyo stock sea menor
 al promedio de stock de su misma categoría (use subconsulta correlacionada
 ), incrementando el precio un 8%. Luego elimine los pedidos con estado 
 cancelado cuyos clientes no tengan ningún otro pedido en estado entregado
 (use subconsulta con NOT EXISTS).
Clausulas requeridas: UPDATE con subconsulta correlacionada, DELETE con NOT EXISTS
*/
SET SQL_SAFE_UPDATES = 0; -- Por si marca error de seguridad
update productos p
-- Consulta de promedio y restricciones 
set p.precioProducto = p.precioProducto * 1.08
	where p.stockProducto < (
	select avg (p2.stockProducto)
	from productos p2
    where p2.categoriaProducto = p.categoriaProducto  -- correlacion
    );

delete from pedidos p -- ubicacion de donde se va a eliminar
-- Elimina las filas cuyo id este en la consulta 
where pedido_id in (
-- subconsulta externa crea una tabla temporal
	select pedido_id from (
		select p.pedido_id
        -- restricciones 
        from pedidos p
        where p.estadoPedido = 'cancelado'
        and not exists (
			select 1
            from pedidos p2
            where p2.cliente_id = p.cliente_id
            and p2.estadoPedido = 'entregado')
            )as subconsulta 
            );
	 SET SQL_SAFE_UPDATES = 1;

/*  Punto 5. Liste el nombre del cliente, ciudad, nombre del producto, cantidad y 
fecha_pedido de todos los pedidos entregados cuyo total (cantidad * precio)
supere el promedio general de totales de pedidos entregados. 
Ordene los resultados por total descendente.
Clausulas requeridas: JOIN tres tablas, WHERE con subconsulta escalar AVG, ORDER BY DESC
*/
select 
	c.nombreCliente,
    c.ciudadCliente,
    pr.nombreProducto,
    p.cantidadPedido,
    p.fecha_pedido,
    (p.cantidadPedido * pr.precioProducto) as totalPedido -- Columna calculada para el order by
from pedidos p
join clientes c on p.cliente_id = c.cliente_id -- relaciona pedidos con clientes
join productos pr on p.producto_id = pr.producto_id -- relaciona pedidos con productos
where p.estadoPedido = 'entregado'  -- Restriccion solo pedidos entregados
and (p.cantidadPedido * pr.precioProducto) > ( -- que superen el promedio 
	select avg(p2.cantidadPedido * pr2.precioProducto)
    from pedidos p2
    join productos pr2 on p2.producto_id = pr2.producto_id
    where p2.estadoPedido = 'entregado' -- promedio de solo entregados
    )
    order by totalPedido desc; -- ordenados 

/* Punto 6: Cree la vista vista_ventas_ciudad que muestre: ciudad, 
total_pedidos_entregados, suma_ingresos (SUM de cantidad*precio) 
y promedio_ingreso_por_pedido. Luego consulte la vista para mostrar 
solo las ciudades cuyo suma_ingresos supere los 5,000,000, 
ordenadas de mayor a menor.
Clausula requeridas: CREATE VIEW con JOIN, GROUP BY, CREATE INDEX opcional, SELECT FROM vista con WHERE y ORDER BY
*/ 
create or replace view vistaVentasCiudad as 
	select 
    c.ciudadCliente as ciudad,
    count(p.pedido_id) as totalPedidosEntregados, -- Contar pedidos 
    sum(p.cantidadPedido * pr.precioProducto) as ingresos, -- suma ingresos
    avg(p.cantidadPedido * pr.precioProducto) as promedioIngresoPedido -- promedio ingresos
from pedidos p
join clientes c on p.cliente_id = c.cliente_id  -- Trae los datos del cliente
join productos pr on p.producto_id = pr.producto_id -- Trae el precio del producto
where p.estadoPedido = 'entregado' -- Condicion
group by c.ciudadCliente;

select *  
from vistaVentasCiudad  -- Visualizar vista creada
where ingresos > 5000000 -- filtra ciudades con ingresos > 5.000.000
order by ingresos desc; 

/* Punto 7. Cree la vista vista_productos_populares que liste los productos
 que hayan sido pedidos por más de un cliente distinto 
 (en pedidos entregados). La vista debe mostrar: producto_id, nombre, 
 categoria, precio y total_clientes_distintos. Luego use la vista para 
 obtener unicamente los productos de la categoría Perifericos.
 1*/
create or replace view vistaProductosPopulares as
select 
	pr.producto_id,
    pr.nombreProducto as nombre,
    pr.categoriaProducto as categoria,
    pr.precioProducto as precio,
    count(distinct p.cliente_id) as totalClientesDistintos -- Conteo clientes unicos
from productos pr
join pedidos p on pr.producto_id = p.producto_id -- conecta productos y pedidos
where p.estadoPedido = 'entregado' -- restricciones
group by
	pr.producto_id,
    pr.nombreProducto,
    pr.categoriaProducto,
    pr.precioProducto
HAVING COUNT(DISTINCT p.cliente_id) > 1; 

select * -- Consulta vista 
from vistaProductosPopulares
where categoria = 'perifericos' ;

/*Punto 8. Cree la función fn_ingreso_cliente(p_cliente_id INT) que retorne
 el ingreso total acumulado de un cliente (suma de cantidad*precio solo 
 para pedidos entregados, usando JOIN entre pedidos y productos). 
 Luego use esa función en un SELECT sobre la tabla clientes para 
 mostrar nombre, ciudad y su ingreso_total, ordenados de mayor a 
 menor ingreso.
Clausulas requeridas: CREATE FUNCTION con SELECT JOIN, RETURN; SELECT usando la función en la lista de columnas
*/ 
delimiter $$

create function fn_ingresoCliente (p_cliente_id int) -- define nombre y parametro de entrada
returns decimal (12,2) -- define tipo de dato que devuelve 
deterministic 
begin 
	declare v_ingreso 	decimal (12,2); -- declara la variable local
    select sum(p.cantidadPedido * pr.precioProducto) -- Calcula la suma
    into v_ingreso -- guarda el resultado en la variable
    from pedidos p
    join productos pr on p.producto_id = pr.producto_id -- necesario para acceder al precio
    where p.cliente_id = p_cliente_id -- correlaciona con el parametro recibido
    and p.estadoPedido = 'entregado'; -- restriccion 
    
    return ifnull(v_ingreso, 0);
end$$
DELIMITER ; 

-- usar la funcion
select 
	c.nombreCliente,
    c.ciudadCliente,
    fn_ingresoCliente(c.cliente_id) as ingresoTotal
from clientes c
order by ingresoTotal desc; 

/* Punto 9. Cree la función fn_stock_suficiente(p_producto_id INT, 
p_cantidad_solicitada INT) que retorne 1 si el stock actual del 
producto es mayor o igual a la cantidad solicitada, o 0 en 
caso contrario. Luego escriba una consulta que liste nombre 
y stock de todos los productos donde fn_stock_suficiente(producto_id, 5) 
= 0, es decir, productos con menos de 5 unidades disponibles.
Clausulas requeridas: CREATE FUNCTION, SELECT con WHERE usando la función, subconsulta o logica equivalente
*/
delimiter $$

create function fn_stockSuficiente(
	p_producto_id int, 				-- Parametro 1 que requiere para identificar el producto
    p_cantidadSolicitada int	    -- Cantidad necesitada
    )
    returns int 
    deterministic 
    begin 
		declare v_stock int;
        
        select stockProducto
        into v_stock
        from productos
        where producto_id = p_producto_id;
        
        if v_stock >= p_cantidadSolicitada then  -- Compara entre el stock y lo necesitado
			return 1;
		else 
			return 0;
		end if; 
	end$$
delimiter ;

-- Usar la funcion
select 
	nombreProducto as nombre,
    stockProducto as stock
from productos 
where fn_stockSuficiente(producto_id, 5 ) = 0;  -- Producto donde la funcion retorna a 0


/* Punto 10. Cree el procedimiento sp_actualizar_estado_pedido
(p_pedido_id INT, p_nuevo_estado VARCHAR(20)) que: 
(a) Verifique que el pedido exista (si no, retorne mensaje de error). 
(b) Inserte un registro en log_cambios_estado con el estado anterior 
y el nuevo. (c) Actualice el estado del pedido. (d) Si el nuevo estado 
es cancelado, restaure el stock del producto correspondiente.
Clausula requeridas: CREATE PROCEDURE, SELECT INTO var, IF/ELSE, INSERT, UPDATE dos tablas
*/
DROP PROCEDURE IF EXISTS sp_actualizarEstadoPedido;
delimiter $$
create procedure sp_actualizarEstadoPedido (
	p_pedido_id int, -- Parametro id del pedido
    p_nuevoEstado varchar(20) -- nuevo estado a asignar 
    )
begin 
	declare v_estadoAnterior varchar(20); -- Guarda el estado actual
    declare v_producto_id 	int; -- Guarda el producto del pedido
    declare v_cantidad int; -- Guarda la cantidad del pedido
 
 -- a) Verificar que el pedido exista 
	select estadoPedido, producto_id, cantidadPedido -- Obtiene los datos actuales
    into v_estadoAnterior, v_producto_id, v_cantidad  -- Se guarda en las variables locales 
    from pedidos 
    where pedido_id = p_pedido_id;
    
    if v_estadoAnterior is null then 
		select 'Error: el pedido no existe' as mensaje;
	else 
    -- b) insertar en log el cambio de estado 
		insert into log_cambios_estado -- Registra en la tabla de log 
			(pedido_id, estadoAnterior, estadoNuevo)
		values  (p_pedido_id, v_estadoAnterior, p_nuevoEstado);
        
	-- C) actualizar el estado del pedido 
		update pedidos
        set estadoPedido = p_nuevoEstado
        where pedido_id = p_pedido_id;
        
	-- D) si el nuevo estado es cancelado, restaurar stock
    if p_nuevoEstado = 'cancelado' then 
		update productos
        set stockProducto = stockProducto + v_cantidad
        where producto_id = v_producto_id;
	end if;
    
    select 'Pedido actualizado correctamente' as mensaje;
end if;
end$$ 
delimiter ;

-- Llamar el procedimiento
call sp_actualizarEstadoPedido(4, 'cancelado');

/* Punto 11. Cree el procedimiento sp_resumen_cliente(p_cliente_id INT) 
que ejecute y retorne en un solo SELECT: nombre del cliente, ciudad, total
 de pedidos por estado (use SUM con CASE WHEN para contar pedidos entregados,
 pendientes y cancelados en columnas separadas) y el ingreso total solo 
 de pedidos entregados.
Clausula requeridas: CREATE PROCEDURE, SELECT con JOIN, SUM(CASE WHEN ...), GROUP BY
 */ 
 delimiter $$
 create procedure sp_resumenCliente(p_cliente_id int)
 begin 
	select 
		c.nombreCliente,
        c.ciudadCliente,
        -- Contar pedidos por estado en columnas separadas
        sum( case when p.estadoPedido = 'entregado' then 1 else 0 end) 
        as pedidosEntregados,
        sum( case when p.estadoPedido = 'pendiente' then 1 else 0 end) 
        as pedidosPendientes,
        sum( case when p.estadoPedido = 'cancelado' then 1 else 0 end) 
        as pedidosCancelados,
        
        -- Solo los entregados
        sum(case when p.estadoPedido = 'entregado'
			then p.cantidadPedido * pr.precioProducto
            else 0 end) as ingresototal
        
        from clientes c
        join pedidos p on c.cliente_id = p.cliente_id 
        join productos pr on p.producto_id = pr.producto_id
        where c.cliente_id = p_cliente_id
        group by c.cliente_id, c.nombreCliente, c.ciudadCliente; 
	end$$
 delimiter ;
 
 -- Llamar funcion
 call sp_resumenCliente (1);
 
 /* Punto 12. Cree la vista vista_pedidos_pendientes que muestre pedido_id,
 nombre del cliente, nombre del producto, cantidad, precio unitario 
 y dias_espera (DATEDIFF entre CURDATE() y fecha_pedido) para todos 
 los pedidos con estado pendiente. 
 Luego cree el procedimiento 
 sp_alertar_retrasos(p_dias_limite INT) que consulte esa vista 
 y retorne los pedidos cuyo dias_espera supere p_dias_limite.
Clausula requeridas: CREATE VIEW con JOIN y DATEDIFF, CREATE PROCEDURE con SELECT FROM vista con WHERE
*/
-- Creacion de la vista 
create or replace view vista_pedidosPendientes as 
select 
	p.pedido_id,
    c.nombreCliente,
    pr.nombreProducto,
    p.cantidadPedido,
    pr.precioProducto as precioUnitario,
    datediff(curdate(), p.fecha_Pedido) as diasEspera -- Diferencia en dias entre el pedido y hoy
from pedidos p
join clientes c on p.cliente_id = c.cliente_id
join productos pr on p.producto_id = pr.producto_id
where p.estadoPedido = 'pendiente';

-- Creacion del procedimiento 
DELIMITER $$
create procedure sp_alertarRetrasos(p_diasLimite int)
begin
	select * 
    from vista_pedidosPendientes
    where diasEspera > p_diasLimite
    order by diasEspera desc;
end$$
delimiter ; 

call sp_alertarRetrasos(30);
    
/* Punto 13. Agregue la columna descuento DECIMAL(5,2) DEFAULT 0 a la tabla
 productos con una restricción CHECK que garantice valores entre 0 y 50. 
 Cree la función fn_precio_final(p_producto_id INT) que retorne el precio 
 del producto aplicando su descuento (precio * (1 - descuento/100)). 
 Luego escriba una consulta que muestre nombre, precio, descuento 
 y precio_final para los 3 productos con mayor precio_final, 
 usando la función.
Clausulas requeridas: ALTER TABLE ADD COLUMN CHECK, CREATE FUNCTION con SELECT, SELECT ORDER BY DESC LIMIT 3
*/
-- Agregar la columna 
alter table productos 
add column descuento decimal (5,2) default 0
check (descuento between 0 and 50); -- restricciones 

-- Funcion 
delimiter $$
create function fn_precioFinal(p_producto_id int)
returns decimal (12,2)
deterministic 
begin 
	declare v_precio	decimal(12,2);
    declare v_descuento	 decimal(5,2);
    
    select precioProducto, descuento
    into v_precio, v_descuento
    from productos
    where producto_id = p_producto_id;
    
    return v_precio * (1 - v_descuento /100);
end$$
delimiter ;

select 
	nombreProducto	as nombre,
    precioProducto as precio,
    descuento, 
    fn_precioFinal(producto_id) as precioFinal -- Llama a la funcion
from productos
order by precioFinal desc
limit 3;  -- Solo llama los 3 primeros 

/* Punto 14. Cree el procedimiento sp_registrar_pedido
(p_cliente_id INT, p_producto_id INT, p_cantidad INT) que: 
(a) Valide que el cliente exista. (b) Valide que el stock sea suficiente. 
(c) Inserte el pedido con estado pendiente. 
(d) Actualice el stock descontando la cantidad. 
(e) Retorne con un SELECT JOIN el pedido recién creado con nombre 
del cliente y nombre del producto.
Clausulas requeridas: CREATE PROCEDURE, SELECT INTO var para validar, IF, INSERT, UPDATE, SELECT con JOIN al final
*/
drop procedure if exists sp_registrarPedido;
delimiter $$
create procedure sp_registrarPedido(
		p_cliente_id int,
        p_producto_id int,
        p_cantidad int
        )
begin
	declare v_clienteExiste int;
    declare v_stock int;
    declare v_nuevoPedido_id int;
    
    -- a) Validar que el cliente exista
	select count(*)
    into v_clienteExiste
    from clientes 
    where cliente_id = p_cliente_id;
    
    if v_clienteExiste = 0 then 
		select 'Error: Cliente no exisite' as mensaje;
	else 
    -- B. Validar que el stock es suficiente 
    select stockProducto
    into v_stock
    from productos
    where producto_id = p_producto_id;
    
    if v_stock < p_cantidad then 
		select 'Error: stock insuficiente' as mensaje;
	else 
    -- c. Insertar el pedido con estado pendiente 
    insert into pedidos
		(cliente_id, producto_id, cantidadPedido, fecha_pedido, estadoPedido)
        values (p_cliente_id, p_producto_id, p_cantidad, CURDATE(), 'pendiente');
        
	set v_nuevoPedido_id = last_insert_id(); -- llama al id recien nombrado
		-- D. Actualizar el stock descontando la cantidad 
        update productos
        set stockProducto = stockProducto - p_cantidad
        where producto_id = p_producto_id;
        
        -- Retornar el pedido recien llegado con join 
        select
			p.pedido_id,
            c.nombreCliente,
            pr.nombreProducto,
            p.cantidadPedido,
            p.estadoPedido,
            p.fecha_pedido
		from pedidos p
        join clientes c on p.cliente_id = c.cliente_id
        join productos pr on p.producto_id = pr.producto_id
        where p.pedido_id = v_nuevoPedido_id;
	end if;
    end if;
    end$$
delimiter ;

-- Llamar el procedimiento 
CALL sp_registrarPedido(1, 2, 3); 

/* Punto 15. Cree la funcion fn_clasificar_producto(p_producto_id INT) 
que retorne: PREMIUM si el precio > 1,000,000; ESTANDAR si esta entre 
200,000 y 1,000,000; BASICO si es menor a 200,000. 
Luego cree la vista vista_catalogo_clasificado que muestre nombre, 
categoria, precio, clasificacion (usando la funcion) y stock para todos 
los productos. Finalmente, consulte la vista mostrando solo los productos
 PREMIUM con stock > 5.
Clausulas requeridas: CREATE FUNCTION con CASE, CREATE VIEW usando la función, SELECT FROM vista con WHERE compuesto
*/
delimiter $$
create function fn_clasificar_producto(p_producto_id INT) 
returns varchar(20)
deterministic 
begin 
	declare v_precio decimal (12,2);
    select precioProducto
    into v_precio
    from productos
    where producto_id = p_producto_id;
    
    return case  -- condiciones
		when v_precio > 1000000 then 'premium'
        when v_precio between 200000 and 1000000 then 'estandar'
        else 'basico'
	end;
	end$$
delimiter ;

-- Crear vista 
 create or replace view vistaCatalogoClasificado as 
 select 
	nombreProducto as nombre,
    categoriaProducto as categoria,
    precioProducto as precio, 
    fn_clasificar_producto(producto_id) as clasificacion,
    stockProducto as stock
from productos;

-- Consultar la vista 
select *
from vistaCatalogoClasificado
where clasificacion = 'premium'
and stock > 5;

/* Punto 16. Cree la vista vista_clientes_vip que contenga el cliente_id, 
nombre, ciudad y total_pedidos_entregados de clientes que hayan realizado 
mas pedidos entregados que el promedio de pedidos entregados por cliente 
(use subconsulta en el HAVING). Luego escriba una consulta sobre esa vista
 junto con un JOIN a pedidos y productos para listar el detalle de los 
 últimos 2 pedidos de cada cliente VIP, mostrando nombre del cliente, 
 nombre del producto y fecha_pedido.
Clausulas requeridas: CREATE VIEW con HAVING > subconsulta AVG, SELECT con JOIN y subconsulta o RANK/ROW_NUMBER
*/
use preparcial;

create or replace view vistaClientesVIP as 
select 
	c.cliente_id,
    c.nombreCliente,
    c.ciudadCliente,
    count(p.pedido_id) as totalPedidosEntregados
from clientes c
join pedidos p on c.cliente_id = p.cliente_id
where p.estadoPedido = 'entregado'
group by c.cliente_id, c.nombreCliente, c.ciudadCliente
having count(p.pedido_id) > 
(   select avg(conteo)
    from (
    select count(pedido_id) as conteo
    from pedidos
    where estadoPedido = 'entregado'
    group by cliente_id
    ) as promedios
    );
    
    -- Consultar vista 
    select 
		v.nombreCliente,
        pr.nombreProducto,
        p.fecha_pedido
	from vistaClientesVIP v
    JOIN pedidos p   ON v.cliente_id   = p.cliente_id              -- JOIN 1: conecta VIP con sus pedidos
	JOIN productos pr ON p.producto_id = pr.producto_id            -- JOIN 2: conecta pedidos con productos
WHERE p.pedido_id IN (                                         -- filtra solo los últimos 2 pedidos por cliente
    SELECT pedido_id FROM (
        SELECT pedido_id,
               ROW_NUMBER() OVER (                             -- ROW_NUMBER: numera pedidos por cliente
                   PARTITION BY cliente_id                     -- PARTITION BY: reinicia el conteo por cliente
                   ORDER BY fecha_pedido DESC                  -- ORDER BY DESC: el más reciente es el 1
               ) AS rn
        FROM pedidos
        WHERE cliente_id = v.cliente_id
    ) AS ranked
    WHERE rn <= 2                                              -- WHERE: toma solo los 2 más recientes
)
ORDER BY v.nombreCliente, p.fecha_pedido DESC;

/* -- VISTA
CREATE OR REPLACE VIEW nombre AS
SELECT ... FROM ... JOIN ... WHERE ... GROUP BY ...;

-- FUNCIÓN
DELIMITER $$
CREATE FUNCTION nombre(parametro TIPO)
RETURNS TIPO
DETERMINISTIC
BEGIN
    DECLARE variable TIPO;
    SELECT ... INTO variable FROM ...;
    RETURN variable;
END$$
DELIMITER ;

-- PROCEDIMIENTO
DELIMITER $$
CREATE PROCEDURE nombre(parametro TIPO)
BEGIN
    DECLARE variable TIPO;
    SELECT ... INTO variable FROM ...;
    IF condicion THEN
        -- acción
    END IF;
END$$
DELIMITER ;
*/
