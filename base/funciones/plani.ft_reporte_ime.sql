CREATE OR REPLACE FUNCTION plani.ft_reporte_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Planillas
 FUNCION: 		plani.ft_reporte_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'plani.treporte'
 AUTOR: 		 (admin)
 FECHA:	        17-01-2014 22:07:28
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_reporte			integer;
    v_record				record;
	v_codigo_rc_iva			varchar;
    v_record_json			jsonb;
BEGIN

    v_nombre_funcion = 'plani.ft_reporte_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'PLA_REPO_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		17-01-2014 22:07:28
	***********************************/

	if(p_transaccion='PLA_REPO_INS')then

        begin
        	--Sentencia de la insercion
        	insert into plani.treporte(
			id_tipo_planilla,
			numerar,
			hoja_posicion,
			mostrar_nombre,
			mostrar_codigo_empleado,
			mostrar_doc_id,
			mostrar_codigo_cargo,
			agrupar_por,
			ordenar_por,
			estado_reg,
			titulo_reporte,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			fecha_mod,
			ancho_total,
			control_reporte,
			tipo_reporte
          	) values(
			v_parametros.id_tipo_planilla,
			v_parametros.numerar,
			v_parametros.hoja_posicion,
			v_parametros.mostrar_nombre,
			v_parametros.mostrar_codigo_empleado,
			v_parametros.mostrar_doc_id,
			v_parametros.mostrar_codigo_cargo,
			v_parametros.agrupar_por,
			v_parametros.ordenar_por,
			'activo',

			v_parametros.titulo_reporte,
			now(),
			p_id_usuario,
			null,
			null,
			plani.f_reporte_get_ancho_total_hoja(v_parametros.hoja_posicion),
			v_parametros.control_reporte,
			v_parametros.tipo_reporte

			)RETURNING id_reporte into v_id_reporte;

			v_resp = plani.f_reporte_calcular_ancho_utilizado(v_id_reporte);

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reportes de Planilla almacenado(a) con exito (id_reporte'||v_id_reporte||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reporte',v_id_reporte::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'PLA_REPO_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		17-01-2014 22:07:28
	***********************************/

	elsif(p_transaccion='PLA_REPO_MOD')then

		begin
			--Sentencia de la modificacion
			update plani.treporte set
			id_tipo_planilla = v_parametros.id_tipo_planilla,
			numerar = v_parametros.numerar,
			hoja_posicion = v_parametros.hoja_posicion,
			mostrar_nombre = v_parametros.mostrar_nombre,
			mostrar_codigo_empleado = v_parametros.mostrar_codigo_empleado,
			mostrar_doc_id = v_parametros.mostrar_doc_id,
			mostrar_codigo_cargo = v_parametros.mostrar_codigo_cargo,
			agrupar_por = v_parametros.agrupar_por,
			ordenar_por = v_parametros.ordenar_por,
			ancho_total = plani.f_reporte_get_ancho_total_hoja(v_parametros.hoja_posicion),
			titulo_reporte = v_parametros.titulo_reporte,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			control_reporte = v_parametros.control_reporte,
			tipo_reporte = v_parametros.tipo_reporte
			where id_reporte=v_parametros.id_reporte;
            v_resp = plani.f_reporte_calcular_ancho_utilizado(v_parametros.id_reporte);
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reportes de Planilla modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reporte',v_parametros.id_reporte::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'PLA_REPO_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		17-01-2014 22:07:28
	***********************************/

	elsif(p_transaccion='PLA_REPO_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from plani.treporte
            where id_reporte=v_parametros.id_reporte;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reportes de Planilla eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reporte',v_parametros.id_reporte::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;
    /*********************************
 	#TRANSACCION:  'PLA_REP_RCIVA_IME'
 	#DESCRIPCION:	cargado de codigos rc-iva faltantes
 	#AUTOR:		admin
 	#FECHA:		17-01-2014 22:07:28
	***********************************/

	elsif(p_transaccion='PLA_REP_RCIVA_IME')then

		begin
        	create temp table registros_rc_iva(
            	codigo varchar,
                nombre varchar,
                primer_apellido varchar,
                segundo_apellido varchar,
                numero_doc varchar,
                tipo_doc varchar
            ) on commit drop;

            for v_record_json in SELECT * FROM jsonb_array_elements(v_parametros.registros)  loop

                  insert into registros_rc_iva(
                    codigo,
                    nombre,
                    primer_apellido,
                    segundo_apellido,
                    numero_doc,
                    tipo_doc
                  )values (
                      (v_record_json->>'codigo')::varchar,
                      (v_record_json->>'nombre')::varchar,
                      (v_record_json->>'primer_apellido')::varchar,
                      (v_record_json->>'segundo_apellido')::varchar,
                      (v_record_json->>'numero_doc')::varchar,
                      (v_record_json->>'tipo_doc')::varchar
                  );
              end loop;
			--Sentencia de la eliminacion
			for v_record in select tf.ci, tf.id_persona
            			    from orga.vfuncionario tf
                            inner join orga.tuo_funcionario tuo on tuo.id_funcionario = tf.id_funcionario
                            where (tuo.fecha_finalizacion >= current_date or tuo.fecha_finalizacion is null) and tf.codigo_rc_iva is null loop
            	select tf.codigo
                into v_codigo_rc_iva
                from registros_rc_iva tf
                where tf.numero_doc = v_record.ci;

                if v_codigo_rc_iva is not null then
                    update orga.tfuncionario set
                    codigo_rc_iva =  v_codigo_rc_iva
                    where id_persona = v_record.id_persona;
                	--raise exception 'v_codigo_rc_iva: %, %', v_codigo_rc_iva,v_record.id_persona;
                end if;
            end loop;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reportes de Planilla eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'resultado','Exito');

            --Devuelve la respuesta
            return v_resp;

		end;
	else

    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

EXCEPTION

	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;