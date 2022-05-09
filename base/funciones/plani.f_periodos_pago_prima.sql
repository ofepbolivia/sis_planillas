CREATE OR REPLACE FUNCTION plani.f_periodos_pago_prima (
  p_id_funcionario integer,
  p_id_gestion integer
)
RETURNS date [] AS
$body$
DECLARE
    v_registros				record;
    v_resp	            	varchar;
    v_nombre_funcion    	text;
    v_horas_normales		numeric;
    v_periodo_array			text[];
    v_periodo_array_aux 	integer[];
    v_periodo_total			integer = 0;
    v_periodo_aux			integer = 12;
    v_contador				integer;
	v_periodos				date [];
    v_gestion				integer;
BEGIN

    v_nombre_funcion = 'plani.f_periodos_pago_prima';

    select tg.gestion
    into v_gestion
    from param.tgestion tg
    where tg.id_gestion  = p_id_gestion;

	for v_registros in  select pe.periodo, fp.id_funcionario_planilla
                          from plani.tfuncionario_planilla fp
                          inner join plani.thoras_trabajadas ht on ht.id_funcionario_planilla = fp.id_funcionario_planilla
                          inner join orga.tfuncionario fun on fun.id_funcionario = fp.id_funcionario and fun.id_funcionario = p_id_funcionario
                          inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                          inner join param.tperiodo pe on pe.id_periodo = p.id_periodo
                          inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla and tp.codigo = 'PLASUE' and p.estado not in (
                            'registros_horas', 'registro_funcionarios', 'calculo_columnas', 'anulado') and p.id_gestion = p_id_gestion
                          group by fp.id_funcionario_planilla, pe.periodo
                          order by  pe.periodo desc loop

      select count(tht.id_funcionario_planilla), sum(tht.horas_normales)
      into  v_contador, v_horas_normales
      from plani.thoras_trabajadas tht
      where tht.id_funcionario_planilla = v_registros.id_funcionario_planilla;


      if v_registros.periodo = v_periodo_aux and v_horas_normales = 240 then
          v_periodo_total =  v_periodo_total + 1;
          v_periodo_aux = v_periodo_aux - 1;
          v_periodo_array[v_periodo_total] = ARRAY[v_registros.periodo, v_contador];
          v_periodos [v_periodo_total] = ('1/'||v_registros.periodo||'/'||v_gestion)::date;
          if v_periodo_total = 3 then
              exit;
          end if;
      else
          if v_horas_normales = 240 then
            v_periodo_total = 1;
            v_periodo_array[v_periodo_total] = ARRAY[v_registros.periodo, v_contador];
            v_periodos [v_periodo_total] = ('1/'||v_registros.periodo||'/'||v_gestion)::date;
            v_periodo_aux = v_registros.periodo - 1;
          end if;
          v_periodo_aux = v_registros.periodo - 1;
      end if;

    end loop;

    return v_periodos;
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