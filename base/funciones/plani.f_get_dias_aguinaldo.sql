CREATE OR REPLACE FUNCTION plani.f_get_dias_aguinaldo (
  p_id_funcionario integer,
  p_fecha_ini date,
  p_fecha_fin date
)
RETURNS integer AS
$body$
	/*Obtiene la cuenta bancaria de un empleado a la fecha indicada y devuelve el id_funcionario_cuenta_bancaria*/
DECLARE
    v_fecha_ini_emp	date;
    v_fecha_fin_emp	date;
    v_fecha_ini_mes	date;
    v_fecha_fin_mes	date;
    v_gestion 		numeric;
    v_meses			integer;
    v_dias			integer;
    v_nombre_funcion	varchar;
    v_resp				varchar;
    v_dias_en_mes		integer;

    --dias dias trabajados  - licencias
    v_dias_licencia		integer;
BEGIN
	v_nombre_funcion = 'plani.f_get_dias_aguinaldo';

    v_gestion = extract(YEAR FROM p_fecha_fin);
    --obteniendo la fecha_ini y fecha_fin del empleado para la gestion actual

    v_fecha_ini_emp = plani.f_get_fecha_primer_contrato_empleado(NULL,p_id_funcionario,p_fecha_ini);

    --si la fecha inicio es anterior a la gestion actual la fecha inicio sera 01-01-gestion
    if (v_fecha_ini_emp < ('01-01-' || v_gestion)::date) then
      v_fecha_ini_emp = ('01-01-' || v_gestion)::date;
    end if;

    v_fecha_fin_emp = p_fecha_fin;
    if ((extract(month from v_fecha_fin_emp)::integer - extract(month from v_fecha_ini_emp)::integer) = 0) then
    	return v_fecha_fin_emp - v_fecha_ini_emp;
    end if;
    --obtener la fecha de inicio del mes
    v_fecha_ini_mes = date_trunc('month',v_fecha_ini_emp);
    v_fecha_fin_mes = date_trunc('month',v_fecha_fin_emp) + interval '1 month' - interval '1 day';

    --si la fecha inicio no es inicio de mes tomo el mes siguiente
    if (v_fecha_ini_mes != v_fecha_ini_emp) then
      v_fecha_ini_mes =   date_trunc('month',v_fecha_ini_emp + interval '1 month');
    end if;

    --si la fecha fin no es fin de mes tomo el mes anterior
    if (v_fecha_fin_mes != v_fecha_fin_emp) then
      v_fecha_fin_mes =   date_trunc('month',v_fecha_fin_emp) - interval '1 day';
    end if;

    --obtengo la cantidad de meses
    v_meses = extract(month from v_fecha_fin_mes)::integer - extract(month from v_fecha_ini_mes)::integer + 1;

    --obtengo la cantidad de dias del mes inicial
    v_dias =  v_fecha_ini_mes	 - v_fecha_ini_emp;

     --solo por sigma
    v_dias_en_mes = DATE_PART('days',
        DATE_TRUNC('month', v_fecha_ini_emp)
        + '1 MONTH'::INTERVAL
        - '1 day'::interval
    )::integer;

    if (v_dias > 0 ) then
    	v_dias = v_dias + (30 - v_dias_en_mes);
    end if;


    --obtengo la cantidad de dias del mes final
    v_dias = v_dias + (v_fecha_fin_emp - v_fecha_fin_mes);

    v_dias = v_dias + (v_meses * 30);
    if (v_dias > 360) then
      v_dias = 360;
    end if;



    /*select extract( month from age(tli.hasta, tli.desde))*30 + extract( day from age(tli.hasta, tli.desde))
    into v_dias_licencia
    from plani.tlicencia tli
    where tli.id_funcionario = p_id_funcionario and date_part('year', tli.desde) = date_part('year', current_date);

    v_dias = v_dias - coalesce(v_dias_licencia,0);*/

    return v_dias;

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