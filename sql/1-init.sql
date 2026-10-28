CREATE TABLE rol (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(8)
);

CREATE TABLE sucursal (
	id UUID DEFAULT gen_random_uuid() UNIQUE,
	nombre VARCHAR(32) UNIQUE NOT NULL,
	ubicacion VARCHAR(32) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE area (
	id UUID DEFAULT gen_random_uuid() UNIQUE,
	id_sucursal UUID NOT NULL REFERENCES sucursal(id),
	nombre VARCHAR(64) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuario (
	id UUID DEFAULT gen_random_uuid() UNIQUE,
	id_rol INTEGER NOT NULL REFERENCES rol(id),
	nombre VARCHAR(32) UNIQUE NOT NULL,
	correo VARCHAR(64) UNIQUE NOT NULL,
	telefono VARCHAR(9),
	salario NUMERIC NOT NULL CHECK (salario > 0.0),
	estado VARCHAR(8) NOT NULL CHECK (estado in ('ACTIVO', 'INACTIVO')),
	id_sucursal UUID REFERENCES sucursal(id),
	id_area UUID REFERENCES area(id),
	supervisor BOOLEAN,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CHECK ((id_sucursal = NULL AND id_area != NULL) OR (id_area = NULL AND supervisor != NULL AND id_sucursal != NULL))
);

CREATE TABLE movimiento_catalogo (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(32) NOT NULL UNIQUE,
	tipo VARCHAR(6) NOT NULL CHECK (tipo in ('COMPRA', 'VENTA'))
);

CREATE TABLE movimiento_interno (
	id UUID DEFAULT gen_random_uuid(),
	id_area UUID NOT NULL REFERENCES area(id),
	id_movimiento INTEGER NOT NULL REFERENCES movimiento_catalogo(id),
	costo NUMERIC NOT NULL CHECK ( costo > 0.0 ),
	motivo VARCHAR(64) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE venta (
	id UUID UNIQUE DEFAULT gen_random_uuid(),
	id_cliente UUID NOT NULL REFERENCES usuario(id),
	id_sucursal UUID NOT NULL REFERENCES sucursal(id),
	estado VARCHAR(16) CHECK (estado in ('CANCELADO', 'PENDIENTE', 'REALIZADO')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE servicio (
	id UUID UNIQUE DEFAULT gen_random_uuid(),
	nombre VARCHAR(64) NOT NULL,
	descripcion VARCHAR(128) NOT NULL,
	precio NUMERIC NOT NULL CHECK ( precio > 0.0 ),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE paquete (
	id UUID UNIQUE DEFAULT gen_random_uuid(),
	nombre VARCHAR(64) NOT NULL,
	descripcion VARCHAR(128) NOT NULL,
	precio NUMERIC NOT NULL CHECK ( precio > 0.0 ),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contenido_paquete (
	id_paquete UUID UNIQUE NOT NULL REFERENCES paquete(id),
	id_servicio UUID UNIQUE NOT NULL REFERENCES servicio(id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE detalles_venta (
	id_venta UUID UNIQUE NOT NULL REFERENCES venta(id),
	id_servicio UUID UNIQUE NOT NULL REFERENCES servicio(id),
	id_paquete UUID UNIQUE NOT NULL REFERENCES paquete(id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	CHECK ((id_servicio = NULL AND id_paquete != NULL) OR (id_paquete = NULL AND id_servicio != NULL))
);
