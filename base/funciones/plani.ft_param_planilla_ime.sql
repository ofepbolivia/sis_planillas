CREATE OR REPLACE FUNCTION "plani"."ft_param_planilla_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Planillas
 FUNCION: 		plani.ft_param_planilla_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'plani.tparam_planilla'
 AUTOR: 		 (franklin.espinoza)
 FECHA:	        26-08-2019 20:06:59
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
#ISSUE				FECHA				AUTOR				DESCRIPCION
 #0				26-08-2019 20:06:59								Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'plani.tparam_planilla'	
 #
 ***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_param_planilla	integer;
			    
BEGIN

    v_nombre_funcion = 'plani.ft_param_planilla_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'PLA_PARAMPLA_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		franklin.espinoza	
 	#FECHA:		26-08-2019 20:06:59
	***********************************/

	if(p_transaccion='PLA_PARAMPLA_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into plani.tparam_planilla(
			estado_reg,
			id_tipo_planilla,
			porcentaje_calculo,
			valor_promedio,
			porcentaje_menor_promedio,
			porcentaje_mayor_promedio,
			id_usuario_reg,
			fecha_reg,
			id_usuario_ai,
			usuario_ai,
			id_usuario_mod,
			fecha_mod
          	) values(
			'activo',
			v_parametros.id_tipo_planilla,
			v_parametros.porcentaje_calculo,
			v_parametros.valor_promedio,
			v_parametros.porcentaje_menor_promedio,
			v_parametros.porcentaje_mayor_promedio,
			p_id_usuario,
			now(),
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			null,
			null
							
			
			
			)RETURNING id_param_planilla into v_id_param_planilla;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Parametros Planilla almacenado(a) con exito (id_param_planilla'||v_id_param_planilla||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_param_planilla',v_id_param_planilla::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'PLA_PARAMPLA_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		franklin.espinoza	
 	#FECHA:		26-08-2019 20:06:59
	***********************************/

	elsif(p_transaccion='PLA_PARAMPLA_MOD')then

		begin
			--Sentencia de la modificacion
			update plani.tparam_planilla set
			id_tipo_planilla = v_parametros.id_tipo_planilla,
			porcentaje_calculo = v_parametros.porcentaje_calculo,
			valor_promedio = v_parametros.valor_promedio,
			porcentaje_menor_promedio = v_parametros.porcentaje_menor_promedio,
			porcentaje_mayor_promedio = v_parametros.porcentaje_mayor_promedio,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_param_planilla=v_parametros.id_param_planilla;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Parametros Planilla modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_param_planilla',v_parametros.id_param_planilla::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'PLA_PARAMPLA_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		franklin.espinoza	
 	#FECHA:		26-08-2019 20:06:59
	***********************************/

	elsif(p_transaccion='PLA_PARAMPLA_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from plani.tparam_planilla
            where id_param_planilla=v_parametros.id_param_planilla;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Parametros Planilla eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_param_planilla',v_parametros.id_param_planilla::varchar);
              
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
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "plani"."ft_param_planilla_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
