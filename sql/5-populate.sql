-- sacados del gemini, hasta creen que voy a llenar la base a mano
-- 1. Insertar roles (Con los nombres estrictamente solicitados)
INSERT INTO rol (id, nombre) VALUES 
(1, 'ADMINISTRADOR'),
(2, 'GERENTE'),
(3, 'SUPERVISOR'),
(4, 'CEO'),
(5, 'EMPLEADO'),
(6, 'CLIENTE');

-- Reiniciar la secuencia de rol si se llegan a insertar más en el futuro
SELECT setval(pg_get_serial_sequence('rol', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM rol;

-- 2. Insertar sucursales
INSERT INTO sucursal (id, nombre, ubicacion) VALUES 
('a0000000-0000-0000-0000-000000000001', 'Sucursal Norte', 'CDMX Norte'),
('a0000000-0000-0000-0000-000000000002', 'Sucursal Sur', 'CDMX Sur');

-- 3. Insertar áreas
INSERT INTO area (id, id_sucursal, nombre) VALUES 
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Atención a Clientes Norte'),
('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'Soporte Técnico Norte'),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000002', 'Atención a Clientes Sur');

-- 4. Insertar usuarios (Respetando el CHECK compuesto de sucursal, area y supervisor)
INSERT INTO usuario (id, id_rol, nombre, correo, telefono, contrasena, salario, estado, id_sucursal, id_area, supervisor) VALUES 
-- CEO (id_sucursal IS NULL, id_area IS NULL, supervisor IS NULL)
('c0000000-0000-0000-0000-000000000001', 4, 'Carlos Slim', 'ceo@empresa.com', '5512345678', 'password123', 150000.00, 'ACTIVO', NULL, NULL, NULL),

-- Administrador (id_sucursal IS NULL, id_area IS NULL, supervisor IS NULL)
('c0000000-0000-0000-0000-000000000002', 1, 'Ana Admin', 'admin@empresa.com', '5587654321', 'adminsecure89', 40000.00, 'ACTIVO', NULL, NULL, NULL),

-- Gerente de Sucursal Norte (id_sucursal IS NOT NULL, id_area IS NULL, supervisor IS NULL)
('c0000000-0000-0000-0000-000000000003', 2, 'Luis Gerente', 'gerente.norte@empresa.com', '5500112233', 'gerentepass', 35000.00, 'ACTIVO', 'a0000000-0000-0000-0000-000000000001', NULL, NULL),

-- Supervisor de Área (id_sucursal IS NULL, id_area IS NOT NULL, supervisor IS NOT NULL)
('c0000000-0000-0000-0000-000000000004', 3, 'María Supervisor', 'sup.atencion@empresa.com', '5544332211', 'superpass', 25000.00, 'ACTIVO', NULL, 'b0000000-0000-0000-0000-000000000001', TRUE),

-- Empleado regular (id_sucursal IS NULL, id_area IS NOT NULL, supervisor IS NOT NULL) -> supervisor en false indicando que NO supervisa
('c0000000-0000-0000-0000-000000000005', 5, 'Juan Empleado', 'juan.emp@empresa.com', '5599887766', 'empleadopass', 12000.00, 'ACTIVO', NULL, 'b0000000-0000-0000-0000-000000000001', FALSE),

-- Clientes (id_sucursal IS NULL, id_area IS NULL, supervisor IS NULL) - Sin salario
('c0000000-0000-0000-0000-000000000006', 6, 'Pedro Cliente', 'pedro.cliente@gmail.com', '5577665544', 'clientepass', NULL, 'ACTIVO', NULL, NULL, NULL),
('c0000000-0000-0000-0000-000000000007', 6, 'Laura Cliente', 'laura.c@hotmail.com', '5566554433', 'clientepass2', NULL, 'ACTIVO', NULL, NULL, NULL);

-- 5. Insertar movimientos del catálogo
INSERT INTO movimiento_catalogo (id, nombre, tipo) VALUES 
(1, 'Compra Papelería', 'COMPRA'),
(2, 'Pago de Licencias', 'COMPRA'),
(3, 'Venta Excedente', 'VENTA');

SELECT setval(pg_get_serial_sequence('movimiento_catalogo', 'id'), coalesce(max(id), 1), max(id) IS NOT null) FROM movimiento_catalogo;

-- 6. Insertar movimientos internos
INSERT INTO movimiento_interno (id, id_area, id_movimiento, costo, motivo) VALUES 
(gen_random_uuid(), 'b0000000-0000-0000-0000-000000000001', 1, 1500.50, 'Resurtido de hojas y tintas trimestral'),
(gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002', 2, 8500.00, 'Renovación de licencias de software de soporte');

-- 7. Insertar servicios
INSERT INTO servicio (id, nombre, descripcion, precio) VALUES 
('d0000000-0000-0000-0000-000000000001', 'Mantenimiento Básico', 'Limpieza y revisión general del equipo', 500.00),
('d0000000-0000-0000-0000-000000000002', 'Formateo y SO', 'Respaldo, formateo e instalación de Windows/Linux', 800.00),
('d0000000-0000-0000-0000-000000000003', 'Soporte Remoto 1H', 'Asistencia remota por una hora', 300.00);

-- 8. Insertar paquetes
INSERT INTO paquete (id, nombre, descripcion, precio) VALUES 
('e0000000-0000-0000-0000-000000000001', 'Paquete Puesta a Punto', 'Mantenimiento completo y reinstalación de sistema', 1100.00),
('e0000000-0000-0000-0000-000000000002', 'Paquete Empresa PYME', 'Mantenimiento + 2 horas de soporte remoto', 950.00);

-- 9. Insertar contenido_paquete
INSERT INTO contenido_paquete (id_paquete, id_servicio) VALUES 
('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001'), -- Mantenimiento Básico
('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002'), -- Formateo y SO
('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001'), -- Mantenimiento Básico
('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003'); -- Soporte Remoto 1H

-- 10. Insertar ventas
INSERT INTO venta (id, id_cliente, id_sucursal, estado) VALUES 
('f0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000001', 'REALIZADO'),
('f0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000002', 'PENDIENTE');

-- 11. Insertar detalles de la venta (Respetando el CHECK de (servicio NULL XOR paquete NULL))
INSERT INTO detalles_venta (id_venta, id_servicio, id_paquete, cantidad, precio) VALUES 
-- Venta 1: Compró 1 paquete 'Puesta a Punto'
('f0000000-0000-0000-0000-000000000001', NULL, 'e0000000-0000-0000-0000-000000000001', 1, 1100.00),
-- Venta 1: Compró también un servicio individual extra (Soporte remoto)
('f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000003', NULL, 1, 300.00),

-- Venta 2: Compró 2 servicios de mantenimiento básico
('f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', NULL, 2, 500.00);
