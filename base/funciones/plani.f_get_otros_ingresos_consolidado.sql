CREATE OR REPLACE FUNCTION plani.f_get_otros_ingresos_consolidado (
  p_id_funcionario integer,
  p_id_periodo integer,
  p_id_gestion integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Planillas
 FUNCION: 		plani.f_get_otros_ingresos_consolidado
 DESCRIPCION:   Funcion que retorna el json de otros ingresos
 AUTOR: 		Franklin Espinonza Alvarez
 FECHA:	        19-09-2019 15:45:34
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
	v_ingresos				varchar = '[';
	v_monto					numeric = 0;

    v_periodo				integer;
    v_gestion 				integer;
BEGIN

    v_nombre_funcion = 'plani.f_get_otros_ingresos_consolidado';

    select tp.periodo
    into v_periodo
    from param.tperiodo tp
    where tp.id_periodo = p_id_periodo;

    select tg.gestion
    into v_gestion
    from param.tgestion tg
    where tg.id_gestion = p_id_gestion;



    select coalesce(sum(toi.monto),0)
    into v_monto
    from plani.totros_ingresos toi
    where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente = 'Refrigerios' and toi.periodo = v_periodo and toi.gestion = v_gestion;

    v_ingresos = v_ingresos ||'{"refrigerio":'||v_monto||',';

    select coalesce(sum(toi.monto),0)
    into v_monto
    from plani.totros_ingresos toi
    where toi.id_funcionario = p_id_funcionario and toi.sistema_fuente like 'Viatico%' and toi.periodo = v_periodo and toi.gestion = v_gestion;

    v_ingresos = v_ingresos ||'"viatico":'||v_monto||',';

    select coalesce(sum(tcv.valor),0)
    into v_monto
    from plani.tplanilla tp
    inner join plani.ttipo_planilla ttp on ttp.id_tipo_planilla = tp.id_tipo_planilla
    inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla
    inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = 'PRIMA'
    where ttp.codigo = 'PLAPRI' and tp.id_gestion = p_id_gestion - 1 and tfp.id_funcionario = p_id_funcionario and tp.estado != 'calculo_columnas';

    v_ingresos = v_ingresos ||'"prima":'||v_monto||',';

    v_monto = 0;
    /*select coalesce(sum(thp.pago_variable),0)
    into v_monto
    from oip.thoras_piloto thp
    where thp.id_funcionario = p_id_funcionario and thp.mes = p_id_periodo;*/

    v_ingresos = v_ingresos ||'"horas_vuelo":'||v_monto||'}]';

    return v_ingresos;
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