
-- ==== PERSONAL DE LA EMPRESA ====

-- Usuarios con rol, sucursal y área (gerentes, supervisor de area y empleados normales)
CREATE VIEW v_usuario_detalle WITH (security_invoker = true) AS
SELECT u.id, u.nombre, u.correo, u.telefono, u.salario, u.estado, u.supervisor,
       r.nombre AS rol,
       COALESCE(u.id_sucursal, a.id_sucursal) AS id_sucursal,
       s.nombre AS sucursal,
       u.id_area, a.nombre AS area
FROM usuario u
JOIN rol r ON r.id = u.id_rol
LEFT JOIN area a ON a.id = u.id_area
LEFT JOIN sucursal s ON s.id = COALESCE(u.id_sucursal, a.id_sucursal)
WHERE r.nombre <> 'CLIENTE';

-- Empleados por área
CREATE VIEW v_empleados_area WITH (security_invoker = true) AS
SELECT u.id, u.nombre, u.correo, u.telefono, u.estado, u.supervisor,
      u.id_area, a.nombre AS area,
      a.id_sucursal, s.nombre As sucursal
FROM usuario u
JOIN area a ON a.id = uu.id_area
JOIN sucursal s ON s.id = a.id_sucursal;


-- ==== PARA VENTAS DE LA EMPRESA ====

-- Renglones de una venta con su concepto y subtotal
CREATE VIEW v_detalle_venta WITH (security_invoker = true) AS
SELECT dv.id, dv.id_venta,
       COALESCE(s.nombre, p.nombre) AS concepto,
       CASE WHEN dv.id_servicio IS NOT NULL THEN 'SERVICIO' ELSE 'PAQUETE' END AS tipo,
       dv.cantidad, dv.precio,
       dv.cantidad * dv.precio AS subtotal
FROM detalles_venta dv
LEFT JOIN servicio s ON s.id = dv.id_servicio
LEFT JOIN paquete p ON p.id = dv.id_paquete;

-- Ventas con cliente, sucursal y total (también sirve para el historial de un cliente)
CREATE VIEW v_venta_resumen WITH (security_invoker = true) AS
SELECT v.id, v.created_at, v.estado,
       v.id_sucursal, s.nombre AS sucursal,
       v.id_cliente, c.nombre AS cliente,
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




-- Ventas por sucursal y estado (gerente y CEO)
CREATE VIEW v_ventas_sucursal WITH (security_invoker = true) AS
SELECT id_sucursal, sucursal, estado,
       COUNT(*) AS num_ventas,
       SUM(total) AS monto
FROM v_venta_resumen
GROUP BY id_sucursal, sucursal, estado;


 -- ==== PARA FINANZAS ====

-- Movimientos internos con su tipo (contaduría)
CREATE VIEW v_movimiento_detalle WITH (security_invoker = true) AS
SELECT mi.id, mi.created_at,
       a.id_sucursal, mi.id_area, a.nombre AS area,
       mc.nombre AS movimiento, mc.tipo,
       mi.costo, mi.motivo
FROM movimiento_interno mi
JOIN movimiento_catalogo mc ON mc.id = mi.id_movimiento
JOIN area a ON a.id = mi.id_area;

-- Gastos (COMPRA) e ingresos (VENTA) por área
CREATE VIEW v_movimientos_area WITH (security_invoker = true) AS
SELECT id_area, area, id_sucursal,
       COALESCE(SUM(costo) FILTER (WHERE tipo = 'COMPRA'), 0) AS gastos,
       COALESCE(SUM(costo) FILTER (WHERE tipo = 'VENTA'), 0) AS ingresos
FROM v_movimiento_detalle
GROUP BY id_area, area, id_sucursal;
