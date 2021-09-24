--------------- SQL ---------------

CREATE OR REPLACE FUNCTION plani.ft_obligacion_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Planillas
 FUNCION: 		plani.ft_obligacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'plani.tobligacion'
 AUTOR: 		 (jrivera)
 FECHA:	        14-07-2014 20:30:19
 COMENTARIOS:	
***************************************************************************

 
 
    HISTORIAL DE MODIFICACIONES:
       
 ISSUE            FECHA:              AUTOR                 DESCRIPCION
   
 #0               14/07/2014       JRIVERA KPLIAN       creacion
 #38              10/09/2019       RAC KPLIAN           metodo para verificar si existen cbte de pago para la planilla	
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_obligacion	        integer;
	v_obligacion			record;
    v_existe_cbte_pago      varchar; --#38
			    
BEGIN

    v_nombre_funcion = 'plani.ft_obligacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'PLA_OBLI_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		jrivera	
 	#FECHA:		14-07-2014 20:30:19
	***********************************/

	if(p_transaccion='PLA_OBLI_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into plani.tobligacion(
			id_auxiliar,
			id_cuenta,
			id_planilla,
			id_tipo_obligacion,
			monto_obligacion,
			acreedor,
			estado_reg,
			tipo_pago,
			descripcion,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_ai,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.id_auxiliar,
			v_parametros.id_cuenta,
			v_parametros.id_planilla,
			v_parametros.id_tipo_obligacion,
			v_parametros.monto_obligacion,
			v_parametros.acreedor,
			'activo',
			v_parametros.tipo_pago,
			v_parametros.descripcion,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			v_parametros._id_usuario_ai,
			null,
			null
							
			
			
			)RETURNING id_obligacion into v_id_obligacion;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Obligaciones almacenado(a) con exito (id_obligacion'||v_id_obligacion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_obligacion',v_id_obligacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'PLA_OBLI_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		jrivera	
 	#FECHA:		14-07-2014 20:30:19
	***********************************/

	elsif(p_transaccion='PLA_OBLI_MOD')then

		begin
			select *
			into v_obligacion
			from plani.tobligacion
			where id_obligacion = v_parametros.id_obligacion;
			
			if (v_obligacion.tipo_pago = 'transferencia_empleados' and v_parametros.tipo_pago != 'transferencia_empleados') then
				raise exception 'No es posible cambiar el tipo de pago para esta obligacion';
			end if;
			
			if (v_obligacion.tipo_pago != 'transferencia_empleados' and v_parametros.tipo_pago = 'transferencia_empleados') then
				raise exception 'No es posible asignar el tipo de pago transferencia_empleados a esta obligacion';
			end if;  
			
			
			--Sentencia de la modificacion
			update plani.tobligacion set			
			acreedor = v_parametros.acreedor,
			tipo_pago = v_parametros.tipo_pago,
			descripcion = v_parametros.descripcion,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_obligacion=v_parametros.id_obligacion;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Obligaciones modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_obligacion',v_parametros.id_obligacion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'PLA_OBLI_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		jrivera	
 	#FECHA:		14-07-2014 20:30:19
	***********************************/

	elsif(p_transaccion='PLA_OBLI_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from plani.tobligacion
            where id_obligacion=v_parametros.id_obligacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Obligaciones eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_obligacion',v_parametros.id_obligacion::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
        
    /*********************************    
 	#TRANSACCION:  'PLA_EXCBTE_PAG'
 	#DESCRIPCION:	Pregunta Existe algun cbte de pago para la planilla
 	#AUTOR:		rarteaga	
 	#FECHA:		18-09-2019
	***********************************/

	elsif(p_transaccion='PLA_EXCBTE_PAG')then  --#38 

		begin
			
            IF EXISTS(
                      SELECT 1
                      FROM plani.tobligacion ob
                      INNER JOIN plani.tobligacion_agrupador oa ON oa.id_obligacion_agrupador = ob.id_obligacion_agrupador
                      WHERE ob.id_planilla = v_parametros.id_planilla
                      AND (   ob.id_int_comprobante IS NOT NULL  
                           OR oa.id_int_comprobante IS NOT NULL)) THEN
                 
                  v_existe_cbte_pago = 'si';       
                           
            ELSE
                  v_existe_cbte_pago = 'no';
            
            END IF;
            
        
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','verificacion de cbte de pago en planilla'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_planilla',v_parametros.id_planilla::varchar); 
            v_resp = pxp.f_agrega_clave(v_resp,'existe_cbte_pago',v_existe_cbte_pago);
              
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