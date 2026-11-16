
-- ==== PERSONAL DE LA EMPRESA ====

-- Usuarios con rol, sucursal y área (gerentes, supervisor de area y empleados normales)
CREATE VIEW v_usuario_detalle WITH (security_invoker = true) AS
SELECT u.id, u.nombre, u.correo, u.telefono, u.salario, u.estado, u.supervisor,
       r.nombre AS rol,
       s.nombre AS sucursal,
       a.nombre AS area
FROM usuario u
JOIN rol r ON r.id = u.id_rol
LEFT JOIN area a ON a.id = u.id_area
LEFT JOIN sucursal s ON s.id = COALESCE(u.id_sucursal, a.id_sucursal)
WHERE r.nombre <> 'CLIENTE';

-- Empleados por área
CREATE VIEW v_empleados_area WITH (security_invoker = true) AS
SELECT u.id, u.nombre, u.correo, u.telefono, u.estado, u.supervisor,
      a.nombre AS area,
      s.nombre As sucursal
FROM usuario u
JOIN area a ON a.id = u.id_area
JOIN sucursal s ON s.id = a.id_sucursal;

-- Areas con su sucursal y supervisor xd
CREATE VIEW v_area WITH (security_invoker = true) AS
SELECT a.id, a.nombre,
    a.id_sucursal, s.nombre AS sucursal,
    sup.id AS id_supervisor,
    sup.nombre AS supervisor
FROM area a
JOIN sucursal s ON s.id = a.id_sucursal
LEFT JOIN usuario sup ON sup.id_area = a.id AND sup.supervisor IS TRUE;

-- Sucursal con su gente
CREATE VIEW v_sucursal WITH (security_invoker= true) AS
SELECT s.id, s.nombre, s.ubicacion,
    g.id AS id_gerente, g.nombre AS gerente
FROM sucursal s
LEFT JOIN usuario g ON g.id_sucursal = s.id;


-- ==== PARA VENTAS DE LA EMPRESA ====

-- Renglones de una venta con su concepto, subtotal y descripcion (x sucursal).
CREATE VIEW v_detalle_venta WITH (security_invoker = true) AS
SELECT dv.id, dv.id_venta,
       COALESCE(s.nombre, p.nombre) AS concepto,
       COALESCE(s.descripcion, p.descripcion) AS descripcion,
       CASE WHEN dv.id_servicio IS NOT NULL THEN 'SERVICIO' ELSE 'PAQUETE' END AS tipo,
       dv.cantidad, dv.precio,
       dv.cantidad * dv.precio AS subtotal
FROM detalles_venta dv
JOIN venta v ON v.id = dv.id_venta
LEFT JOIN servicio s ON s.id = dv.id_servicio
LEFT JOIN paquete p ON p.id = dv.id_paquete;

-- Ventas con cliente, sucursal y total (también sirve para el historial de un cliente) GERENTE Y CEO
CREATE VIEW v_venta_resumen WITH (security_invoker = true) AS
SELECT v.id, v.created_at, v.estado,
       s.nombre AS sucursal,
       c.nombre AS cliente,
       COALESCE(SUM(dv.cantidad * dv.precio), 0) AS total
FROM venta v
JOIN sucursal s ON s.id = v.id_sucursal
JOIN usuario c ON c.id = v.id_cliente
LEFT JOIN detalles_venta dv ON dv.id_venta = v.id
GROUP BY v.id, s.nombre, c.nombre;

-- Para datos de contacto del cliente (asi no expone el salario)
CREATE VIEW v_cliente WITH(security_invoker = true) AS
SELECT u.id, u.nombre, u.correo, u.telefono, u.estado
FROM usuario u
JOIN rol r ON r.id = u.id_rol
WHERE r.nombre = 'CLIENTE';


 -- ==== PARA FINANZAS ====

-- Movimientos internos con su tipo (contaduría)
CREATE VIEW v_movimiento_detalle WITH (security_invoker = true) AS
SELECT mi.id, mi.created_at,
		s.nombre AS sucursal,
       a.nombre AS area,
       mc.nombre AS movimiento, mc.tipo,
       mi.costo, mi.motivo
FROM movimiento_interno mi
JOIN movimiento_catalogo mc ON mc.id = mi.id_movimiento
JOIN area a ON a.id = mi.id_area
JOIN sucursal s ON s.id = a.id_sucursal;

-- Gastos (COMPRA) e ingresos (VENTA) por área
CREATE VIEW v_movimientos_area WITH (security_invoker = true) AS
SELECT area, sucursal,
       COALESCE(SUM(costo) FILTER (WHERE tipo = 'COMPRA'), 0) AS gastos,
       COALESCE(SUM(costo) FILTER (WHERE tipo = 'VENTA'), 0) AS ingresos
FROM v_movimiento_detalle
GROUP BY area, sucursal;

-- SUCURSALES

-- Saca cada sucursal con el conteo de áreas que tiene
CREATE VIEW v_sucursal_area WITH (security_invoker = true) AS
SELECT
	s.id, s.nombre, s.ubicacion,
	COUNT(a.id) AS areas
FROM sucursal s
LEFT JOIN area a ON s.id = a.id_sucursal
GROUP BY s.id;

CREATE VIEW v_area_empleado WITH (security_invoker = true) AS
SELECT
	a.id, a.nombre,
	COUNT(u.id) FILTER (WHERE u.supervisor= false) AS empleados,
	MAX(u.nombre) FILTER (WHERE u.supervisor = true) AS supervisor
FROM area a
LEFT JOIN usuario u ON a.id = u.id_area
GROUP BY a.id;
