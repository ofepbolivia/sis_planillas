CREATE OR REPLACE FUNCTION plani.f_calcular_dias_para_prorrateo (
  p_fecha_ini date,
  p_fecha_per_ini date,
  p_fecha_per_fin date,
  p_id_uo_funcionario integer,
  p_id_funcionario integer
)
RETURNS numeric AS
$body$
DECLARE

    v_resp	            varchar;
  	v_nombre_funcion    text;
  	v_mensaje_error     text;
    v_resultado			numeric;

    v_horas_normales	numeric = 240;
    v_record			record;
    v_fecha_inicio		date;

BEGIN
	v_nombre_funcion = 'plani.f_calcular_dias_para_prorrateo';
		v_fecha_inicio = plani.f_get_fecha_primer_contrato_empleado(p_id_uo_funcionario, p_id_funcionario, p_fecha_ini);
        v_fecha_inicio = date(date_part('day', v_fecha_inicio)||'/'||date_part('month', v_fecha_inicio)||'/'||date_part('year', p_fecha_per_ini));
        --raise 'v_fecha_inicio: %, %, %', v_fecha_inicio,  p_fecha_per_ini,  p_fecha_per_fin;

        if v_fecha_inicio = p_fecha_per_ini then
			v_horas_normales = 240;
        else
          if v_fecha_inicio between p_fecha_per_ini and p_fecha_per_fin then
            if  v_fecha_inicio > p_fecha_per_ini then
              v_horas_normales = 240 - ((date_part('day', v_fecha_inicio) - date_part('day', p_fecha_per_ini))*8);
            end if;
          else
            if  v_fecha_inicio > p_fecha_per_ini and date_part('month', v_fecha_inicio) = date_part('month', p_fecha_per_ini) then
              v_horas_normales = 240 - ((date_part('day', v_fecha_inicio) - date_part('day', p_fecha_per_ini))*8);
            end if;
          end if;
        end if;

    return v_horas_normales/8;
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
STABLE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;