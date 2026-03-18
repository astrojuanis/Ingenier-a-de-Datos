/*
Autor: Juanita Castrillón
*/
CREATE DATABASE IF NOT EXISTS companiaseguros;
USE companiaseguros;
DROP TABLE IF EXISTS detalleAccidente;
DROP TABLE IF EXISTS seguros;
DROP TABLE IF EXISTS polizas; 
DROP TABLE IF EXISTS accidente;
DROP TABLE IF EXISTS automovil;
DROP TABLE IF EXISTS compania;

CREATE TABLE compania (
  idCompania        INT          AUTO_INCREMENT PRIMARY KEY,
  nit               VARCHAR(20)  NOT NULL UNIQUE,
  nombreCompania    VARCHAR(50)  NOT NULL,
  fechaFundacion    DATE         NULL,
  representanteLegal VARCHAR(100) NOT NULL
);

CREATE TABLE automovil (
  idAutomovil    INT         AUTO_INCREMENT PRIMARY KEY,
  placa          VARCHAR(10) NOT NULL UNIQUE,
  marca          VARCHAR(50) NOT NULL,
  modelo         VARCHAR(50) NOT NULL,
  tipo           VARCHAR(50) NOT NULL,
  anoFabricacion YEAR        NOT NULL,
  serialChasis   VARCHAR(50) NOT NULL UNIQUE,
  pasajeros      INT         NOT NULL,
  cilindraje     INT         NOT NULL
);

CREATE TABLE seguros (
  idSeguro       INT            AUTO_INCREMENT PRIMARY KEY,
  numPoliza      VARCHAR(30)    NOT NULL UNIQUE,
  estado         VARCHAR(20)    NOT NULL,
  costo          DECIMAL(12,2)  NOT NULL,
  fechaInicio    DATE           NOT NULL,
  fechaExpiracion DATE          NOT NULL,
  valorAsegurado DECIMAL(15,2)  NOT NULL,
  idCompaniaFK   INT            NOT NULL,
  idAutomovilFK  INT            NOT NULL,
  FOREIGN KEY (idCompaniaFK)  REFERENCES compania(idCompania),
  FOREIGN KEY (idAutomovilFK) REFERENCES automovil(idAutomovil)
);

CREATE TABLE accidente (
  idAccidente    INT         AUTO_INCREMENT PRIMARY KEY,
  fatalidades    INT         NOT NULL,
  heridos        INT         NOT NULL,
  lugar          VARCHAR(100) NOT NULL,
  fechaAccidente DATE        NOT NULL,
  descripcion    TEXT        NULL
);

CREATE TABLE detalleAccidente (
  idDetalle          INT         AUTO_INCREMENT PRIMARY KEY,
  tipoParticipacion  VARCHAR(50) NOT NULL,
  idAutomovilFK      INT         NOT NULL,
  idAccidenteFK      INT         NOT NULL,
  FOREIGN KEY (idAutomovilFK) REFERENCES automovil(idAutomovil),
  FOREIGN KEY (idAccidenteFK) REFERENCES accidente(idAccidente)
);

##relaciones op1
alter table seguros
## Crea la relación entre dos tablas 
add constraint FKCompaniaSeguros
foreign key(idCompaniaFK)
references compania(idCompania);

##Agregar un campo nuevo 
alter table compania add direccionCompania  varchar(50) null;

##Cambiar nombre de tabla
alter table seguros
rename to polizas;

## Eliminar campo de una tabla 
alter table compania
drop column fechaFundacion;

##Borrar una llave foranea
SELECT constraint_name 
FROM information_schema.table_constraints
WHERE table_name = 'polizas' 
AND constraint_type = 'FOREIGN KEY';

ALTER TABLE polizas
DROP FOREIGN KEY FKCompaniaSeguros;

SELECT constraint_name 
FROM information_schema.table_constraints
WHERE table_name = 'polizas'
AND constraint_type = 'FOREIGN KEY';

