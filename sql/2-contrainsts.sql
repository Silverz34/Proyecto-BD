-- indices para mejotar las busquedas
CREATE INDEX idx_area_sucursal ON area(id_sucursal);
CREATE INDEX idx_usuario_rol ON usuario(id_rol);
CREATE INDEX idx_usuario_area ON usuario(id_area);
CREATE INDEX idx_mov_interno_area ON movimiento_interno(id_area);
CREATE INDEX idx_venta_cliente ON venta(id_cliente);
CREATE INDEX idx_venta_sucursal ON venta(id_sucursal);
CREATE INDEX idx_detalles_venta ON detalles_venta(id_venta);



-- un solo gerente por sucursal
CREATE UNIQUE INDEX uq_gerente_sucursal ON usuario(id_sucursal) WHERE id_sucursal IS NOT NULL;
-- un solo supervisor por área
CREATE UNIQUE INDEX uq_supervisor_area ON usuario(id_area) WHERE supervisor IS TRUE;
