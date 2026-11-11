
-- Devuelve el id del usuario de la petición, solo si está ACTIVO
CREATE FUNCTION usuario_actual() RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
	SELECT id FROM usuario
	WHERE id = NULLIF(current_setting('app.user_id', true), '')::uuid
	  AND estado = 'ACTIVO'
$$;

CREATE FUNCTION sucursal_de_area(p_area uuid) RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
	SELECT id_sucursal FROM area WHERE id = p_area
$$;

CREATE FUNCTION sucursal_actual() RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
	SELECT COALESCE(id_sucursal, sucursal_de_area(id_area))
	FROM usuario WHERE id = usuario_actual()
$$;

CREATE FUNCTION area_actual() RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
	SELECT id_area FROM usuario WHERE id = usuario_actual()
$$;

CREATE FUNCTION es_supervisor() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
	SELECT COALESCE((SELECT supervisor FROM usuario WHERE id = usuario_actual()), false)
$$;

REVOKE EXECUTE ON FUNCTION usuario_actual(), sucursal_de_area(uuid), sucursal_actual(),
                           area_actual(), es_supervisor() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION usuario_actual(), sucursal_de_area(uuid), sucursal_actual(),
                          area_actual(), es_supervisor() TO rol_empleado;

-- Activar RLS en todas las tablas y dar acceso total (sin borrar) al CEO
DO $$
DECLARE t text;
BEGIN
	FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
		EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
		EXECUTE format('CREATE POLICY ceo_todo ON %I FOR ALL TO rol_ceo USING (true) WITH CHECK (true)', t);
	END LOOP;
END $$;

-- Estructura: todos ven los roles y solo su sucursal y sus áreas
CREATE POLICY rol_lectura ON rol FOR SELECT TO rol_empleado USING (true);
CREATE POLICY sucursal_propia ON sucursal FOR SELECT TO rol_empleado
	USING (id = sucursal_actual());
CREATE POLICY area_sucursal ON area FOR SELECT TO rol_empleado
	USING (id_sucursal = sucursal_actual());

-- POLITICAS DE USUARIOS (ROLES)
-- cada quien se ve a sí mismo
CREATE POLICY usuario_propio ON usuario FOR SELECT TO rol_empleado
	USING (id = usuario_actual());

-- el supervisor ve a los de su área
CREATE POLICY usuario_area ON usuario FOR SELECT TO rol_empleado
	USING (es_supervisor() AND id_area = area_actual());

-- RRHH y gerente ven al personal de su sucursal (CEO y clientes no tienen sucursal)
CREATE POLICY usuario_sucursal ON usuario FOR SELECT TO rol_rrhh, rol_gerente
	USING (COALESCE(id_sucursal, sucursal_de_area(id_area)) = sucursal_actual());

-- ventas ve a todos los clientes
CREATE POLICY usuario_clientes_ventas ON usuario FOR SELECT TO rol_ventas
	USING (id_rol IN (SELECT id FROM rol WHERE nombre = 'CLIENTE'));

-- el gerente ve a los clientes con ventas en su sucursal (el RLS de venta ya filtra)
CREATE POLICY usuario_clientes_gerente ON usuario FOR SELECT TO rol_gerente
	USING (EXISTS (SELECT 1 FROM venta WHERE venta.id_cliente = usuario.id));

-- el supervisor cambia el estado de su equipo (no el suyo); la columna la limita el GRANT
CREATE POLICY usuario_estado_supervisor ON usuario FOR UPDATE TO rol_empleado
	USING (es_supervisor() AND id_area = area_actual() AND id <> usuario_actual())
	WITH CHECK (es_supervisor() AND id_area = area_actual());

-- 5. Ventas
CREATE POLICY venta_sucursal ON venta FOR SELECT TO rol_gerente, rol_ventas
	USING (id_sucursal = sucursal_actual());

-- hereda el filtro de venta: el EXISTS solo encuentra ventas visibles
CREATE POLICY detalles_venta_visibles ON detalles_venta FOR SELECT TO rol_gerente, rol_ventas
	USING (EXISTS (SELECT 1 FROM venta WHERE venta.id = detalles_venta.id_venta));

-- catálogo de servicios y paquetes (no pertenece a una sucursal)
CREATE POLICY servicio_catalogo ON servicio FOR SELECT TO rol_gerente, rol_ventas USING (true);
CREATE POLICY paquete_catalogo ON paquete FOR SELECT TO rol_gerente, rol_ventas USING (true);
CREATE POLICY contenido_paquete_catalogo ON contenido_paquete FOR SELECT TO rol_gerente, rol_ventas USING (true);

-- 6. Movimientos
CREATE POLICY movimiento_catalogo_lectura ON movimiento_catalogo FOR SELECT
	TO rol_gerente, rol_contaduria USING (true);

CREATE POLICY movimiento_sucursal ON movimiento_interno FOR SELECT
	TO rol_gerente, rol_contaduria
	USING (sucursal_de_area(id_area) = sucursal_actual());

-- contaduría edita solo de su sucursal (las columnas las limita el GRANT)
CREATE POLICY movimiento_editar_contaduria ON movimiento_interno FOR UPDATE TO rol_contaduria
	USING (sucursal_de_area(id_area) = sucursal_actual())
	WITH CHECK (sucursal_de_area(id_area) = sucursal_actual());
