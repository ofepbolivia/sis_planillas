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
  	v_fecha_ini				date;
	v_fecha_fin				date;

	v_id_gestion			integer;
  	v_id_periodo			integer;

BEGIN

    v_nombre_funcion = 'plani.f_get_otro_ingreso';



	  if p_bandera = 'ref' then

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Refrigerios' and toi.gestion = p_gestion and toi.periodo = p_periodo;

    elsif p_bandera = 'sueldo_neto' then

      select tg.id_gestion, tp.id_periodo
      into v_id_gestion, v_id_periodo
      from param.tperiodo tp
    	inner join param.tgestion tg on tg.id_gestion = tp.id_gestion
      where tp.periodo = p_periodo and tg.gestion = p_gestion;

    	select coalesce(cot.valor-afp.valor,0)
    	into v_monto
    	from plani.tplanilla tp
      inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla
      inner join plani.tcolumna_valor cot on cot.id_funcionario_planilla = tfp.id_funcionario_planilla and cot.codigo_columna = 'COTIZABLE'
      inner join plani.tcolumna_valor afp on afp.id_funcionario_planilla = tfp.id_funcionario_planilla and afp.codigo_columna = 'AFP_LAB'
    	where tp.id_gestion = v_id_gestion and tp.id_periodo = v_id_periodo and tfp.id_funcionario = p_id_funcionario;


    elsif p_bandera = 'refrigerio' then

      select tp.fecha_ini, tp.fecha_fin
      into v_fecha_ini, v_fecha_fin
      from param.tperiodo tp
    	inner join param.tgestion tg on tg.id_gestion = tp.id_gestion
      where tp.periodo = p_periodo and tg.gestion = p_gestion;

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Refrigerios'
      and toi.gestion = p_gestion and (toi.fecha_pago between v_fecha_ini and v_fecha_fin);

    elsif p_bandera = 'viatico' then

        select tp.fecha_ini, tp.fecha_fin
        into v_fecha_ini, v_fecha_fin
        from param.tperiodo tp
    	inner join param.tgestion tg on tg.id_gestion = tp.id_gestion
        where tp.periodo = p_periodo and tg.gestion = p_gestion;

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente like '%Viatico%'
      and toi.gestion = p_gestion and (toi.fecha_pago between v_fecha_ini and v_fecha_fin);

    elsif p_bandera = 'ref_fin' then

    	select tp.fecha_ini, tp.fecha_fin
      	into v_fecha_ini, v_fecha_fin
      	from param.tperiodo tp
    	inner join param.tgestion tg on tg.id_gestion = tp.id_gestion
      	where tp.periodo = p_periodo and tg.gestion = p_gestion;

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Refrigerios' and toi.gestion = p_gestion and toi.periodo = p_periodo;
        --(toi.fecha_pago between v_fecha_ini and v_fecha_fin);
    elsif p_bandera = 'adm_ope' then

		select tp.fecha_ini, tp.fecha_fin
    	into v_fecha_ini, v_fecha_fin
      	from param.tperiodo tp
    	inner join param.tgestion tg on tg.id_gestion = tp.id_gestion
      	where tp.periodo = p_periodo and tg.gestion = p_gestion;

    	select coalesce(sum(toi.monto),0)
    	into v_monto
    	from plani.totros_ingresos toi
    	where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = '%Viatico%' and toi.gestion = p_gestion and toi.periodo = p_periodo;

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
    elsif p_bandera = 'ref_sep' then
		select coalesce(toi.monto,0)
        into v_monto
        from plani.totros_ingresos toi
        where toi.id_funcionario = p_id_funcionario and toi.periodo = 10 and toi.sistema_fuente = 'Refrigerios' and
        toi.fecha_pago between '01/09/2020'::date and '30/09/2020' and toi.gestion = 2020;
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

ALTER FUNCTION plani.f_get_otro_ingreso (p_id_funcionario integer, p_gestion integer, p_periodo integer, p_bandera varchar)
  OWNER TO postgres;