CREATE OR REPLACE FUNCTION plani.f_plaguin_valid_empleado (
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
  v_fecha_ini		date;
  v_cantidad_horas_mes	integer;
  v_resultado			numeric;
  v_tiene_incremento	integer;
  v_id_escala			integer;
  v_fecha_fin_planilla	date;
  v_entra				varchar;
  v_dias				integer;
  v_tipo_planilla		record;
  v_id_columna_valor	integer;
  v_detalle				record;

  /****************************** CALCULO COLUMNAS VALOR ******************************/
  v_funcionarios		    record;
  v_valor_generado			numeric;
  v_valor				    numeric;
  v_recalcular				varchar;
  /****************************** CALCULO COLUMNAS VALOR ******************************/
BEGIN

    v_nombre_funcion = 'plani.f_plaguin_valid_empleado';

	v_existe = 'no';
	select id_tipo_planilla, p.id_gestion, ges.gestion,id_uo, p.id_usuario_reg,p.fecha_planilla, pe.fecha_ini, pe.fecha_fin
    into v_planilla
    from plani.tplanilla p
    inner join param.tgestion ges on p.id_gestion = ges.id_gestion
    left join param.tperiodo pe on pe.id_periodo = p.id_periodo
    where p.id_planilla = p_id_planilla;

    if (v_planilla.fecha_planilla >= ('20/12/' || v_planilla.gestion)::date) then
    	v_fecha_fin_planilla = ('31/12/' || v_planilla.gestion)::date;
    ELSE
    	v_fecha_fin_planilla = v_planilla.fecha_planilla;
    end if;

    for v_registros in execute('
          select distinct on (uofun.id_funcionario) uofun.id_funcionario , uofun.id_uo_funcionario,ofi.id_lugar,uofun.fecha_asignacion as fecha_ini,
          (case when (uofun.fecha_finalizacion is null or uofun.fecha_finalizacion > ''' || v_fecha_fin_planilla || ''') then
          	''' || v_fecha_fin_planilla || '''
          else
          	uofun.fecha_finalizacion
          end) as fecha_fin,uofun.fecha_finalizacion as fecha_fin_real,tc.codigo as tipo_contrato
          from orga.tuo_funcionario uofun
          inner join orga.tcargo car
              on car.id_cargo = uofun.id_cargo
          inner join orga.ttipo_contrato tc
              on car.id_tipo_contrato = tc.id_tipo_contrato
          inner join orga.toficina ofi
              on car.id_oficina = ofi.id_oficina
          where tc.codigo in ('''||p_contrato||''') and UOFUN.tipo = ''oficial'' and
          coalesce(uofun.fecha_finalizacion,''' || v_fecha_fin_planilla || ''') >= (''31/03/' || v_planilla.gestion ||''')::date and
            uofun.fecha_asignacion <=  '''|| '31/12/' || v_planilla.gestion || ''' and
              uofun.estado_reg != ''inactivo'' and uofun.id_funcionario = ' || p_id_funcionario || '
              and uofun.id_funcionario not in (
                  select id_funcionario
                  from plani.tfuncionario_planilla fp
                  inner join plani.tplanilla p
                      on p.id_planilla = fp.id_planilla
                  where 	fp.id_funcionario = uofun.id_funcionario and
                          p.id_tipo_planilla = ' || v_planilla.id_tipo_planilla || ' and
                          p.id_gestion = ' || v_planilla.id_gestion || ')
          order by uofun.id_funcionario, uofun.fecha_asignacion desc')loop

        v_entra = 'si';
        if (v_fecha_fin_planilla != ('31/12/' || v_planilla.gestion)::date) then
        	if (v_registros.fecha_fin_real is null or v_registros.fecha_fin_real > v_fecha_fin_planilla)then
            	v_entra = 'no';
            end if;
        end if;
        v_dias = plani.f_get_dias_aguinaldo(v_registros.id_funcionario, v_registros.fecha_ini, v_registros.fecha_fin);


        if (v_dias >= 90  and v_entra = 'si') then
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
            plani.f_get_afp(p_id_funcionario, v_registros.fecha_fin),
            plani.f_get_cuenta_bancaria_empleado(p_id_funcionario, v_registros.fecha_fin),
            v_registros.tipo_contrato

			)RETURNING id_funcionario_planilla into o_id_funcionario_planilla;

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

          	v_existe = 'si';
            o_tipo_contrato = v_registros.tipo_contrato;
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



                  update plani.tcolumna_valor set
                      valor = round(v_valor, v_funcionarios.decimales_redondeo),
                      valor_generado = round(v_valor_generado, v_funcionarios.decimales_redondeo)
                  where id_columna_valor = v_funcionarios.id_columna_valor;
          end loop;
        /**************************************** CALCULO COLUMNAS VALOR ****************************************/

    end loop;
    if (v_existe = 'no') then
    	raise exception 'No se puede añadir el funcionario a la planilla ya que no le corresponde entrar a esta planilla de aguinaldo';
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

ALTER FUNCTION plani.f_plaguin_valid_empleado (p_id_usuario integer, p_id_funcionario integer, p_id_planilla integer, p_forzar_cheque varchar, p_finiquito varchar, p_contrato varchar, out o_id_funcionario_planilla integer, out o_tipo_contrato varchar)
  OWNER TO postgres;