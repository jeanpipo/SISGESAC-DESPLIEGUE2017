
create table aud.t_auditoria (  id serial,
				usuario character varying,
				datos text,
				hora timestamp,
				tabla character varying,
				tipo character varying,
				subtipo character varying
			);

CREATE OR REPLACE FUNCTION aud.f_auditoria()
  RETURNS trigger AS
$BODY$
DECLARE
	data json;
BEGIN
	IF (TG_OP = 'INSERT') THEN
		data = row_to_json(NEW.*);
	ELSEIF (TG_OP = 'DELETE') THEN		
		data = row_to_json(OLD.*);		
		
	ELSEIF (TG_OP = 'UPDATE') THEN
		IF (TG_WHEN = 'BEFORE') THEN
			data = row_to_json(OLD.*);
		ELSE 
			data = row_to_json(NEW.*);
		END IF;
	END IF;
	
	INSERT INTO aud.t_auditoria (usuario,datos,hora,tabla,tipo,subtipo) 
		VALUES (user,data,current_timestamp,TG_TABLE_NAME,TG_OP,TG_WHEN);
	IF (TG_OP <> 'DELETE') THEN
		RETURN NEW;
	ELSE
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aud.f_auditoria()
  OWNER TO admin;


CREATE OR REPLACE FUNCTION aud.f_NoBorrarEditarAuditoria()
  RETURNS trigger AS
$BODY$
DECLARE
	
BEGIN
	return null;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aud.f_NoBorrarEditarAuditoria()
  OWNER TO admin;

--select aud.f_NoBorrarEditarAuditoria();

 CREATE OR REPLACE FUNCTION aud.f_crearTgAuditoria (p_esquema text) returns void
   as $BODY$
DECLARE
	r information_schema.tables;
BEGIN
	for r in SELECT * FROM information_schema.tables WHERE table_schema = p_esquema AND table_type='BASE TABLE' loop
		execute 'CREATE TRIGGER tg_auditoria_before BEFORE INSERT OR UPDATE OR DELETE ON ' || p_esquema || '.' || r.table_name ||
			' FOR EACH ROW EXECUTE PROCEDURE aud.f_auditoria();';

		execute 'CREATE TRIGGER tg_auditoria_after AFTER INSERT OR UPDATE OR DELETE ON ' || p_esquema || '.' || r.table_name ||
			' FOR EACH ROW EXECUTE PROCEDURE aud.f_auditoria();';
	end loop;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aud.f_crearTgAuditoria (p_esquema text)
  OWNER TO admin;

  select aud.f_crearTgAuditoria ('sis');

 CREATE OR REPLACE FUNCTION aud.f_crearTgTablaAuditoria () returns void
   as $BODY$
DECLARE
	
BEGIN	
	execute 'CREATE TRIGGER tg_auditoria_before BEFORE UPDATE OR DELETE ON aud.t_auditoria  FOR EACH ROW EXECUTE PROCEDURE aud.f_NoBorrarEditarAuditoria();';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aud.f_crearTgTablaAuditoria ()
  OWNER TO admin;

select aud.f_crearTgTablaAuditoria ();

 CREATE OR REPLACE FUNCTION aud.f_eliminarTg (p_esquema text) returns void
   as $BODY$
DECLARE
	r information_schema.tables;
BEGIN
	for r in SELECT * FROM information_schema.tables WHERE table_schema = p_esquema loop
		execute 'DROP TRIGGER tg_auditoria_before  ON ' || p_esquema || '.' || r.table_name || ';';
			

		execute 'DROP TRIGGER tg_auditoria_after  ON ' || p_esquema || '.' || r.table_name ||';';
			
	end loop;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aud.f_eliminarTg(p_esquema text)
  OWNER TO admin;


CREATE OR REPLACE FUNCTION sis.f_persona_act(p_codigo integer, p_cedula integer, p_rif text, p_nombre1 text, p_nombre2 text, p_apellido1 text, p_apellido2 text, p_sexo text, p_fec_nacimiento date, p_tip_sangre text, p_telefono1 text, p_telefono2 text, p_cor_personal text, p_cor_institucional text, p_direccion text, p_discapacidad text, p_nacionalidad text, p_hijos integer, p_est_civil text, p_observaciones text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE r_operacion integer := 0;
BEGIN

	UPDATE sis.t_persona SET cedula=p_cedula,			rif=p_rif,
				 nombre1=upper(p_nombre1),		nombre2=upper(p_nombre2),
				 apellido1=upper(p_apellido1),		apellido2=upper(p_apellido2),
				 sexo=p_sexo,				fec_nacimiento=p_fec_nacimiento,
				 tip_sangre=p_tip_sangre,		telefono1=p_telefono1,
				 telefono2=p_telefono2,			cor_personal=p_cor_personal,
				 cor_institucional=p_cor_institucional,	direccion=p_direccion,
				 discapacidad=p_discapacidad,		nacionalidad=p_nacionalidad,
				 hijos=p_hijos,				est_civil=p_est_civil,
				 observaciones=p_observaciones
			     WHERE codigo=p_codigo;

	IF found THEN
		r_operacion := 1;
	END IF;

  RETURN r_operacion;
END;
$$;


ALTER FUNCTION sis.f_persona_act(p_codigo integer, p_cedula integer, p_rif text, p_nombre1 text, p_nombre2 text, p_apellido1 text, p_apellido2 text, p_sexo text, p_fec_nacimiento date, p_tip_sangre text, p_telefono1 text, p_telefono2 text, p_cor_personal text, p_cor_institucional text, p_direccion text, p_discapacidad text, p_nacionalidad text, p_hijos integer, p_est_civil text, p_observaciones text) 
OWNER TO admin;

-- DROP SEQUENCE sis.s_persona;

CREATE SEQUENCE sis.s_persona
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 2432
  CACHE 1
  CYCLE;
ALTER TABLE sis.t_persona
  OWNER TO admin;
GRANT ALL ON SEQUENCE sis.s_persona TO admin;
GRANT ALL ON SEQUENCE sis.s_persona TO public;


CREATE OR REPLACE FUNCTION sis.f_persona_ins(p_cedula integer, p_rif text, p_nombre1 text, p_nombre2 text, p_apellido1 text, p_apellido2 text, p_sexo text, p_fec_nacimiento date, p_tip_sangre text, p_telefono1 text, p_telefono2 text, p_cor_personal text, p_cor_institucional text, p_direccion text, p_discapacidad text, p_nacionalidad text, p_hijos integer, p_est_civil text, p_observaciones text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE cod_persona integer := 0;
	exite integer := 0;
BEGIN
	--select coalesce(max(codigo),0) from sis.t_persona into cod_persona;
	SELECT nextval('sis.s_persona') into cod_persona;
	--cod_persona := cod_persona + 1;
	select codigo from sis.t_persona where cedula=p_cedula into exite;
	IF (exite is  null) THEN
		insert into sis.t_persona (codigo,		cedula,			rif,
					   nombre1,		nombre2,		apellido1,
					   apellido2,   	sexo,			fec_nacimiento,
					   tip_sangre,		telefono1,		telefono2,
					   cor_personal,	cor_institucional,	direccion,
					   discapacidad,	nacionalidad,		hijos,
					   est_civil,		observaciones
					)

				  values (cod_persona,		p_cedula,		p_rif,
					  upper(p_nombre1),	upper(p_nombre2),	upper(p_apellido1),
					  upper(p_apellido2),	p_sexo,			p_fec_nacimiento,
					  p_tip_sangre,		p_telefono1,		p_telefono2,
					  p_cor_personal,	p_cor_institucional,	p_direccion,
					  p_discapacidad, 	p_nacionalidad,		p_hijos,
					  p_est_civil,		p_observaciones
					);	 
		RETURN cod_persona;
	ELSE
		RETURN -1;
	END IF;
END;
$$;


ALTER FUNCTION sis.f_persona_ins(p_cedula integer, p_rif text, p_nombre1 text, p_nombre2 text, p_apellido1 text, p_apellido2 text, p_sexo text, p_fec_nacimiento date, p_tip_sangre text, p_telefono1 text, p_telefono2 text, p_cor_personal text, p_cor_institucional text, p_direccion text, p_discapacidad text, p_nacionalidad text, p_hijos integer, p_est_civil text, p_observaciones text) 
OWNER TO admin;


grant all on sequence aud.t_auditoria_id_seq to public;


CREATE OR REPLACE FUNCTION per.AgregarModuloAuditoria() returns void
   as $BODY$
DECLARE

BEGIN
	PERFORM per.f_modulo_agregar('Auditoria', 'Gestion de la auditoria sobre las modificaciones en todas las tablas del esquema sis');
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION per.AgregarModuloAuditoria()
  OWNER TO admin;

select per.AgregarModuloAuditoria();

CREATE OR REPLACE FUNCTION per.AgregarAccionesAuditoria() returns void
   as $BODY$
DECLARE
	codigoModulo integer;
BEGIN
	select codigo from per.t_modulo where nombre='Auditoria' into codigoModulo;
	PERFORM 'per.f_accion_ins(AuditoriaAgregar, agregar en la tabla auditoria, || codigoModulo || );';	
	PERFORM 'per.f_accion_ins(AuditoriaListar, Permite Consultar la tabla Auditoria,  || codigoModulo || );';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION per.AgregarAccionesAuditoria()
  OWNER TO admin;

select per.AgregarAccionesAuditoria();

 CREATE OR REPLACE FUNCTION aud.f_agregarPermisoATodosUsuarios () returns void
   as $BODY$
DECLARE
	r pg_user;
	i per.t_usuario;
	x integer;
	codInsertarAuditoria integer;
	codListarAuditoria integer;
BEGIN
	
	select codigo from per.t_accion where nombre='AuditoriaAgregar' into codInsertarAuditoria;
	select codigo from per.t_accion where nombre='AuditoriaListar' into codListarAuditoria;
	
	
	for r in SELECT usename FROM pg_user loop
		execute 'grant insert on table aud.t_auditoria to ' || r.usename ||';';
			
		execute 'grant select on table aud.t_auditoria to ' || r.usename ||';';			
	end loop;

	for i in SELECT codigo FROM per.t_usuario loop
		select max(cod_usuario) from per.t_acc_usuario where cod_accion in (codInsertarAuditoria,codListarAuditoria) and cod_usuario =i.codigo into x;
		if(x is not null) then
			perform per.f_usuario_usu_acc_insertar(i.codigo , codInsertarAuditoria);
			perform per.f_usuario_usu_acc_insertar(i.codigo ,  codListarAuditoria );	
		end if;		
	end loop;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION aud.f_agregarPermisoATodosUsuarios()
  OWNER TO admin;
  
  select aud.f_agregarPermisoATodosUsuarios();

CREATE OR REPLACE FUNCTION sis.f_extrarArchivo (p_ruta text, p_codigo int) returns void
   as $BODY$
DECLARE
	usuario text;
BEGIN
	  
	select usename from pg_user where usename = CURRENT_USER into usuario;
	
	if((SELECT rolsuper FROM pg_roles where rolname=CURRENT_USER)=true) then
		PERFORM lo_export(sis.t_archivo.archivo,p_ruta ) 
		FROM sis.t_archivo WHERE codigo= p_codigo;
	else 
		EXECUTE format('alter user '|| current_user||' with superuser');
		PERFORM lo_export(sis.t_archivo.archivo,p_ruta ) 
		FROM sis.t_archivo WHERE codigo= p_codigo;
		EXECUTE format('alter user '|| current_user||' with nosuperuser');
	end if;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sis.f_extrarArchivo (p_ruta text, p_codigo int)
  OWNER TO admin;

--pg_dump postgres > postgres_db.sql

-- DROP SEQUENCE sis.s_persona;

CREATE SEQUENCE sis.s_estudiante
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 2147483647
  START 2432
  CACHE 1
  CYCLE;
ALTER TABLE sis.t_estudiante
  OWNER TO admin;
GRANT ALL ON SEQUENCE sis.s_estudiante TO admin;
GRANT ALL ON SEQUENCE sis.s_estudiante TO public;


CREATE OR REPLACE FUNCTION sis.f_estudiante_ins(
    p_cod_persona integer,
    p_cod_instituto integer,
    p_cod_pensum integer,
    p_num_carnet text,
    p_num_expediente text,
    p_cod_rusnies text,
    p_cod_estado text,
    p_fec_inicio date,
    p_fec_fin date,
    p_condicion text,
    p_observaciones text)
  RETURNS integer AS
$BODY$
DECLARE cod_estudiante integer := 0;
BEGIN
	--select coalesce(max(codigo),0) from sis.t_estudiante into cod_estudiante;

	--cod_estudiante := cod_estudiante + 1;
	
	SELECT nextval('sis.s_estudiante') into cod_estudiante;

	insert into sis.t_estudiante (	codigo, 		cod_persona, 		cod_instituto,
					cod_pensum, 		num_carnet, 		num_expediente,
					cod_rusnies, 		cod_estado,		fec_inicio,
					fec_fin, 		condicion,		observaciones
				     )
			     values (	cod_estudiante, 	p_cod_persona, 		p_cod_instituto,
					p_cod_pensum, 		p_num_carnet,		p_num_expediente,
					p_cod_rusnies, 		p_cod_estado, 		p_fec_inicio,
					p_fec_fin, 		p_condicion, 		p_observaciones
				    );



  RETURN cod_estudiante;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sis.f_estudiante_ins(integer, integer, integer, text, text, text, text, date, date, text, text)
  OWNER TO admin;



  
