CREATE OR REPLACE FUNCTION plani.f_plaguin_insert_empleados (
  p_id_planilla integer
)
RETURNS varchar AS
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
  v_id_afp				integer;
  v_id_cuenta_bancaria	integer;
  v_fecha_ini			date;
  v_entra				varchar;
  v_fecha_fin_planilla	date;
  v_dias				integer;
  v_tipo_contrato		varchar;

  v_id_gerente			integer;

BEGIN

    v_nombre_funcion = 'plani.f_plaguin_insert_empleados';
    v_filtro_uo = '';
	select id_tipo_planilla, per.id_periodo, ges.fecha_ini, ges.fecha_fin, id_uo,
    		p.id_usuario_reg,p.fecha_planilla,ges.gestion,p.id_gestion, p.modalidad
    into v_planilla
    from plani.tplanilla p
    left join param.tperiodo per on p.id_periodo = per.id_periodo
    inner join param.tgestion ges on ges.id_gestion = p.id_gestion
    where p.id_planilla = p_id_planilla;

    if (v_planilla.fecha_planilla >= ('20/12/' || v_planilla.gestion)::date) then
    	v_fecha_fin_planilla = ('31/12/' || v_planilla.gestion)::date;
    ELSE
    	v_fecha_fin_planilla = v_planilla.fecha_planilla;
    end if;

    if (v_planilla.id_uo is not null) then
    	v_filtro_uo = ' uofun.id_uo in (' || orga.f_get_uos_x_planilla(v_planilla.id_uo) || ','|| v_planilla.id_uo ||') and ';
    end if;


    for v_registros in execute('
          select distinct on (uofun.id_funcionario) uofun.id_funcionario , uofun.id_uo_funcionario,ofi.id_lugar,uofun.fecha_asignacion as fecha_ini,
          (case when (uofun.fecha_finalizacion is null or uofun.fecha_finalizacion > ''' || v_fecha_fin_planilla || ''') then
          	''' || v_fecha_fin_planilla || '''
          else
          	uofun.fecha_finalizacion
          end) as fecha_fin,uofun.fecha_finalizacion as fecha_fin_real,
          ca.codigo as categoria
          from orga.tuo_funcionario uofun
          inner join orga.tcargo car on car.id_cargo = uofun.id_cargo

          inner join orga.tescala_salarial es on es.id_escala_salarial = car.id_escala_salarial and es.estado_reg = ''activo''
          inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

          inner join orga.ttipo_contrato tc
              on car.id_tipo_contrato = tc.id_tipo_contrato
          inner join orga.toficina ofi
              on car.id_oficina = ofi.id_oficina
          where tc.codigo in (''PLA'', ''EVE'') and UOFUN.tipo = ''oficial'' and '
          	|| v_filtro_uo || ' coalesce(uofun.fecha_finalizacion,''' || v_fecha_fin_planilla || ''') >= (''01/12/' || v_planilla.gestion ||''')::date and
            uofun.fecha_asignacion <=  '''|| '31/12/' || v_planilla.gestion || ''' and
              uofun.estado_reg != ''inactivo''
              and uofun.id_funcionario not in (
                  select id_funcionario
                  from plani.tfuncionario_planilla fp
                  inner join plani.tplanilla p
                      on p.id_planilla = fp.id_planilla
                  where 	fp.id_funcionario = uofun.id_funcionario and
                          p.id_tipo_planilla = ' || v_planilla.id_tipo_planilla || ' and
                          p.id_gestion = ' || v_planilla.id_gestion || ')
          order by uofun.id_funcionario, uofun.fecha_asignacion desc')loop

        -- (''31/03/' || v_planilla.gestion ||''')::date REGLA PARA AGREGAR A TODOS LOS FUNCIONARIOS DE LA GESTION 2020 (franky) 01/12/2020
        -- (''01/12/' || v_planilla.gestion ||''')::date

        select tuo.id_funcionario
        into v_id_gerente
        from orga.tcargo tcar
        inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
        inner join orga.tuo uo on uo.id_uo = tuo.id_uo
        where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo'
        and coalesce(tuo.fecha_finalizacion,'31/12/9999'::date)>= current_date;

    	v_entra = 'si';
        if (v_fecha_fin_planilla != ('31/12/' || v_planilla.gestion)::date) then
        	if (v_registros.fecha_fin_real is null or v_registros.fecha_fin_real > v_fecha_fin_planilla)then
            	v_entra = 'no';
            end if;
        end if;
        v_dias = plani.f_get_dias_aguinaldo(v_registros.id_funcionario, v_registros.fecha_ini, v_registros.fecha_fin);

        if ((v_registros.categoria != 'SUPER' or v_registros.id_funcionario::integer = v_id_gerente) and v_planilla.modalidad = 'administrativo') then
          if (v_dias >= 90  and v_entra = 'si') then
            v_id_afp = plani.f_get_afp(v_registros.id_funcionario, v_registros.fecha_fin);
            v_id_cuenta_bancaria = plani.f_get_cuenta_bancaria_empleado(v_registros.id_funcionario, v_planilla.fecha_fin);
               v_tipo_contrato = plani.f_get_tipo_contrato(v_registros.id_uo_funcionario);
              INSERT INTO plani.tfuncionario_planilla (
                  id_usuario_reg,					estado_reg,					id_funcionario,
                  id_planilla,					id_uo_funcionario,			id_lugar,
                  forzar_cheque,					finiquito,					id_afp,
                  id_cuenta_bancaria,				tipo_contrato)
              VALUES (
                  v_planilla.id_usuario_reg,		'activo',					v_registros.id_funcionario,
                  p_id_planilla,					v_registros.id_uo_funcionario,v_registros.id_lugar,
                  'no',							'no',						v_id_afp,
                  v_id_cuenta_bancaria,			v_tipo_contrato)
              RETURNING id_funcionario_planilla into v_id_funcionario_planilla;

              for v_columnas in (	select *
                                  from plani.ttipo_columna
                                  where id_tipo_planilla = v_planilla.id_tipo_planilla and estado_reg = 'activo' order by orden) loop
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
                      v_planilla.id_usuario_reg,
                      'activo',
                      v_columnas.id_tipo_columna,
                      v_id_funcionario_planilla,
                      v_columnas.codigo,
                      v_columnas.formula,
                      0,
                      0
                    );
              end loop;
          end if;
        end if;

        if ((v_registros.categoria = 'SUPER' and v_registros.id_funcionario::integer != v_id_gerente) and v_planilla.modalidad = 'piloto') then

          if (v_dias >= 90  and v_entra = 'si') then
            v_id_afp = plani.f_get_afp(v_registros.id_funcionario, v_registros.fecha_fin);
            v_id_cuenta_bancaria = plani.f_get_cuenta_bancaria_empleado(v_registros.id_funcionario, v_planilla.fecha_fin);
               v_tipo_contrato = plani.f_get_tipo_contrato(v_registros.id_uo_funcionario);
              INSERT INTO plani.tfuncionario_planilla (
                  id_usuario_reg,					estado_reg,					id_funcionario,
                  id_planilla,					id_uo_funcionario,			id_lugar,
                  forzar_cheque,					finiquito,					id_afp,
                  id_cuenta_bancaria,				tipo_contrato)
              VALUES (
                  v_planilla.id_usuario_reg,		'activo',					v_registros.id_funcionario,
                  p_id_planilla,					v_registros.id_uo_funcionario,v_registros.id_lugar,
                  'no',							'no',						v_id_afp,
                  v_id_cuenta_bancaria,			v_tipo_contrato)
              RETURNING id_funcionario_planilla into v_id_funcionario_planilla;

              for v_columnas in (	select *
                                  from plani.ttipo_columna
                                  where id_tipo_planilla = v_planilla.id_tipo_planilla and estado_reg = 'activo' order by orden) loop
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
                      v_planilla.id_usuario_reg,
                      'activo',
                      v_columnas.id_tipo_columna,
                      v_id_funcionario_planilla,
                      v_columnas.codigo,
                      v_columnas.formula,
                      0,
                      0
                    );
              end loop;
          end if;
        end if;
    end loop;
    return 'exito';
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

ALTER FUNCTION plani.f_plaguin_insert_empleados (p_id_planilla integer)
  OWNER TO postgres;