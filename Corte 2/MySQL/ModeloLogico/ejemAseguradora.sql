/*
Autor: Juanita Castrillón
Base de datos: Compañía de Seguros
Modelo Físico - DDL Completo
*/

CREATE DATABASE IF NOT EXISTS companiaseguros;
USE companiaseguros;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS detalleAccidente;
DROP TABLE IF EXISTS polizas;

DROP TABLE IF EXISTS seguros;

DROP TABLE IF EXISTS accidente;
DROP TABLE IF EXISTS automovil;
DROP TABLE IF EXISTS compania;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE compania (
idCompania          INT           AUTO_INCREMENT PRIMARY KEY,
nit                 VARCHAR(20)   NOT NULL UNIQUE,
nombreCompania      VARCHAR(50)   NOT NULL,
fechaFundacion      DATE          NULL,
representanteLegal  VARCHAR(100)  NOT NULL,
direccionCompania   VARCHAR(50)   NULL
);

CREATE TABLE automovil (
idAutomovil     INT         AUTO_INCREMENT PRIMARY KEY,
placa           VARCHAR(10) NOT NULL UNIQUE,
marca           VARCHAR(50) NOT NULL,
modelo          VARCHAR(50) NOT NULL,
tipo            VARCHAR(50) NOT NULL,
anoFabricacion  YEAR        NOT NULL,
serialChasis    VARCHAR(50) NOT NULL UNIQUE,
pasajeros       INT         NOT NULL,
cilindraje      INT         NOT NULL
);

CREATE TABLE accidente (
idAccidente     INT          AUTO_INCREMENT PRIMARY KEY,
fatalidades     INT          NOT NULL,
heridos         INT          NOT NULL,
lugar           VARCHAR(100) NOT NULL,
fechaAccidente  DATE         NOT NULL,
descripcion     TEXT         NULL
);

CREATE TABLE seguros (
idSeguro        INT             AUTO_INCREMENT PRIMARY KEY,
numPoliza       VARCHAR(30)     NOT NULL UNIQUE,
estado          VARCHAR(20)     NOT NULL,
costo           DECIMAL(12,2)   NOT NULL,
fechaInicio     DATE            NOT NULL,
fechaExpiracion DATE            NOT NULL,
valorAsegurado  DECIMAL(15,2)   NOT NULL,
idCompaniaFK    INT             NOT NULL,
idAutomovilFK   INT             NOT NULL,
CONSTRAINT FKCompaniaSeguros
FOREIGN KEY (idCompaniaFK)
REFERENCES compania(idCompania)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT FKAutomovilSeguros
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil(idAutomovil)
ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE detalleAccidente (
idDetalle          INT         AUTO_INCREMENT PRIMARY KEY,
tipoParticipacion  VARCHAR(50) NOT NULL,
idAutomovilFK      INT         NOT NULL,
idAccidenteFK      INT         NOT NULL,
CONSTRAINT FKAutomovilDetalle
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil(idAutomovil)
ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT FKAccidenteDetalle
FOREIGN KEY (idAccidenteFK)
REFERENCES accidente(idAccidente)
ON DELETE RESTRICT ON UPDATE CASCADE
);

##Cambio nombre de tabla
ALTER TABLE seguros
RENAME TO polizas;

##Elimnar campo de tabla
ALTER TABLE compania
DROP COLUMN fechaFundacion;

#Fk
SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'polizas'
AND constraint_type = 'FOREIGN KEY';

#Eliminar FK
ALTER TABLE polizas
DROP FOREIGN KEY FKCompaniaSeguros;

DESCRIBE compania;
DESCRIBE automovil;
DESCRIBE polizas;
DESCRIBE accidente;
DESCRIBE detalleAccidente;