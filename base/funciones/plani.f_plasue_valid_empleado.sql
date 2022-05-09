CREATE OR REPLACE FUNCTION plani.f_plasue_valid_empleado (
  p_id_usuario integer,
  p_id_funcionario integer,
  p_id_planilla integer,
  p_forzar_cheque varchar,
  p_finiquito varchar,
  p_contrato varchar,
  out o_id_funcionario_planilla integer,
  out o_tipo_contrato varchar
)
RETURNS record AS
$body$
DECLARE
  v_registros			record;
  v_planilla			record;
  v_id_funcionario_planilla	integer;
  v_columnas			record;
  v_resp	            varchar;
  v_nombre_funcion      text;
  v_mensaje_error       text;
  v_filtro_uo			varchar;
  v_existe				varchar;
  v_tipo_planilla		record;
  v_id_columna_valor	integer;
  v_detalle				record;

  /************************************** PORCENTAJE HORAS TRABAJADAS **************************************/
  v_suma_horas		    	integer;
  v_suma_sueldo		    	numeric;
  v_cantidad_horas_mes    	integer;
  v_funcionario           	varchar;
  v_suma_porcentaje			numeric;
  v_id_horas_trabajadas		integer;

  /****************************** CALCULO COLUMNAS VALOR ******************************/
  v_funcionarios		    record;
  v_valor_generado			numeric;
  v_valor				    numeric;
  v_recalcular				varchar;
  /****************************** CALCULO COLUMNAS VALOR ******************************/
  /************************************** PORCENTAJE HORAS TRABAJADAS **************************************/
BEGIN

    v_nombre_funcion = 'plani.f_plasue_valid_empleado';

	v_existe = 'no';
	select id_tipo_planilla, per.id_periodo, fecha_ini, fecha_fin, id_uo, p.id_usuario_reg
    into v_planilla
    from plani.tplanilla p
    inner join param.tperiodo per
    	on p.id_periodo = per.id_periodo
    where p.id_planilla = p_id_planilla;


    for v_registros in execute('
          select uofun.id_funcionario, uofun.id_funcionario , uofun.id_uo_funcionario,ofi.id_lugar,tc.codigo as tipo_contrato
          from orga.tuo_funcionario uofun
          inner join orga.tcargo car
              on car.id_cargo = uofun.id_cargo
          inner join orga.ttipo_contrato tc
              on car.id_tipo_contrato = tc.id_tipo_contrato
          inner join orga.toficina ofi
              on car.id_oficina = ofi.id_oficina
          --where uofun.id_funcionario = ' || p_id_funcionario || ' and tc.codigo in (''PLA'', ''EVE'') and UOFUN.tipo = ''oficial'' and
          where uofun.id_funcionario = ' || p_id_funcionario || ' and tc.codigo in ('''||p_contrato||''') and UOFUN.tipo = ''oficial'' and
          	 uofun.fecha_asignacion <= ''' || v_planilla.fecha_fin || ''' and
              (uofun.fecha_finalizacion is null or uofun.fecha_finalizacion >= ''' || v_planilla.fecha_ini || ''') AND
              uofun.estado_reg != ''inactivo'' and uofun.id_funcionario not in (
                  select id_funcionario
                  from plani.tfuncionario_planilla fp
                  inner join plani.tplanilla p
                      on p.id_planilla = fp.id_planilla
                  where 	fp.id_funcionario = uofun.id_funcionario and
                          p.id_tipo_planilla = ' || v_planilla.id_tipo_planilla || ' and
                          p.id_periodo = ' || v_planilla.id_periodo || ' and fp.tipo_contrato = '''||p_contrato||''')
          order by uofun.fecha_asignacion desc
          --limit 1')loop

          select tp.*,p.id_gestion,p.estado into v_tipo_planilla
        	from plani.tplanilla p
        	inner join plani.ttipo_planilla tp
        		on tp.id_tipo_planilla = p.id_tipo_planilla
        	where p.id_planilla = p_id_planilla;

          --Sentencia de la insercion
        	insert into plani.tfuncionario_planilla(
			finiquito,
			forzar_cheque,
			id_funcionario,
			id_planilla,
			id_lugar,
			id_uo_funcionario,
			estado_reg,
			id_usuario_reg,
			fecha_reg,
			id_usuario_mod,
			fecha_mod,
            id_afp,
            id_cuenta_bancaria,
            tipo_contrato
          	) values(
			p_finiquito,
			p_forzar_cheque,
			p_id_funcionario,
			p_id_planilla,
			v_registros.id_lugar,
			v_registros.id_uo_funcionario,
			'activo',
			p_id_usuario,
			now(),
			null,
			null,
            plani.f_get_afp(p_id_funcionario, v_planilla.fecha_fin),
            plani.f_get_cuenta_bancaria_empleado(p_id_funcionario, v_planilla.fecha_fin),
            v_registros.tipo_contrato

			)RETURNING id_funcionario_planilla into o_id_funcionario_planilla;

			o_tipo_contrato = v_registros.tipo_contrato;

			for v_columnas in (	select *
        					from plani.ttipo_columna
                            where id_tipo_planilla = v_tipo_planilla.id_tipo_planilla and estado_reg = 'activo'  order by orden) loop
		        	INSERT INTO
		                plani.tcolumna_valor
		              (
		                id_usuario_reg,
		                estado_reg,
		                id_tipo_columna,
		                id_funcionario_planilla,
		                codigo_columna,
		                formula,
		                valor,
		                valor_generado
		              )
		              VALUES (
		                p_id_usuario,
		                'activo',
		                v_columnas.id_tipo_columna,
		                o_id_funcionario_planilla,
		                v_columnas.codigo,
		                v_columnas.formula,
		                0,
		                0
		              )returning id_columna_valor into v_id_columna_valor;

                      --registrando el detalle en caso de ser necesario
                if (v_columnas.tiene_detalle = 'si')then
                	for v_detalle in (
                    	select ht.id_horas_trabajadas
                    	from plani.tplanilla p
                    	inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                    	inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                    	inner join plani.thoras_trabajadas ht on ht.id_funcionario_planilla = fp.id_funcionario_planilla
                    	where fp.id_funcionario = p_id_funcionario and  tp.codigo = 'PLASUE' and
                    	ht.estado_reg = 'activo' and p.id_gestion = v_tipo_planilla.id_gestion) loop

                        INSERT INTO
                            plani.tcolumna_detalle
                          (
                            id_usuario_reg,
                            id_horas_trabajadas,
                            id_columna_valor,
                            valor,
                            valor_generado
                          )
                          VALUES (
                            p_id_usuario,
                            v_detalle.id_horas_trabajadas,
                            v_id_columna_valor,
                            0,
                            0
                          );

                    end loop;
                end if;
        end loop;

        if (v_tipo_planilla.estado in ('calculo_columnas', 'registro_horas'))then

        	execute 'select * from ' || v_tipo_planilla.funcion_calculo_horas || '(' ||
        						 p_id_planilla || ', '||p_id_usuario  || ', '''||p_contrato|| ''', '||v_registros.id_uo_funcionario||', '|| o_id_funcionario_planilla||')'
        	into v_resp;
        end if;
        v_existe = 'si';

        /********************************************************************* PORCENTAJE HORAS TRABAJADAS *********************************************************************/
          select vf.desc_funcionario2::varchar
          into v_funcionario
          from orga.vfuncionario vf
          where vf.id_funcionario = p_id_funcionario;

          v_cantidad_horas_mes = plani.f_get_valor_parametro_valor('HORLAB', v_planilla.fecha_ini)::integer;

          select sum(horas_normales)::integer, round(sum(sueldo / v_cantidad_horas_mes * case when horas_normales=0 then 1 else horas_normales end),2)
                    into v_suma_horas, v_suma_sueldo
                    from plani.thoras_trabajadas
                    where id_funcionario_planilla = o_id_funcionario_planilla;

                    if (v_suma_horas > v_cantidad_horas_mes)then
                        raise exception 'La cantidad de horas trabajadas para el empleado : % , superan las : % horas', v_funcionario,v_cantidad_horas_mes;
                    end if;

                    if (v_suma_horas < 0 )then
                        raise exception 'La cantidad de horas trabajadas para el empleado : % , es 0 o menor a 0', v_funcionario;
                    end if;

                    update plani.thoras_trabajadas set
                        porcentaje_sueldo = (round((sueldo / v_cantidad_horas_mes * coalesce(horas_normales,1)),2) / case when v_suma_sueldo=0 then 1 else v_suma_sueldo end) * 100
                    where id_funcionario_planilla = o_id_funcionario_planilla;

                    select sum(porcentaje_sueldo),max(id_horas_trabajadas)
                    into v_suma_porcentaje,v_id_horas_trabajadas
                    from plani.thoras_trabajadas
                    where id_funcionario_planilla = o_id_funcionario_planilla;

                    if (v_suma_porcentaje != 100 ) then
                        update plani.thoras_trabajadas set
                            porcentaje_sueldo = porcentaje_sueldo + (100 - v_suma_porcentaje)
                        where id_horas_trabajadas = v_id_horas_trabajadas;
                    end if;


          /**************************************** CALCULO COLUMNAS VALOR ****************************************/


          v_recalcular = 'no';

          for v_funcionarios in (	select fp.*,cv.*,tc.tipo_descuento_bono, tc.orden, tc.finiquito,
        							tc.decimales_redondeo,tc.tipo_dato
    						from plani.tfuncionario_planilla fp
    						inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
        					inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                            where fp.id_planilla = p_id_planilla and tc.orden >= 0 and fp.id_funcionario_planilla = o_id_funcionario_planilla
                            order by fp.id_funcionario_planilla asc,tc.orden asc
    						) loop

                    if (v_funcionarios.tipo_descuento_bono is not null and v_funcionarios.tipo_descuento_bono != '') THEN
                        if (v_funcionarios.valor_generado = v_funcionarios.valor) then
                            v_valor_generado = plani.f_calcular_descuento_bono(v_funcionarios.id_funcionario,
                                                v_planilla.fecha_ini, v_planilla.fecha_fin, v_funcionarios.id_tipo_columna,
                                                v_funcionarios.tipo_descuento_bono,v_funcionarios.formula,
                                                v_funcionarios.id_funcionario_planilla,v_funcionarios.codigo_columna,
                                                v_funcionarios.tipo_dato, v_funcionarios.id_columna_valor);
                            v_valor = v_valor_generado;
                        else
                            v_valor_generado = v_funcionarios.valor_generado;
                            v_valor = v_funcionarios.valor;
                        end if;
                    elsif (v_funcionarios.tipo_dato = 'basica') THEN
                        if (v_funcionarios.valor_generado = v_funcionarios.valor) then

                            v_valor_generado = plani.f_calcular_basica(v_funcionarios.id_funcionario_planilla,
                                                    v_planilla.fecha_ini, v_planilla.fecha_fin, v_funcionarios.id_tipo_columna,v_funcionarios.codigo_columna,v_funcionarios.id_columna_valor);

                            v_valor = v_valor_generado;

                        else
                            v_valor_generado = v_funcionarios.valor_generado;
                            v_valor = v_funcionarios.valor;
                        end if;
                    elsif (v_funcionarios.tipo_dato = 'formula') then
                        if (v_funcionarios.valor_generado = v_funcionarios.valor) then
                            v_valor_generado = plani.f_calcular_formula(v_funcionarios.id_funcionario_planilla,
                                                        v_funcionarios.formula, v_planilla.fecha_ini, v_funcionarios.id_columna_valor,v_recalcular);
                            v_valor = v_valor_generado;
                        else
                            v_valor_generado = v_funcionarios.valor_generado;
                            v_valor = v_funcionarios.valor;
                        end if;
                    else
                        v_valor_generado = v_funcionarios.valor_generado;
                        v_valor = v_funcionarios.valor;
                    end if;
                    if (v_funcionarios.codigo_columna = 'AFP_CADM' or v_funcionarios.codigo_columna = 'AFP_APSOL') and v_funcionarios.id_funcionario_planilla = 479772 then
                        if CAST(SUBSTRING (split_part(CAST ( v_valor AS varchar ),'.',2), 3, 1) AS INTEGER) <= 5 then
                            v_valor = CAST( split_part(CAST ( v_valor AS varchar ),'.',1)||'.'||SUBSTRING (split_part(CAST ( v_valor AS varchar ),'.',2), 1, 2) AS NUMERIC);
                            v_valor_generado = CAST( split_part(CAST ( v_valor_generado AS varchar ),'.',1)||'.'||SUBSTRING (split_part(CAST ( v_valor_generado AS varchar ),'.',2), 1, 2) AS NUMERIC);
                        end if;
                    end if;

                    --(franklin.espinoza)[13/07/2021]redondeo para el 13 % de facturas
                    if v_funcionarios.codigo_columna = 'IMPOFAC13' then
                        if (v_valor-trunc(v_valor)) >= 0.46 and (v_valor_generado-trunc(v_valor_generado)) >= 0.46 then
                            v_valor = ceiling(v_valor);
                            v_valor_generado = ceiling(v_valor_generado);
                        end if;
                    end if;
                    --(franklin.espinoza)[13/07/2021]redondeo para el 13 % de facturas

                    update plani.tcolumna_valor set
                        valor = case when v_funcionarios.codigo_columna in ('AFP_CADM','AFP_CADM') and v_funcionarios.id_funcionario_planilla = 479772  then v_valor else round (v_valor, v_funcionarios.decimales_redondeo) end,--round (v_valor, v_funcionarios.decimales_redondeo),
                        valor_generado = case when v_funcionarios.codigo_columna in ('AFP_CADM','AFP_CADM') and v_funcionarios.id_funcionario_planilla = 479772 then v_valor_generado else round (v_valor_generado, v_funcionarios.decimales_redondeo) end--round (v_valor_generado, v_funcionarios.decimales_redondeo)
                    where id_columna_valor = v_funcionarios.id_columna_valor;
            end loop;
          /**************************************** CALCULO COLUMNAS VALOR ****************************************/
          /********************************************************************* PORCENTAJE HORAS TRABAJADAS *********************************************************************/

    end loop;
    if (v_existe = 'no') then
    	raise exception 'No se puede añadir el funcionario a la planilla ya que no tiene una asignacion de cargo para el periodo o ya esta incluido en otra planilla';
    end if;
    return;
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

ALTER FUNCTION plani.f_plasue_valid_empleado (p_id_usuario integer, p_id_funcionario integer, p_id_planilla integer, p_forzar_cheque varchar, p_finiquito varchar, p_contrato varchar, out o_id_funcionario_planilla integer, out o_tipo_contrato varchar)
  OWNER TO postgres;