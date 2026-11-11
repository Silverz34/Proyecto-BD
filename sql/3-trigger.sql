
-- AYUDA a la actualizacion en las fechas para el registro de AUDITORIAS

CREATE FUNCTION set_modified_at() RETURNS trigger AS $$
BEGIN
	NEW.modified_at = CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t text;
BEGIN
	FOR t IN SELECT table_name FROM information_schema.columns
	         WHERE table_schema = 'public' AND column_name = 'modified_at'
	LOOP
		EXECUTE format('CREATE TRIGGER trg_%I_modified BEFORE UPDATE ON %I
		                FOR EACH ROW EXECUTE FUNCTION set_modified_at()', t, t);
	END LOOP;
END $$;
