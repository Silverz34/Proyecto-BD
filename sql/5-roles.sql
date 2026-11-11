
-- ROLES DE NEGOCIO
CREATE ROLE rol_empleado NOLOGIN;
CREATE ROLE rol_ventas NOLOGIN IN ROLE rol_empleado;
CREATE ROLE rol_rrhh NOLOGIN IN ROLE rol_empleado;
CREATE ROLE rol_contaduria NOLOGIN IN ROLE rol_empleado;
CREATE ROLE rol_gerente NOLOGIN IN ROLE rol_empleado;
CREATE ROLE rol_ceo NOLOGIN IN ROLE rol_empleado;

-- usuario de conexion a la API:
-- Sin permisos propios, sirve para cambiar entre roles
CREATE ROLE api_user LOGIN NOINHERIT NOBYPASSRLS;
GRANT rol_empleado, rol_ventas, rol_rrhh, rol_contaduria, rol_gerente, rol_ceo TO api_user;

-- Cerrar el acceso x defecto de Supabase
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon, authenticated;

-- BASE: lo que todos pueden usar
GRANT USAGE ON SCHEMA public TO rol_empleado;
GRANT SELECT ON sucursal, area, rol TO rol_empleado;
GRANT SELECT (id, id_rol, nombre, correo, telefono, estado, id_sucursal, id_area, supervisor) ON usuario TO rol_empleado;
GRANT UPDATE (estado) ON usuario TO rol_empleado;
GRANT SELECT ON v_empleados_area, v_area TO rol_empleado;

-- rol_rrhh
GRANT SELECT (salario) ON usuario TO rol_rrhh;
GRANT SELECT ON v_usuario_detalle, v_sucursal TO rol_rrhh;
GRANT INSERT (id_rol, nombre, correo, telefono, salario, estado, id_area, supervisor)
  ON usuario TO rol_rrhh;
GRANT UPDATE (id_rol, nombre, correo, telefono, salario, estado, id_area, supervisor)
  ON usuario TO rol_rrhh;


--ventas o atencion al cliente
GRANT SELECT ON venta, detalles_venta, servicio, paquete, contenido_paquete TO rol_ventas;
GRANT SELECT ON v_sucursal, v_cliente, v_venta_resumen,v_detalle_venta, v_paquete_contenido TO rol_ventas;
GRANT INSERT (id_rol, nombre, correo, telefono) ON usuario TO rol_ventas;
GRANT UPDATE (nombre, correo, telefono, estado) ON usuario TO rol_ventas;
GRANT INSERT (id_cliente, id_sucursal) ON venta TO rol_ventas;
GRANT UPDATE (estado) ON venta TO rol_ventas, rol_gerente;
GRANT INSERT (id_venta, id_servicio, id_paquete, cantidad) ON detalles_venta TO rol_ventas;
GRANT UPDATE (cantidad) ON detalles_venta TO rol_ventas;


-- contaduria (solo edita costo y motivo)
GRANT SELECT ON movimiento_interno, movimiento_catalogo TO rol_contaduria;
GRANT UPDATE (costo, motivo) ON movimiento_interno TO rol_contaduria;
GRANT SELECT ON v_movimiento_detalle, v_movimientos_area TO rol_contaduria;
GRANT INSERT (id_area, id_movimiento, costo, motivo) ON movimiento_interno TO rol_contaduria;

--gerente
GRANT SELECT ON venta, detalles_venta, servicio, paquete, contenido_paquete, movimiento_interno, movimiento_catalogo TO rol_gerente;
GRANT SELECT ON v_sucursal, v_venta_resumen, v_ventas_sucursal, v_detalle_venta, v_paquete_contenido, v_movimiento_detalle, v_movimientos_area TO rol_gerente;

--Ceo
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO rol_ceo;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO rol_ceo;
