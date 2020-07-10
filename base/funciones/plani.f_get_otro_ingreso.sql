CREATE OR REPLACE FUNCTION plani.f_get_otro_ingreso (
  p_id_funcionario integer,
  p_gestion integer,
  p_periodo integer,
  p_bandera varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Planillas
 FUNCION: 		plani.f_get_otro_ingreso
 DESCRIPCION:   Funcion que retorna el json de otros ingresos
 AUTOR: 		Franklin Espinonza Alvarez
 FECHA:	        01-05-2020 15:45:34
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/

DECLARE

	v_parametros           	record;
	v_archivo				record;
	v_resp		            varchar;
	v_nombre_funcion        text;
    v_valores				record;

	v_monto					numeric = 0;
	v_c31					varchar='';

BEGIN

    v_nombre_funcion = 'plani.f_get_otro_ingreso';



	if p_bandera = 'ref' then

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Refrigerios' and toi.gestion = p_gestion and toi.periodo = p_periodo;

    elsif p_bandera = 'vad' then

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Viatico Administrativo' and toi.gestion = p_gestion and toi.periodo = p_periodo;

    elsif p_bandera = 'vam' then

        select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Viatico Administrativo AMP' and toi.gestion = p_gestion and toi.periodo = p_periodo;

    elsif p_bandera = 'vop' then

        select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Viatico Operativo' and toi.gestion = p_gestion and toi.periodo = p_periodo;

    elsif p_bandera = 'total' then

        select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.gestion = p_gestion and toi.periodo = p_periodo  and toi.sistema_fuente != 'Refrigerios' ;

    elsif p_bandera = 'c31' then

        select pxp.list(toi.nro_comprobante)
    	into v_c31
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.gestion = p_gestion and toi.periodo = p_periodo ;

    end if;

	if p_bandera = 'c31' then
    	return v_c31;
    else
    	return v_monto::varchar;
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
