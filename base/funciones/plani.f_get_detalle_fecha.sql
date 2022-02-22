CREATE OR REPLACE FUNCTION plani.f_get_detalle_fecha (
  p_fecha date,
  p_operacion varchar
)
RETURNS varchar AS
$body$
  /**************************************************************************
   PLANI
  ***************************************************************************
   SCRIPT:
   COMENTARIOS:
   AUTOR: Franklin Espinoza (BoA)
   DESCRIP: Funcion que devuelve informacion sobre una fecha especifica cantidad dias, si es primer dia, si es ultimo dia
   Fecha: 11/09/2019

  */
DECLARE

    v_nombre_funcion	varchar;
    v_resp				varchar;
	  v_detalle			varchar;
BEGIN
	v_nombre_funcion = 'plani.f_get_detalle_fecha';

	if p_operacion = 'days' then
    	--v_detalle = DATE_PART('days', DATE_TRUNC('month', p_fecha) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)::varchar;
        if date_part('month', p_fecha) != 2 then
    		v_detalle = DATE_PART('days', DATE_TRUNC('month', p_fecha) + '1 MONTH'::INTERVAL - '1 DAY'::INTERVAL)::varchar;
        else
        	v_detalle = 30;
        end if;
    elsif p_operacion = 'first' then
    	if date_trunc('month', p_fecha) = p_fecha then
        	v_detalle = 'true';
        else
        	v_detalle = 'false';
        end if;
    elsif p_operacion = 'last' then
    	if date_trunc('month',p_fecha) + interval '1 month' - interval '1 day' = p_fecha then
			v_detalle = 'true';
        else
        	v_detalle = 'false';
        end if;
    end if;

	return v_detalle;
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

ALTER FUNCTION plani.f_get_detalle_fecha (p_fecha date, p_operacion varchar)
  OWNER TO postgres;