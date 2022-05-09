CREATE OR REPLACE FUNCTION plani.f_get_fecha_primer_contrato_empleado (
  p_id_uo_funcionario integer,
  p_id_funcionario integer,
  p_fecha_ini date
)
RETURNS date AS
$body$
DECLARE
  v_fecha_ini				date;
  v_id_uo_funcionario		integer;
  v_resp	            	varchar;
  v_nombre_funcion      	text;
  v_mensaje_error       	text;
  /***************** VAR CONTROL CONTADOR *****************/
  v_id_funcionario          integer;
  v_contador                integer = 0;
  v_funcionario             text;
  /***************** VAR CONTROL CONTADOR *****************/
BEGIN
  v_fecha_ini = null;
  v_nombre_funcion = 'plani.f_get_fecha_primer_contrato_empleado';
  --raise notice 'parametros [plani.f_get_fecha_primer_contrato_empleado] -> p_id_uo_funcionario %, p_id_funcionario %, p_fecha_ini %',p_id_uo_funcionario, p_id_funcionario, p_fecha_ini;
  select uofun.id_uo_funcionario, uofun.fecha_asignacion
  into	v_id_uo_funcionario, v_fecha_ini
  from orga.tuo_funcionario uofun
  inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
  inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
  where uofun.id_funcionario = p_id_funcionario and uofun.fecha_finalizacion = p_fecha_ini - interval '1 day'
  		and uofun.estado_reg != 'inactivo' and uofun.tipo = 'oficial' and tc.codigo in ('PLA','EVE');

  --raise notice 'f_get_fecha_primer_contrato_empleado -> p_id_funcionario: %',p_id_funcionario;
  /************************************* CONTROL CONTADOR *************************************/
  /*if p_id_funcionario is not null then

      select (glo.valor->'id_funcionario'), (glo.valor->'contador')
      into v_id_funcionario, v_contador
      from plani.variable_global_json glo
      where glo.variable = 'control_recursivo';

   	  raise notice 'v_id_funcionario: %, v_contador: %',v_id_funcionario,v_contador;

      if v_id_funcionario != p_id_funcionario and v_contador != 0 then
          raise notice 'v_contador: %',v_contador;

          update plani.variable_global_json set
          valor = jsonb_set(valor, '{id_funcionario}','0'::jsonb)
          where variable = 'control_recursivo';

          update plani.variable_global_json set
          valor = jsonb_set(valor, '{contador}','0'::jsonb)
          where variable = 'control_recursivo';
      else
          update plani.variable_global_json set
          valor = jsonb_set(valor, '{id_funcionario}',(p_id_funcionario::varchar)::jsonb)
          where variable = 'control_recursivo';

          update plani.variable_global_json set
          valor = jsonb_set(valor, '{contador}',((v_contador+1)::varchar)::jsonb)
          where variable = 'control_recursivo';

          if v_contador = 35 then
                select vf.desc_funcionario2 funcionario
                into v_funcionario
                from orga.vfuncionario vf
                where vf.id_funcionario = v_id_funcionario;
                raise  'Ocurrio una excepcion para el funcionario: %',v_funcionario;
          end if;
      end if;
  end if;*/
  /************************************* CONTROL CONTADOR *************************************/

  if (v_fecha_ini is not null) then
  	v_fecha_ini = plani.f_get_fecha_primer_contrato_empleado(v_id_uo_funcionario, p_id_funcionario, v_fecha_ini);
  else
  	v_fecha_ini = p_fecha_ini;
  end if;
  return v_fecha_ini;
EXCEPTION

	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '% ID. EMPLEADO: %',v_resp,p_id_funcionario;

END;
$body$
LANGUAGE 'plpgsql'
STABLE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

ALTER FUNCTION plani.f_get_fecha_primer_contrato_empleado (p_id_uo_funcionario integer, p_id_funcionario integer, p_fecha_ini date)
  OWNER TO postgres;