--------------- SQL ---------------

CREATE OR REPLACE FUNCTION plani.f_conta_eliminacion_comprobante_obligacion (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/*

Autor:     RAC KPLIANF
Fecha:    20/05/2019
Descripcion  solo rompe la relacion de FK para poder eliminar el cbte


    HISTORIAL DE MODIFICACIONES:
       
 ISSUE            FECHA:              AUTOR                 DESCRIPCION
   
 #7 ETR           20/05/2019        RAC KPLIAN       eliminacion de coprobantes de obligaciones de pago para planilla
 #38 ETR          10/09/2019        RAC KPLIAN       considerar si el cbte es independiente del flujo WF de planilla  

*/


DECLARE
  
	v_nombre_funcion   	       text;
	v_resp				       varchar;
    v_registros 		       record;
    v_plani_cbte_independiente varchar;--#38 
    
    
    
BEGIN

	v_nombre_funcion = 'plani.f_conta_eliminacion_comprobante_obligacion';    
     --#38 recupera configuracion de cbte independite SI/NO
    v_plani_cbte_independiente = pxp.f_get_variable_global('plani_cbte_independiente');
    IF v_plani_cbte_independiente = 'NO' THEN   --#38 si la generacion de cbte no es independiente del flujo de planilla, entonces cambiamos el estado wf de la planilla
     
       -- con el id_comprobante identificar el plan de pago
       select 
           o.*
       into
           v_registros
       from  plani.tobligacion o      
       where  o.id_int_comprobante = p_id_int_comprobante; 
      
       IF v_registros IS NULL THEN
          raise exception 'El cbte id = %, no tiene ninguna obligacion relacionada ',p_id_int_comprobante;
       END IF;
      
       UPDATE plani.tobligacion o SET
         obs_cbte = COALESCE(obs_cbte,'')||'-  Eliminado manualmente el cbte id '||p_id_int_comprobante,
         id_int_comprobante = NULL
       WHERE o.id_obligacion = v_registros.id_obligacion;
       
   ELSE
   
       UPDATE plani.tobligacion o  SET
           obs_cbte = COALESCE(obs_cbte,'')||' - Eliminado manualmente el cbte id '||p_id_int_comprobante,
           id_int_comprobante = NULL
       WHERE o.id_int_comprobante = p_id_int_comprobante;
   
   END IF;  
     
               
             
RETURN  TRUE;

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