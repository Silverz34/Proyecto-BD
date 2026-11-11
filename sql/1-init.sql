CREATE TABLE rol (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(16) NOT NULL UNIQUE
);

CREATE TABLE sucursal (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	nombre VARCHAR(32) UNIQUE NOT NULL,
	ubicacion VARCHAR(32) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE area (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	id_sucursal UUID NOT NULL REFERENCES sucursal(id),
	nombre VARCHAR(64) NOT NULL UNIQUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	nombre VARCHAR(64) NOT NULL,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE (id_sucursal, nombre)
);

CREATE TABLE usuario (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	id_rol INTEGER NOT NULL REFERENCES rol(id),
	nombre VARCHAR(64) NOT NULL UNIQUE CHECK (TRIM(nombre) <> ''),
	correo VARCHAR(64) NOT NULL UNIQUE CHECK (correo ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
	telefono VARCHAR(10) NOT NULL CHECK (telefono ~ '^[0-9]{10}$'),
	contrasena VARCHAR(125) NOT NULL CHECK (TRIM(contrasena) <> '' AND LENGTH(contrasena) >= 8),
	salario NUMERIC CHECK (salario > 0.0),
	estado VARCHAR(8) NOT NULL DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'BAJA', 'PAUSADO')),
	id_sucursal UUID REFERENCES sucursal(id),
	id_area UUID REFERENCES area(id),
	supervisor BOOLEAN,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CHECK (
		(id_sucursal IS NULL AND id_area IS NULL AND supervisor IS NULL)
		OR (id_sucursal IS NOT NULL AND id_area IS NULL AND supervisor IS NULL)
		OR (id_sucursal IS NULL AND id_area IS NOT NULL AND supervisor IS NOT NULL)
	)
);

CREATE TABLE movimiento_catalogo (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(32) NOT NULL UNIQUE,
	tipo VARCHAR(6) NOT NULL CHECK (tipo in ('COMPRA', 'VENTA'))
);

CREATE TABLE movimiento_interno (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	id_area UUID NOT NULL REFERENCES area(id),
	id_movimiento INTEGER NOT NULL REFERENCES movimiento_catalogo(id),
	costo NUMERIC NOT NULL CHECK ( costo > 0.0 ),
	motivo VARCHAR(64)  NOT NULL CHECK (length(trim(motivo)) > 0),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE venta (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	id_cliente UUID NOT NULL REFERENCES usuario(id),
	id_sucursal UUID NOT NULL REFERENCES sucursal(id),
	estado VARCHAR(16) NOT NULL DEFAULT 'PENDIENTE' CHECK (estado IN ('CANCELADO', 'PENDIENTE', 'REALIZADO')),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE servicio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	nombre VARCHAR(64) NOT NULL UNIQUE,
	descripcion VARCHAR(128) NOT NULL,
	precio NUMERIC NOT NULL CHECK ( precio > 0.0 ),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE paquete (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	nombre VARCHAR(64) NOT NULL UNIQUE,
	descripcion VARCHAR(128) NOT NULL,
	precio NUMERIC NOT NULL CHECK ( precio > 0.0 ),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contenido_paquete (
	id_paquete UUID NOT NULL REFERENCES paquete(id) ON DELETE CASCADE,
	id_servicio UUID NOT NULL REFERENCES servicio(id),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (id_paquete, id_servicio)
);

CREATE TABLE detalles_venta (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	id_venta UUID NOT NULL REFERENCES venta(id) ON DELETE CASCADE,
	id_servicio UUID REFERENCES servicio(id),
	id_paquete UUID REFERENCES paquete(id),
	cantidad INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
	precio NUMERIC NOT NULL CHECK (precio > 0.0),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CHECK ((id_servicio IS NULL) <> (id_paquete IS NULL))
);
