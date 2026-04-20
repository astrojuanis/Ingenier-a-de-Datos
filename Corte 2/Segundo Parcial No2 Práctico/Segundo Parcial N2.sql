-- Segundo Parcial N2
-- Juanita Castrillon
-- 2:15pm
-- ================================================================
-- CASO: Sistema de Gestion Hospitalaria
-- Tablas: medicos, pacientes, consultas
-- ================================================================
CREATE DATABASE hospital_db CHARACTER SET utf8mb4;
USE hospital_db;

CREATE TABLE medicos (
    medico_id        INT AUTO_INCREMENT PRIMARY KEY,
    nombreMedicos           VARCHAR(100) NOT NULL,
    especialidadMedicos     VARCHAR(80)  NOT NULL,
    salarioMedicos          DECIMAL(12,2) NOT NULL CHECK (salarioMedicos > 0),
    fecha_ingresoMedicos    DATE NOT NULL,
    activoMedicos           TINYINT(1)
);

CREATE TABLE pacientes (
    paciente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombrePaciente           VARCHAR(100) NOT NULL,
    fecha_nacimientoPaciente  DATE NOT NULL,
    ciudadPaciente           VARCHAR(60),
    emailPaciente            VARCHAR(100) UNIQUE,
    epsPaciente              VARCHAR(80)
);

CREATE TABLE consultas (
    consulta_id      INT AUTO_INCREMENT PRIMARY KEY,
    medico_id        INT NOT NULL,
    paciente_id      INT NOT NULL,
    fechaConsulta   DATE NOT NULL,
    diagnostico      VARCHAR(200),
    costoConsulta            DECIMAL(10,2) NOT NULL CHECK (costoConsulta > 0),
    estadoConsulta           VARCHAR(20) DEFAULT "programada"
        CHECK (estadoConsulta IN ("programada","realizada","cancelada")),
    FOREIGN KEY (medico_id)   REFERENCES medicos(medico_id),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(paciente_id)
);

-- ================================================================
-- DML: DATOS DE PRUEBA
-- ================================================================
INSERT INTO medicos (nombreMedicos, especialidadMedicos, salarioMedicos, fecha_ingresoMedicos, activoMedicos)
VALUES
 ("Dra. Laura Rios","Cardiologia",8500000.00,"2018-03-10",1),
 ("Dr. Carlos Mesa","Neurologia",9200000.00,"2016-07-22",1),
 ("Dra. Sofia Vega","Pediatria",7800000.00,"2020-01-15",1),
 ("Dr. Andres Gil","Ortopedia",8100000.00,"2019-06-01",1),
 ("Dra. Paula Mora","Cardiologia",8700000.00,"2017-09-30",1),
 ("Dr. Ivan Cruz","Dermatologia",7500000.00,"2021-04-12",0),
 ("Dra. Marta Leon","Neurologia",9500000.00,"2015-11-05",1),
 ("Dr. Felipe Ossa","Pediatria",7600000.00,"2022-02-28",1);

INSERT INTO pacientes (nombrePaciente, fecha_nacimientoPaciente,ciudadPaciente, emailPaciente, epsPaciente)
 VALUES
 ("Juan Perez","1985-04-12","Bogota","juan@mail.com","Sura"),
 ("Ana Gomez","1992-08-25","Medellin","ana@mail.com","Compensar"),
 ("Luis Vargas","1978-12-03","Cali","luis@mail.com","Sura"),
 ("Maria Diaz","2001-06-17","Bogota","maria@mail.com","Famisanar"),
 ("Carlos Ruiz","1965-01-30","Barranquilla","carlos@mail.com","Compensar"),
 ("Lucia Herrera","1990-09-08","Bogota","lucia@mail.com","Sura"),
 ("Pedro Soto","2005-03-22","Cali","pedro@mail.com","Famisanar"),
 ("Valeria Torres","1998-11-14","Medellin","valeria@mail.com","Compensar");

INSERT INTO consultas (medico_id, paciente_id, fechaConsulta, diagnostico, costoConsulta, estadoConsulta)
VALUES
 (1,1,"2024-01-10","Hipertension leve",150000,"realizada"),
 (1,3,"2024-01-22","Control cardiaco",150000,"realizada"),
 (2,2,"2024-02-05","Cefalea cronica",200000,"realizada"),
 (2,5,"2024-02-18","Migraña",200000,"cancelada"),
 (3,4,"2024-03-01","Control crecimiento",90000,"realizada"),
 (3,7,"2024-03-14","Fiebre alta",90000,"realizada"),
 (4,6,"2024-04-02","Fractura muñeca",250000,"realizada"),
 (4,1,"2024-04-15","Dolor rodilla",250000,"programada"),
 (5,8,"2024-05-03","Arritmia",180000,"realizada"),
 (5,2,"2024-05-20","Ecocardiograma",180000,"realizada"),
 (6,3,"2024-05-28","Dermatitis",120000,"cancelada"),
 (7,5,"2024-06-10","Epilepsia control",220000,"realizada"),
 (7,6,"2024-06-22","Resonancia",220000,"programada"),
 (8,4,"2024-07-01","Vacunacion",60000,"realizada"),
 (1,8,"2024-07-15","Hipertension severa",180000,"realizada"),
 (3,2,"2024-07-28","Seguimiento",90000,"programada");
 
/* Punto 11. Cree la vista vista_agenda_pendiente que muestre: consulta_id, nombre del medico, especialidad, nombre del paciente, fecha_consulta 
y dias_espera (DATEDIFF entre fecha_consulta y CURDATE()) para todas las consultas en estado programada.
 Luego cree el procedimiento sp_cancelar_consultas_vencidas(p_dias_limite INT) que: 
 (a) Consulte la vista para identificar consultas cuyo dias_espera sea mayor a p_dias_limite (es decir, con fecha pasada). 
 (b) Actualice esas consultas a estado cancelada. 
 (c) Retorne el numero de filas afectadas con ROW_COUNT().
Clausulas requeridas: CREATE VIEW con JOIN y DATEDIFF, CREATE PROCEDURE con UPDATE usando condicion de la vista, ROW_COUNT() */ 

-- Creacion vista 
create or replace view vista_agenda_pendiente as 
select 
	c.consulta_id,
    m.nombreMedicos,
    m.especialidadMedicos,
    p.nombrePaciente,
    c.fechaConsulta,
    datediff(curdate(), c.fechaConsulta) as diasEspera 
from consultas c
join pacientes p  on p.paciente_id = c.paciente_id
join medicos m on m.medico_id = c.medico_id
where c.estadoConsulta = 'programada';


-- Creacion del procedimiento 
DELIMITER $$
create procedure sp_cancelar_consultas_vencidas(diasEspera int )
begin
declare 
		c_estadoActualizado varchar(20);
        p_diasLimite int;

-- a  Consulte la vista para identificar consultas cuyo dias_espera sea mayor a p_dias_limite (es decir, con fecha pasada). 
	select * 
    into c_estadoActualizado
    from vista_agenda_pendiente
    where diasEspera > p_diasLimite;
-- b Actualice esas consultas a estado cancelada.
	if diasEspera > p_diasLimite  then 
		set c_estadoActualizado = 'cancelado';
		update consultas
        set estadoConsulta = c_estadoActualizado
        where consulta_id = p_pedido_id;
    select 'Consulta actualizada correctamente' as mensaje;
end if;
(c) Retorne el numero de filas afectadas
	select 
		c.estadoConsulta
        sum(case when estadoConsulta = 'cancelado' ) as columnasActualizadas
end$$
delimiter ; 

call sp_cancelar_consultas_vencidas(1);
