CREATE OR REPLACE FUNCTION plani.ft_reporte_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
  /**************************************************************************
   SISTEMA:		Sistema de Planillas
   FUNCION: 		plani.ft_reporte_sel
   DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'plani.treporte'
   AUTOR: 		 (admin)
   FECHA:	        17-01-2014 22:07:28
   COMENTARIOS:
  ***************************************************************************
   HISTORIAL DE MODIFICACIONES:

   DESCRIPCION:
   AUTOR:
   FECHA:
  ***************************************************************************/

  DECLARE

    v_consulta    		varchar;
    v_parametros  		record;
    v_nombre_funcion   	text;
    v_resp				varchar;

    v_ordenar_por		varchar;
    v_where				varchar;
	v_tipo_contrato		varchar;

    --Reporte General
    v_mes				integer;
    v_fechas			record;
    v_id_gestion 		integer;
    v_filtro			varchar = '';

    --categoria programatica
    v_funcionario			record;
    v_asignacion			record;
    v_codigo_pres			varchar = '';
    v_cont_pres				integer = 0;
    v_id_funcionario		integer = -1;

    --f.e.a
    v_id_periodo		integer;

    v_cond_categoria		varchar='';
    v_cond_gestion			varchar='';
    v_cond_admin			varchar='';
    v_codigo				varchar='';
    v_inner_periodo			varchar='';
    v_periodo_group			varchar='';
    v_record				record;
    v_desc_planilla			record;
    v_gestion				integer;

    v_cont_pla				integer;
    v_modalidad       varchar = '';
    v_id_planilla_retroactivo integer;

    v_fecha_planilla date;

    v_fecha_inicio    date;
    v_fecha_final     date;

    v_contrato        varchar;

    v_calendario      varchar;

    v_fecha_fin       date;

    v_licencia        varchar;

    v_id_gerente				varchar;

    --Reporte Otros Ingresos
    v_contador_prima	integer=0;
    v_contador_retro	integer=0;
    v_inner_prima		varchar='';
    v_col_prima			varchar = '0::numeric as monto4,';

    v_col_retro			varchar = '';

    v_inner_categoria	varchar = '';
    v_where_categoria	varchar = '';

    v_date_fin_contrato	date;
    v_date_ini_contrato	date;

    v_estado 			varchar='activo';
    v_periodo			integer;
    v_id_prima			integer;
    v_id_retro			integer;
    v_fuente			varchar = '';

  BEGIN

    v_nombre_funcion = 'plani.ft_reporte_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'PLA_REPO_SEL'
     #DESCRIPCION:	Consulta de datos
     #AUTOR:		admin
     #FECHA:		17-01-2014 22:07:28
    ***********************************/

    if(p_transaccion='PLA_REPO_SEL')then

      begin
        --Sentencia de la consulta
        v_consulta:='select
						repo.id_reporte,
						repo.id_tipo_planilla,
						repo.numerar,
						repo.hoja_posicion,
						repo.mostrar_nombre,
						repo.mostrar_codigo_empleado,
						repo.mostrar_doc_id,
						repo.mostrar_codigo_cargo,
						repo.agrupar_por,
						repo.ordenar_por,
						repo.estado_reg,
						repo.ancho_utilizado,
						repo.ancho_total,
						repo.titulo_reporte,
						repo.fecha_reg,
						repo.id_usuario_reg,
						repo.id_usuario_mod,
						repo.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						repo.control_reporte,
						repo.tipo_reporte
						from plani.treporte repo
						inner join segu.tusuario usu1 on usu1.id_usuario = repo.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = repo.id_usuario_mod
				        where  ';

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
     #TRANSACCION:  'PLA_REPO_CONT'
     #DESCRIPCION:	Conteo de registros
     #AUTOR:		admin
     #FECHA:		17-01-2014 22:07:28
    ***********************************/

    elsif(p_transaccion='PLA_REPO_CONT')then

      begin
        --Sentencia de la consulta de conteo de registros
        v_consulta:='select count(id_reporte)
					    from plani.treporte repo
					    inner join segu.tusuario usu1 on usu1.id_usuario = repo.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = repo.id_usuario_mod
					    where ';

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;

        --Devuelve la respuesta
        return v_consulta;

      end;
    /*********************************
 	#TRANSACCION:  'PLA_REPOMAES_SEL'
 	#DESCRIPCION:	Reporte Generico de planilla de sueldos maestro
 	#AUTOR:		admin
 	#FECHA:		17-01-2014 22:07:28
	***********************************/

    elsif(p_transaccion='PLA_REPOMAES_SEL')then

      begin


        --Sentencia de la consulta
        v_consulta:='select
            				repo.numerar,
                            repo.hoja_posicion,
                            repo.mostrar_nombre,
                            repo.mostrar_codigo_empleado,
                            repo.mostrar_doc_id,
                            repo.mostrar_codigo_cargo,
                            repo.agrupar_por,
                            repo.ordenar_por,
                            repo.titulo_reporte,

                            plani.nro_planilla,
                            per.periodo,
                            ges.gestion,
                            uo.nombre_unidad,
                            dep.nombre_corto,
                            (select count(*) from plani.treporte_columna where id_reporte = repo.id_reporte)::integer

						from plani.tplanilla plani
						inner join plani.treporte repo on  repo.id_tipo_planilla = plani.id_tipo_planilla
                        left join param.tperiodo per on per.id_periodo = plani.id_periodo
                        inner join param.tgestion ges on ges.id_gestion = plani.id_gestion
                        left join orga.tuo uo on uo.id_uo = plani.id_uo
                        inner join param.tdepto dep on dep.id_depto = plani.id_depto
				        where ';

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        --v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
  #TRANSACCION:  'PLA_REPOPREV_SEL'
  #DESCRIPCION:	Reporte de previsiones
  #AUTOR:		admin
  #FECHA:		17-01-2014 22:07:28
 ***********************************/

    elsif(p_transaccion='PLA_REPOPREV_SEL')then

      begin
        v_where = '';
        if (v_parametros.id_tipo_contrato <> '') then
          v_where = v_where || ' and tc.id_tipo_contrato in ('||v_parametros.id_tipo_contrato||')';
        /*else
          v_where = v_where || ' and tc.id_tipo_contrato IN (1,4)';*/
        end if;

        if (v_parametros.id_uo <> -1) then
          v_where = v_where || ' and ger.id_uo = ' || v_parametros.id_uo;
        end if;

        select pxp.list(con.nombre)
        into v_contrato
        from orga.ttipo_contrato con
        where con.id_tipo_contrato::varchar = any(string_to_array(v_parametros.id_tipo_contrato,','));
        /*select tg.id_gestion, tg.gestion
        into v_id_gestion, v_gestion
        from param.tgestion tg
        where tg.gestion = date_part('year', v_parametros.fecha);

        select tp.id_periodo
        into v_id_periodo
        from param.tperiodo tp
        where tp.periodo = date_part('month', v_parametros.fecha) and tp.id_gestion = v_id_gestion;*/

        v_consulta:='with detalle as(

              select
                              ger.nombre_unidad as Gerencia,
                              car.nombre as NombreCargo,
                              datos.desc_funcionario2 as NombreCompleto,

                              (case when uofun.id_funcionario = 10 then
                                  ''27/12/2013''::date
                              else
                                  plani.f_get_fecha_primer_contrato_empleado(uofun.id_uo_funcionario,uofun.id_funcionario,uofun.fecha_asignacion)
                              END)  as FechaIncorp,

                              /*(case when uofun.id_funcionario = 10 then
                                   (''' || v_parametros.fecha ||'''::date - ''27/12/2013''::date) + 1
                              else*/
                                 (''' || v_parametros.fecha ||'''::date - plani.f_get_fecha_primer_contrato_empleado(uofun.id_uo_funcionario,uofun.id_funcionario,uofun.fecha_asignacion)) + 1 - plani.f_get_dias_licencia_funcionario(datos.id_funcionario,''' || v_parametros.fecha ||'''::Date)::integer
                              /*END)::integer */ as diastrabajados,

                          (case when ' || v_parametros.id_uo ||' <>-1 then
                              ger.nombre_unidad
                          ELSE
                              ''Boliviana de Aviacion''::varchar
                          END)  as NombreDepartamento,
                          (case when '''||v_contrato||''' <> '''' then
                              '''||v_contrato||'''
                          ELSE
                              ''TODOS''::varchar
                          END)  as NombreContrato,
                          ''' || v_parametros.fecha ||'''::Date as FechaPrev ,
                          orga.f_get_haber_basico_a_fecha(escala.id_escala_salarial,''' || (case when v_parametros.fecha > now()::date then now()::date else v_parametros.fecha end) ||'''::date) as haberbasico,
                          fun.antiguedad_anterior,
                          plani.f_get_fecha_primer_contrato_empleado(uofun.id_uo_funcionario,uofun.id_funcionario,uofun.fecha_asignacion) as fechaAntiguedad,
                          (case when ofi.frontera =''si'' then
                          	0.2
                          else
                          	0
                          end) as frontera,
                          pre.descripcion as presupuesto,
                          uofun.tipo,
                          datos.id_funcionario,
                          uofun.id_uo_funcionario
                          from orga.tuo_funcionario uofun
                          INNER JOIN orga.vfuncionario datos ON datos.id_funcionario=uofun.id_funcionario
                          inner join orga.tcargo car ON car.id_cargo = uofun.id_cargo

                          LEFT JOIN orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.id_gestion = (select po_id_gestion from param.f_get_periodo_gestion(''' || v_parametros.fecha ||'''::date))
                          and cp.estado_reg = ''activo'' and (cp.fecha_fin >= ''' || v_parametros.fecha ||'''::date or cp.fecha_fin is NULL)

                          --left join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo /*and
                          --''' || v_parametros.fecha ||'''::date <= coalesce(cp.fecha_fin,''31/12/9999''::date)*/ and cp.id_gestion = (select po_id_gestion from param.f_get_periodo_gestion(''' || v_parametros.fecha ||'''::date))

                          left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                          inner join orga.toficina ofi ON ofi.id_oficina = car.id_oficina
                          inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
                          inner join orga.tescala_salarial escala ON escala.id_escala_salarial=car.id_escala_salarial
                          inner join orga.tfuncionario fun on fun.id_funcionario = datos.id_funcionario
                          inner join orga.tuo ger on ger.id_uo = orga.f_get_uo_gerencia(uofun.id_uo,NULL,''' || v_parametros.fecha ||'''::date)
                          where uofun.estado_reg != ''inactivo'' and uofun.fecha_asignacion <= ''' || v_parametros.fecha ||'''::date and
                          (uofun.fecha_finalizacion >= ''' || v_parametros.fecha ||'''::date or uofun.fecha_finalizacion is null) ' || v_where ||'
                          order by ger.prioridad::INTEGER,datos.desc_funcionario2)

                          select Gerencia::varchar,NombreCargo::varchar,NombreCompleto::text,

                          round(plani.f_promedio_ultimos_tres_sueldos (det.id_funcionario, '''|| v_parametros.fecha ||'''::date),2) as HaberBasico,

                          to_char(FechaIncorp::date,''DD/MM/YYYY'')::varchar,
                          diastrabajados::integer,

                          round(plani.f_promedio_ultimos_tres_sueldos (det.id_funcionario, '''|| v_parametros.fecha ||'''::date)/365,8) as indemdia,
                          round(plani.f_promedio_ultimos_tres_sueldos (det.id_funcionario, '''|| v_parametros.fecha ||'''::date)/365,8)*diastrabajados as Indem,
                          presupuesto
                          --,id_uo_funcionario
                          from detalle det
                          where diastrabajados >= 90 and tipo=''oficial'' ';

        raise notice '%',v_where;
        --Sentencia de la consulta
        /*v_consulta:='with detalle as(

              select
                              ger.nombre_unidad as Gerencia,
                              car.nombre as NombreCargo,
                              datos.desc_funcionario2 as NombreCompleto,

                              (case when uofun.id_funcionario = 10 then
                                  ''27/12/2013''::date
                              else
                                  plani.f_get_fecha_primer_contrato_empleado(uofun.id_uo_funcionario,uofun.id_funcionario,uofun.fecha_asignacion)
                              END)  as FechaIncorp,

                              (case when uofun.id_funcionario = 10 then
                                   (''' || v_parametros.fecha ||'''::date - ''27/12/2013''::date) + 1
                              else
                                 (''' || v_parametros.fecha ||'''::date - plani.f_get_fecha_primer_contrato_empleado(uofun.id_uo_funcionario,uofun.id_funcionario,uofun.fecha_asignacion)) + 1 - plani.f_get_dias_licencia_funcionario(datos.id_funcionario,''' || v_parametros.fecha ||'''::Date)
                              END)::integer  as diastrabajados,

                          (case when ' || v_parametros.id_uo ||' <>-1 then
                              ger.nombre_unidad
                          ELSE
                              ''Boliviana de Aviacion''::varchar
                          END)  as NombreDepartamento,
                          (case when ' || v_parametros.id_tipo_contrato ||'<>-1 then
                              tc.nombre
                          ELSE
                              ''TODOS''::varchar
                          END)  as NombreContrato,
                          ''' || v_parametros.fecha ||'''::Date as FechaPrev ,
                          orga.f_get_haber_basico_a_fecha(escala.id_escala_salarial,''' || (case when v_parametros.fecha > current_date then current_date else v_parametros.fecha end) ||'''::date) as haberbasico,
                          fun.antiguedad_anterior,
                          plani.f_get_fecha_primer_contrato_empleado(uofun.id_uo_funcionario,uofun.id_funcionario,uofun.fecha_asignacion) as fechaAntiguedad,
                          (case when ofi.frontera =''si'' then
                          	0.2
                          else
                          	0
                          end) as frontera,
                          pre.descripcion as presupuesto,
                          tcv.valor as bono_antiguedad
                          from orga.tuo_funcionario uofun

                          inner join plani.tplanilla tpl on tpl.id_periodo = '||v_id_periodo||' and tpl.id_gestion = '||v_id_gestion||'
                          inner join plani.tfuncionario_planilla tfp on tfp.id_uo_funcionario = uofun.id_uo_funcionario and tfp.id_planilla = tpl.id_planilla
                          inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''BONANT''

                          INNER JOIN orga.vfuncionario datos ON datos.id_funcionario=uofun.id_funcionario
                          inner join orga.tcargo car ON car.id_cargo = uofun.id_cargo
                          /*left join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and
                          	cp.fecha_ini <= ''' || v_parametros.fecha ||'''::date and cp.id_gestion = (select po_id_gestion from param.f_get_periodo_gestion(''' || v_parametros.fecha ||'''::date))
                            */

                          inner join param.tperiodo tper on tper.id_periodo = tpl.id_periodo and tper.id_gestion = '||v_id_gestion||'
                          inner join orga.tcargo_presupuesto cp on cp.id_cargo = uofun.id_cargo and cp.id_gestion = '||v_id_gestion||'  and
                          ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                          (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,''31/12/'||v_gestion||'''::date)))


                          left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                          inner join orga.toficina ofi ON ofi.id_oficina = car.id_oficina
                          inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
                          inner join orga.tescala_salarial escala ON escala.id_escala_salarial=car.id_escala_salarial
                          inner join orga.tfuncionario fun on fun.id_funcionario = datos.id_funcionario
                          inner join orga.tuo ger on ger.id_uo = orga.f_get_uo_gerencia(uofun.id_uo,NULL,''' || v_parametros.fecha ||'''::date)
                          where uofun.estado_reg != ''inactivo'' and uofun.fecha_asignacion <= ''' || v_parametros.fecha ||'''::date and
                          (uofun.fecha_finalizacion >= ''' || v_parametros.fecha ||'''::date or uofun.fecha_finalizacion is null) ' || v_where ||' and uofun.tipo = ''oficial''
                          order by ger.prioridad::INTEGER,datos.desc_funcionario2)

                          select Gerencia::varchar,NombreCargo::varchar,NombreCompleto::text,
                          round(haberBasico*frontera + haberBasico + /*plani.f_evaluar_antiguedad (fechaAntiguedad,''' || v_parametros.fecha ||'''::date,antiguedad_anterior)*/bono_antiguedad,2) as HaberBasico,
                          to_char(FechaIncorp::date,''DD/MM/YYYY'')::varchar,
                          diastrabajados::integer,
                          round((haberBasico*frontera + haberBasico + /*plani.f_evaluar_antiguedad (fechaAntiguedad,''' || v_parametros.fecha ||'''::date,antiguedad_anterior)*/bono_antiguedad)/365,8) as indemdia,
                          round((haberBasico*frontera + haberBasico + /*plani.f_evaluar_antiguedad (fechaAntiguedad,''' || v_parametros.fecha ||'''::date,antiguedad_anterior)*/bono_antiguedad)/365,8)*diastrabajados as Indem,
                          presupuesto
                          from detalle
                          where diastrabajados >= 90';*/

        raise notice '%',v_consulta;
        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
     #TRANSACCION:  'PLA_REPOMAESBOL_SEL'
     #DESCRIPCION:	Reporte Generico de boleta de sueldos maestro
     #AUTOR:		admin
     #FECHA:		17-01-2014 22:07:28
    ***********************************/

    elsif(p_transaccion='PLA_REPOMAESBOL_SEL')then

      begin
        if (not exists(	select 1
                         from plani.treporte r
                         where r.id_tipo_planilla = v_parametros.id_tipo_planilla and r.estado_reg = 'activo' and
                               r.tipo_reporte = 'boleta')) then
          raise exception 'No existe una configurado un reporte de boleta de pago para este tipo de planilla';
        end if;

        --Sentencia de la consulta
        v_consulta:='select
                            repo.titulo_reporte,
                            plani.nro_planilla,
                            param.f_literal_periodo(per.id_periodo),
                            ges.gestion,
                            emp.nit,
                            ent.identificador_caja_salud::varchar as numero_patronal,
                            fun.desc_funcionario1::varchar as nombre,
                            (case when sum(ht.id_horas_trabajadas) is null then
                            	car.nombre
                            else
                            	pxp.list(carht.nombre || ''  ('' ||round(ht.horas_normales/8,0) || '' dias)'')
                            end)::varchar as cargo,
                            (case when sum(ht.id_horas_trabajadas) is null then
                            	car.codigo
                            else
                            	pxp.list(carht.codigo)
                            end)::varchar as item,
                            fun.codigo as codigo_empleado,
                            sum(ht.horas_normales)::integer,
                            fun.ci,fun.id_funcionario

						from plani.tplanilla plani
                        inner join param.tdepto dep on  dep.id_depto = plani.id_depto
                        inner join param.tentidad ent on  ent.id_entidad = dep.id_entidad
						inner join plani.treporte repo on  repo.id_tipo_planilla = plani.id_tipo_planilla
                        left join param.tperiodo per on per.id_periodo = plani.id_periodo
                        inner join param.tgestion ges on ges.id_gestion = plani.id_gestion
                        inner join param.tempresa emp on emp.estado_reg = ''activo''
                        inner join plani.tfuncionario_planilla planifun  on planifun.id_planilla = plani.id_planilla
                        inner join orga.vfuncionario fun on fun.id_funcionario = planifun.id_funcionario
				        inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = planifun.id_uo_funcionario
				        inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
				        left join plani.thoras_trabajadas ht on ht.id_funcionario_planilla = planifun.id_funcionario_planilla
				        left join orga.tuo_funcionario uofunht on uofunht.id_uo_funcionario = ht.id_uo_funcionario
				        left join orga.tcargo carht on carht.id_cargo = uofunht.id_cargo
				        where repo.tipo_reporte = ''boleta'' and ';

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        v_consulta:=v_consulta||' group by
							repo.titulo_reporte,
							plani.nro_planilla,
                            per.id_periodo,
                            ges.gestion,
                            emp.nit,
                            fun.desc_funcionario1,
                            car.nombre,
                            car.codigo,
                            fun.codigo,
                            fun.ci,
                            fun.id_funcionario,
                            ent.identificador_min_trabajo
			';


        return v_consulta;

      end;
    /*********************************
     #TRANSACCION:  'PLA_REPODETBOL_SEL'
     #DESCRIPCION:	Reporte Generico de planilla de sueldos detalle
     #AUTOR:		admin
     #FECHA:		17-01-2014 22:07:28
    ***********************************/

    elsif(p_transaccion='PLA_REPODETBOL_SEL')then

      begin


        --Sentencia de la consulta
        v_consulta:='select

                            repcol.titulo_reporte_superior,
                            repcol.titulo_reporte_inferior,
                            repcol.tipo_columna,
                            colval.codigo_columna,
                            colval.valor

						from plani.tfuncionario_planilla planifun
                        inner join plani.tplanilla plani on plani.id_planilla = planifun.id_planilla
						inner join plani.treporte repo on repo.id_tipo_planilla = plani.id_tipo_planilla
                        inner join plani.tcolumna_valor colval on  colval.id_funcionario_planilla = planifun.id_funcionario_planilla
                        inner join plani.treporte_columna repcol  on repcol.id_reporte = repo.id_reporte and
                        											repcol.codigo_columna = colval.codigo_columna

				        where repo.tipo_reporte = ''boleta'' and repcol.estado_reg = ''activo'' and colval.estado_reg = ''activo'' and ';

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        v_consulta:=v_consulta||' order by repcol.tipo_columna,repcol.orden asc';

        --Devuelve la respuesta
        return v_consulta;

      end;



    /*********************************
 	#TRANSACCION:  'PLA_REPODET_SEL'
 	#DESCRIPCION:	Reporte Generico de planilla de sueldos detalle
 	#AUTOR:		admin
 	#FECHA:		17-01-2014 22:07:28
	***********************************/

    elsif(p_transaccion='PLA_REPODET_SEL')then

      begin
        --para obtener la columna de ordenacion para el reporte
        execute	'select repo.ordenar_por, plani.id_planilla
           			from plani.tplanilla plani
					inner join plani.treporte repo on  repo.id_tipo_planilla = plani.id_tipo_planilla
           			where '||v_parametros.filtro into v_record;

        if (v_record.ordenar_por = 'nombre')then
          v_ordenar_por = 'fun.desc_funcionario2';
        elsif (v_record.ordenar_por = 'doc_id') then
          v_ordenar_por = 'fun.ci';
        elsif (v_record.ordenar_por = 'codigo_cargo') then
          v_ordenar_por = 'car.codigo';
        else
          v_ordenar_por = 'fun.codigo';
        end if;

		    if pxp.f_existe_parametro(p_tabla , 'tipo_contrato')then
        	v_tipo_contrato = 'tcon.codigo = '''||v_parametros.tipo_contrato||''' and ';
        else
        	v_tipo_contrato = '';
      	end if;

      	select tpl.codigo, tp.id_gestion
        into v_desc_planilla
        from plani.tplanilla tp
        inner join plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
        where tp.id_planilla = v_record.id_planilla;

		    if v_desc_planilla.codigo in ('PLAGUIN', 'PLASEGAGUI') then
            v_inner_periodo = '
            inner join param.tperiodo tper on tper.periodo = extract(''month'' from plani.fecha_planilla) and tper.id_gestion = plani.id_gestion
            left join orga.tcargo_presupuesto cp on cp.id_cargo = uofun.id_cargo and cp.id_gestion = plani.id_gestion  and
            ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)) or
            (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)))';
        else
        	v_inner_periodo = '
           	inner join param.tperiodo tper on tper.id_periodo = plani.id_periodo
            left join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.id_gestion = plani.id_gestion and cp.estado_reg = ''activo''
            and ((tper.fecha_ini between cp.fecha_ini and cp.fecha_fin) or (tper.fecha_fin between cp.fecha_ini and cp.fecha_fin))
            ';
        end if;

        --Sentencia de la consulta
        v_consulta:='select
                            fun.id_funcionario,
                            substring(fun.desc_funcionario2 from 1 for 38),
                            cat.descripcion::varchar,
                            car.codigo,
                            fun.ci,
                            uo.id_uo,

                            (uo.nombre_unidad||'' - ''||(case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''CIJ''
                            when car.codigo = ''0'' then
                            	''EVE''
                            when ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or fun.id_funcionario is null)  then
                            	''ESP''
                            when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10)) then
                            	''ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar)::varchar,

                            repcol.sumar_total,
                            repcol.ancho_columna,
                            repcol.titulo_reporte_superior,
                            repcol.titulo_reporte_inferior,
                            colval.codigo_columna,
                            colval.valor,
                            tcon.nombre,
                            (case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''5.CIJ''
                            when car.codigo = ''0'' then
                            	''6.EVE''
                            when ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or fun.id_funcionario is null)  then
                            	''3.ESP''
                            when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10)) then
                            	''1.ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''2.OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''4.COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar as categoria_prog,
                            --uofun.observaciones_finalizacion as motivo_retiro
							car.nombre cargo
						from plani.tfuncionario_planilla fp
            inner join plani.tplanilla plani on plani.id_planilla = fp.id_planilla
						inner join plani.treporte repo on repo.id_tipo_planilla = plani.id_tipo_planilla
            inner join plani.tcolumna_valor colval on  colval.id_funcionario_planilla = fp.id_funcionario_planilla
            inner join plani.treporte_columna repcol  on repcol.id_reporte = repo.id_reporte and repcol.codigo_columna = colval.codigo_columna
            inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
            inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
            inner JOIN orga.tescala_salarial es ON es.id_escala_salarial = car.id_escala_salarial
            inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
            inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = car.id_tipo_contrato
            /*inner join param.tperiodo tper on tper.id_periodo = plani.id_periodo
            left join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.id_gestion = plani.id_gestion and cp.estado_reg = ''activo''
            and ((tper.fecha_ini between cp.fecha_ini and cp.fecha_fin) or (tper.fecha_fin between cp.fecha_ini and cp.fecha_fin))*/
            '||v_inner_periodo||'
            left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
            left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
            inner join orga.vfuncionario fun on fun.id_funcionario = uofun.id_funcionario
            inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL,NULL)
				    where ';

        /*v_consulta:='select
                            fun.id_funcionario,
                            substring(fun.desc_funcionario2 from 1 for 38),
                            cat.descripcion::varchar,

                            car.codigo,
                            fun.ci,
                            uo.id_uo,
                            (uo.nombre_unidad||'' - ''||(case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''CIJ''
                            when car.codigo = ''0'' then
                            	''EVE''
                            when ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or fun.id_funcionario is null)  then
                            	''ESP''
                            when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10)) then
                            	''ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar)::varchar as nombre_unidad,
                            repcol.sumar_total,
                            repcol.ancho_columna,
                            repcol.titulo_reporte_superior,
                            repcol.titulo_reporte_inferior,
                            colval.codigo_columna,
                            colval.valor,
                            tcon.nombre,
                            (case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''5.CIJ''
                            when car.codigo = ''0'' then
                            	''6.EVE''
                            when ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or fun.id_funcionario is null)  then
                            	''3.ESP''
                            when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10)) then
                            	''1.ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''2.OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''4.COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar as categoria_prog,
                            uofun.observaciones_finalizacion as motivo_retiro

						from plani.tfuncionario_planilla fp
            inner join plani.tplanilla plani on plani.id_planilla = fp.id_planilla
						inner join plani.treporte repo on repo.id_tipo_planilla = plani.id_tipo_planilla
            inner join plani.tcolumna_valor colval on  colval.id_funcionario_planilla = fp.id_funcionario_planilla
            inner join plani.treporte_columna repcol  on repcol.id_reporte = repo.id_reporte and
                                  repcol.codigo_columna = colval.codigo_columna
            inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
            inner join orga.tcargo car on car.id_cargo = uofun.id_cargo

            inner JOIN orga.tescala_salarial es ON es.id_escala_salarial = car.id_escala_salarial
            inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

            /*inner join param.tperiodo tper on tper.periodo = extract(''month'' from plani.fecha_planilla) and tper.id_gestion = plani.id_gestion
            inner join orga.tcargo_presupuesto cp on cp.id_cargo = uofun.id_cargo and cp.id_gestion = plani.id_gestion  and
            ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)) or
            (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)))*/

            left join orga.tcargo_presupuesto cp on car.id_cargo = cp.id_cargo and cp.id_gestion = plani.id_gestion and cp.estado_reg = ''activo'' and
            ((cp.fecha_fin > ANY(plani.f_periodos_pago_prima (fp.id_funcionario,plani.id_gestion))  AND  cp.fecha_ini  <  ANY(plani.f_periodos_pago_prima (fp.id_funcionario,plani.id_gestion))) or uofun.fecha_finalizacion between  cp.fecha_ini and cp.fecha_fin)
            --(cp.fecha_fin >= current_date or cp.fecha_fin is NULL)


            left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
            left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
            inner join orga.vfuncionario fun on fun.id_funcionario = uofun.id_funcionario
            inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL,NULL)
            inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = car.id_tipo_contrato
            where '||v_tipo_contrato;*/

        /*select tpl.codigo, tp.id_gestion
        into v_desc_planilla
        from plani.tplanilla tp
        inner join plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
        where tp.id_planilla = v_record.id_planilla;

        v_id_gestion = v_desc_planilla.id_gestion;



        if v_desc_planilla.codigo = 'PLAPRI' then

        	v_cond_categoria =  '(ca.codigo = ''SUPER'' and ((fp.id_funcionario != 10 and fp.id_funcionario !=1030) or (fp.id_funcionario = 10 and tper.periodo <= 7 and (plani.id_gestion = 16 or plani.id_gestion = 15))))';
            v_cond_admin = '(cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fp.id_funcionario = 10 and (tper.periodo > 7 or plani.id_gestion >= 16))) AND fp.tipo_contrato != ''CONS''';
            v_codigo = 'car.codigo = ''0'' and fp.tipo_contrato = ''EVE''';

            v_id_gestion = v_id_gestion + 1;

            select tg.gestion
        	into v_gestion
        	from param.tgestion tg
        	where tg.id_gestion = v_id_gestion;

            v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = 6 and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto cp on cp.id_cargo = uofun.id_cargo and cp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,''31/12/'||v_gestion||'''::date)))';

            v_periodo_group = 'tper.periodo,';
        elsif v_desc_planilla.codigo in ('PLAGUIN', 'PLASEGAGUI') then

        	v_cond_categoria = '(ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or (fun.id_funcionario = 10 and tper.periodo <= 7 and plani.id_gestion = 16)))';
            v_cond_admin = '(cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10 and (tper.periodo > 7 or plani.id_gestion >= 16))) AND fp.tipo_contrato != ''CONS''';
            v_codigo = 'car.codigo = ''0'' and fp.tipo_contrato = ''EVE''';

            v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from plani.fecha_planilla) and tper.id_gestion = plani.id_gestion
                        inner join orga.tcargo_presupuesto cp on cp.id_cargo = uofun.id_cargo and cp.id_gestion = plani.id_gestion  and
                        ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)) or
                        (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)))';

        else
        	v_cond_categoria =  'ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or fun.id_funcionario is null)';
            v_cond_admin = '(cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10))';
            v_codigo = 'car.codigo = ''0''';

            v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from plani.fecha_planilla) and tper.id_gestion = plani.id_gestion
                        inner join orga.tcargo_presupuesto cp on cp.id_cargo = uofun.id_cargo and cp.id_gestion = plani.id_gestion  and
                        ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)) or
                        (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,(''31/12/''||date_part(''year'',plani.fecha_planilla))::date)))';
        end if;

        v_consulta:='select
                            fun.id_funcionario,
                            substring(fun.desc_funcionario2 from 1 for 38),
                            cat.descripcion::varchar,

                            car.codigo,
                            fun.ci,
                            uo.id_uo,
                            (uo.nombre_unidad||'' - ''||(case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''CIJ''
                            when '||v_codigo||' then
                            	''EVE''
                            when '||v_cond_categoria||'  then
                            	''ESP''
                            when '||v_cond_admin||' then
                            	''ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar)::varchar as nombre_unidad,
                            repcol.sumar_total,
                            repcol.ancho_columna,
                            repcol.titulo_reporte_superior,
                            repcol.titulo_reporte_inferior,
                            colval.codigo_columna,
                            colval.valor,
                            tcon.nombre,
                            (case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''5.CIJ''
                            when car.codigo = ''0'' then
                            	''6.EVE''
                            when ca.codigo = ''SUPER'' and (fun.id_funcionario != 10 or fun.id_funcionario is null)  then
                            	''3.ESP''
                            when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10)) then
                            	''1.ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''2.OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''4.COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar as categoria_prog

						from plani.tfuncionario_planilla fp
                        inner join plani.tplanilla plani on plani.id_planilla = fp.id_planilla
						inner join plani.treporte repo on repo.id_tipo_planilla = plani.id_tipo_planilla
                        inner join plani.tcolumna_valor colval on  colval.id_funcionario_planilla = fp.id_funcionario_planilla
                        inner join plani.treporte_columna repcol  on repcol.id_reporte = repo.id_reporte and repcol.codigo_columna = colval.codigo_columna
                        inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                        inner join orga.tcargo car on car.id_cargo = uofun.id_cargo

                        inner JOIN orga.tescala_salarial es ON es.id_escala_salarial = car.id_escala_salarial
                        inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

                        '||v_inner_periodo||'

                        /*left join orga.tcargo_presupuesto cp on car.id_cargo = cp.id_cargo and cp.id_gestion = plani.id_gestion and cp.estado_reg = ''activo'' and
						(cp.fecha_fin >= current_date or cp.fecha_fin is NULL) */


                        left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                        left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                        inner join orga.vfuncionario fun on fun.id_funcionario = uofun.id_funcionario
                        inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL,NULL)
                        inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = car.id_tipo_contrato
				        where '||v_tipo_contrato;*/

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        v_consulta:=v_consulta||' order by categoria_prog, uo.prioridad::integer, uo.id_uo,' || v_ordenar_por || ', fun.id_funcionario,repcol.orden asc';
		raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
 	#TRANSACCION:  'PLA_REPOACIT_SEL'
 	#DESCRIPCION:	Reporte Planilla actualizada Item
 	#AUTOR:		admin
 	#FECHA:		13-09-2016 17:90:28
	***********************************/

    elsif(p_transaccion='PLA_REPOACIT_SEL')then

      begin
        v_where = '';
        if (v_parametros.id_tipo_contrato <> -1) then
          v_where = v_where || ' and tc.id_tipo_contrato = ' || v_parametros.id_tipo_contrato;
        end if;

        if (v_parametros.id_uo <> -1) then
          v_where = v_where || ' and ger.id_uo = ' || v_parametros.id_uo;
        end if;
        --raise notice '%',v_where;
		select tg.id_gestion
		into v_id_gestion
        from param.tgestion tg
        where tg.gestion = date_part('year',v_parametros.fecha);

        select tp.id_periodo
        into v_id_periodo
        from param.tperiodo tp
        where tp.periodo = date_part('month',v_parametros.fecha) and tp.id_gestion = v_id_gestion;

        select count(tpl.id_planilla)
        into v_cont_pla
        from plani.tplanilla tpl
        where tpl.id_gestion = v_id_gestion and tpl.id_periodo = v_id_periodo and tpl.nro_planilla like '%PLASUE%';

        --if (select 1 from plani.tplanilla tpl where tpl.id_gestion = v_id_gestion and tpl.id_periodo = v_id_periodo and tpl.nro_planilla like '%PLASUE%') then
        if false then /*v_cont_pla = 1*/
          --Sentencia de la consulta
          v_consulta:='SELECT es.nombre AS escala,
                          i.nombre AS cargo,
                          i.codigo AS nro_item,
                          COALESCE(initcap(e.desc_funcionario2), ''ACEFALO''::text) AS nombre_empleado,
                              CASE
                                  WHEN per.genero::text = ANY (ARRAY[''varon''::character varying,''VARON''::character varying, ''Varon''::character varying]::text[]) THEN ''M''::text
                                  WHEN per.genero::text = ANY (ARRAY[''mujer''::character varying,''MUJER''::character varying, ''Mujer''::character varying]::text[]) THEN ''F''::text
                              ELSE ''''::text
                              END::character varying AS genero,
                              --es.haber_basico,
                              /*COALESCE((select coalesce(tcv.valor,0) from plani.tcolumna_valor tcv where tcv.id_funcionario_planilla = tfpl.id_funcionario_planilla and tcv.codigo_columna = ''SUELDOBA''),*/es.haber_basico,

                              /*CASE
                                  WHEN e.id_funcionario IS NOT NULL THEN round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), ''' || v_parametros.fecha ||'''::date, f.antiguedad_anterior), 2)
                              ELSE NULL::numeric
                              END AS bono_antiguedad,*/
                              coalesce(tcv.valor,0) AS bono_antiguedad,
                              CASE
                                  WHEN ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL THEN es.haber_basico * 0.2
                              ELSE 0::numeric
                              END AS bono_frontera,
                              /*es.haber_basico +
                              CASE
                              WHEN ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL THEN es.haber_basico * 0.2
                              ELSE 0::numeric
                              END +
                              CASE
                                  WHEN e.id_funcionario IS NOT NULL THEN round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), ''' || v_parametros.fecha ||'''::date, f.antiguedad_anterior), 2)
                              ELSE 0::numeric
                              END AS sumatoria,*/
                              case when ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL then (es.haber_basico + coalesce(tcv.valor,0) + es.haber_basico * 0.2) else (es.haber_basico +  coalesce(tcv.valor,0)) end AS sumatoria,
                              CASE
                                  WHEN e.id_funcionario IS NOT NULL THEN orga.f_get_fechas_ini_historico(e.id_funcionario, ''' || v_parametros.fecha ||'''::date)
                              ELSE NULL::text
                              END AS "case",
                              per.ci,
                              per.expedicion,
                              lu.codigo,
                              ofi.nombre,
                              ((ger.codigo::text || '' - ''::text) || ger.nombre_unidad::text)::character
                              varying AS "varchar",
                              dep.nombre_unidad,
                              i.id_tipo_contrato,
                              ger.prioridad AS prioridad_gerencia,
                              ger.nombre_unidad AS gerencia,
                              dep.prioridad AS prioridad_depto,
                              --dep.nombre_unidad AS departamento,
                              (case when i.id_uo = any (string_to_array(btrim(''9979,''||orga.f_get_arbol_uo(9979),'',''),'','')::integer[]) then orga.f_get_depto_arbol_uo(i.id_uo) else dep.nombre_unidad end)::varchar AS departamento,
                              (case
                              when lower(ger.nombre_unidad) like ''%cobija%'' then
                                  ''5.CIJ''
                              when i.codigo = ''0'' then
                                  ''6.EVE''
                              when ca.codigo = ''SUPER'' and ((f.id_funcionario != 10 and f.id_funcionario != 2709) or f.id_funcionario is null)  then
                                  ''3.ESP''
                              when (catp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and (f.id_funcionario = 10 or f.id_funcionario = 2709))) then
                                  ''1.ADM''
                              when catp.desc_programa ilike ''%OPE%'' then
                                  ''2.OPE''
                              when catp.desc_programa ilike ''%COM%'' then
                                  ''4.COM''
                              else
                                  ''SINCAT''
                              end
                              )::varchar as categoria_programatica,
                              to_char(ha.fecha_finalizacion,''DD/MM/YYYY'')::varchar as fecha_finalizacion,

                              CASE WHEN e.id_funcionario IS NOT NULL
                              THEN age((''' || v_parametros.fecha ||'''::date+1)::date, substring(orga.f_get_fechas_ini_historico(e.id_funcionario,''' || v_parametros.fecha ||'''::date),1,10)::date)
                              ELSE null::interval END as tiempo_empresa

                              FROM orga.tcargo i
                              inner join param.tgestion ges on (''01/01/''||ges.gestion)::date <= ''' || v_parametros.fecha ||'''::date and
                                                      (''31/12/''||ges.gestion)::date >= ''' || v_parametros.fecha ||'''::date

                              LEFT JOIN orga.tcargo_presupuesto cp on cp.id_cargo = i.id_cargo and cp.id_gestion = ges.id_gestion
                                                                      and cp.estado_reg = ''activo'' and (cp.fecha_fin >= ''' || v_parametros.fecha ||'''::date or cp.fecha_fin is NULL)




                              LEFT JOIN pre.tpresupuesto cc on cc.id_presupuesto = cp.id_centro_costo

                              LEFT JOIN pre.vcategoria_programatica catp on catp.id_categoria_programatica = cc.id_categoria_prog
                              JOIN orga.tescala_salarial es ON es.id_escala_salarial = i.id_escala_salarial
                              JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                              LEFT JOIN orga.tuo_funcionario ha ON ha.id_cargo = i.id_cargo AND ha.estado_reg::text = ''activo''::text AND
                                      (ha.fecha_finalizacion IS NULL OR ha.fecha_finalizacion >= ''' || v_parametros.fecha ||'''::date) AND ha.fecha_asignacion <= ''' || v_parametros.fecha ||'''::date AND
                                      ha.tipo=''oficial''
                              LEFT JOIN orga.vfuncionario e ON e.id_funcionario = ha.id_funcionario
                              LEFT JOIN orga.tfuncionario f ON e.id_funcionario = f.id_funcionario
                              LEFT JOIN segu.tpersona per ON per.id_persona = f.id_persona
                              LEFT JOIN orga.toficina ofi ON i.id_oficina = ofi.id_oficina
                              LEFT JOIN param.tlugar lu ON lu.id_lugar = ofi.id_lugar

                              left join plani.tplanilla tpl on tpl.id_gestion = '||v_id_gestion||' and tpl.id_periodo = '||v_id_periodo||' and tpl.nro_planilla like ''%PLASUE%''
                              left join plani.tfuncionario_planilla tfpl on tfpl.id_funcionario = ha.id_funcionario and tfpl.id_planilla = tpl.id_planilla
                              left join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfpl.id_funcionario_planilla and tcv.codigo_columna = ''BONANT''
                              --left join plani.thoras_trabajadas tht on tht.id_funcionario_planilla = tfpl.id_funcionario_planilla


                              JOIN orga.f_get_uo_prioridades(9418) uo(out_id_uo, out_nombre_unidad, out_prioridad) ON uo.out_id_uo = i.id_uo
                              JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(uo.out_id_uo, NULL::integer, NULL::date)
                              JOIN orga.tuo dep ON dep.id_uo = orga.f_get_uo_departamento(uo.out_id_uo, NULL::integer, NULL::date)
                              WHERE (i.estado_reg::text = ''activo''::text or i.id_cargo = 15757)  AND (i.id_tipo_contrato = 1 OR
                                  (i.id_tipo_contrato = 4 and e.id_funcionario is not null)) AND  ';

        elsif v_parametros.fecha < '01/03/2021'::date then

        	v_licencia = '';
          if v_parametros.licencia != '' then
            if v_parametros.licencia = 'no' then
              v_licencia = ' and ha.id_funcionario not in (select lic.id_funcionario from plani.tlicencia lic where lic.id_funcionario = ha.id_funcionario and ''' || v_parametros.fecha ||'''::date between lic.desde and lic.hasta )';
            end if;
          end if;

          v_calendario = case when v_parametros.fecha <= '31/12/2019'::date then 'month' else 'year' end;


          select pxp.list(tuo.id_funcionario::varchar)
          into v_id_gerente
          from orga.tcargo tcar
          inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
          inner join orga.tuo uo on uo.id_uo = tuo.id_uo
          where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo';

        	v_consulta:='SELECT es.nombre AS escala,
                          i.nombre AS cargo,
                          i.codigo AS nro_item,
                          COALESCE(initcap(e.desc_funcionario2), ''ACEFALO''::text) AS nombre_empleado,
                              CASE
                                  WHEN per.genero::text = ANY (ARRAY[''varon''::character varying,''VARON''::character varying, ''Varon''::character varying]::text[]) THEN ''M''::text
                                  WHEN per.genero::text = ANY (ARRAY[''mujer''::character varying,''MUJER''::character varying, ''Mujer''::character varying]::text[]) THEN ''F''::text
                              ELSE ''''::text
                              END::character varying AS genero,
                              es.haber_basico,

                              (coalesce(round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), '''||v_parametros.fecha||'''::date, f.antiguedad_anterior), 2),0))::numeric AS bono_antiguedad,
                              CASE WHEN ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL THEN es.haber_basico * 0.2
                              ELSE 0::numeric
                              END AS bono_frontera,

                              case when ofi.frontera = ''si'' and e.id_funcionario is not null then
                              (es.haber_basico + coalesce(round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), '''||v_parametros.fecha||'''::date, f.antiguedad_anterior), 2),0) + es.haber_basico * 0.2)::numeric
                              else (es.haber_basico + coalesce(round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), '''||v_parametros.fecha||'''::date, f.antiguedad_anterior), 2),0))::numeric end AS sumatoria,

                              CASE
                                  WHEN e.id_funcionario IS NOT NULL THEN orga.f_get_fechas_ini_historico(e.id_funcionario, ''' || v_parametros.fecha ||'''::date)
                              ELSE NULL::text
                              END AS "case",
                              per.ci,
                              per.expedicion,
                              lu.codigo,
                              ofi.nombre,
                              ((ger.codigo::text || '' - ''::text) || ger.nombre_unidad::text)::character varying AS "varchar",
                              dep.nombre_unidad,
                              i.id_tipo_contrato,
                              ger.prioridad AS prioridad_gerencia,

                              case when ger.nombre_unidad = ''Gerencia de Operaciones'' then ''Gerencia de Operaciones A.I.'' else ger.nombre_unidad end AS gerencia,
                              dep.prioridad AS prioridad_depto,

                              (case when i.id_uo = any (string_to_array(btrim(''9979,''||orga.f_get_arbol_uo(9979),'',''),'','')::integer[]) then orga.f_get_depto_arbol_uo(i.id_uo) else dep.nombre_unidad end)::varchar AS departamento,

                              (case
                              when lower(ger.nombre_unidad) like ''%cobija%'' then
                                  ''6.CIJ''
                              when i.codigo = ''0'' then
                                  ''5.EVE''
                              when ca.codigo = ''SUPER'' and (f.id_funcionario not in ('||v_id_gerente||') or f.id_funcionario is null)  then
                                  ''3.ESP''
                              when (catp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and f.id_funcionario in ('||v_id_gerente||'))) then
                                  ''1.ADM''
                              when catp.desc_programa ilike ''%OPE%'' then
                                  ''2.OPE''
                              when catp.desc_programa ilike ''%COM%'' then
                                  ''4.COM''
                              else
                                  ''SINCAT''
                              end
                              )::varchar as categoria_programatica,

                              to_char(ha.fecha_finalizacion,''DD/MM/YYYY'')::varchar as fecha_finalizacion,

                              CASE WHEN e.id_funcionario IS NOT NULL
                              THEN age((''' || v_parametros.fecha ||'''::date+1)::date, substring(orga.f_get_fechas_ini_historico(e.id_funcionario,''' || v_parametros.fecha ||'''::date),1,10)::date)
                              ELSE null::interval END as tiempo_empresa

                              FROM orga.tcargo i

                              LEFT JOIN orga.tcargo_presupuesto cp on cp.id_cargo = i.id_cargo and cp.id_gestion = '||v_id_gestion||'
                              /*and cp.estado_reg = ''activo''*/ and (cp.fecha_fin >= ''' || v_parametros.fecha ||'''::date or cp.fecha_fin is NULL)

                              LEFT JOIN pre.tpresupuesto cc on cc.id_presupuesto = cp.id_centro_costo

                              LEFT JOIN pre.vcategoria_programatica catp on catp.id_categoria_programatica = cc.id_categoria_prog
                              JOIN orga.tescala_salarial es ON es.id_escala_salarial = i.id_escala_salarial
                              JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

                              LEFT JOIN orga.tuo_funcionario ha ON ha.id_cargo = i.id_cargo AND ha.estado_reg::text = ''activo''::text AND
                              (ha.fecha_finalizacion IS NULL OR ha.fecha_finalizacion >= ''' || v_parametros.fecha ||'''::date) AND
                              ha.fecha_asignacion <= ''' || v_parametros.fecha ||'''::date AND ha.tipo=''oficial''

                              LEFT JOIN orga.vfuncionario e ON e.id_funcionario = ha.id_funcionario
                              LEFT JOIN orga.tfuncionario f ON e.id_funcionario = f.id_funcionario
                              LEFT JOIN segu.tpersona per ON per.id_persona = f.id_persona
                              LEFT JOIN orga.toficina ofi ON i.id_oficina = ofi.id_oficina
                              LEFT JOIN param.tlugar lu ON lu.id_lugar = ofi.id_lugar


                              JOIN orga.f_get_uo_prioridades(9418) uo(out_id_uo, out_nombre_unidad, out_prioridad) ON uo.out_id_uo = i.id_uo
                              JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(uo.out_id_uo, NULL::integer, NULL::date)
                              JOIN orga.tuo dep ON dep.id_uo = orga.f_get_uo_departamento(uo.out_id_uo, NULL::integer, NULL::date)
                              WHERE case when coalesce(i.fecha_fin,''31/12/9999''::date) between date_trunc('''||v_calendario||''',''' || v_parametros.fecha ||'''::date) and ''' || v_parametros.fecha ||'''::date then i.estado_reg = ''inactivo''
			                              else ((i.estado_reg::text = ''inactivo''::text or i.id_cargo = 15757) and i.fecha_ini <= '''||v_parametros.fecha||'''::date) end AND (i.id_tipo_contrato = 1 OR
                                    (i.id_tipo_contrato = 4 and e.id_funcionario is not null)) '||v_licencia||' and ';


        else
          v_licencia = '';
          if v_parametros.licencia != '' then
            if v_parametros.licencia = 'no' then
              v_licencia = ' and ha.id_funcionario not in (select lic.id_funcionario from plani.tlicencia lic where lic.id_funcionario = ha.id_funcionario and ''' || v_parametros.fecha ||'''::date between lic.desde and lic.hasta )';
            end if;
          end if;

          v_calendario = case when v_parametros.fecha <= '31/12/2019'::date then 'month' else 'year' end;

          /*select tuo.id_funcionario
          into v_id_gerente
          from  orga.tuo_funcionario tuo
          inner join orga.tcargo tca on tca.id_cargo = tuo.id_cargo
          where  tuo.estado_reg = 'activo' and  tca.codigo = '1' and tca.estado_reg = 'activo' and  v_parametros.fecha::date <= coalesce (tuo.fecha_finalizacion,'31/12/9999'::date);*/

          select pxp.list(tuo.id_funcionario::varchar)
          into v_id_gerente
          from orga.tcargo tcar
          inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
          inner join orga.tuo uo on uo.id_uo = tuo.id_uo
          where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo';

        	v_consulta:='SELECT es.nombre AS escala,
                          i.nombre AS cargo,
                          i.codigo AS nro_item,
                          COALESCE(initcap(e.desc_funcionario2), ''ACEFALO''::text) AS nombre_empleado,
                              CASE
                                  WHEN per.genero::text = ANY (ARRAY[''varon''::character varying,''VARON''::character varying, ''Varon''::character varying]::text[]) THEN ''M''::text
                                  WHEN per.genero::text = ANY (ARRAY[''mujer''::character varying,''MUJER''::character varying, ''Mujer''::character varying]::text[]) THEN ''F''::text
                              ELSE ''''::text
                              END::character varying AS genero,
                              es.haber_basico,

                              (coalesce(round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), '''||v_parametros.fecha||'''::date, f.antiguedad_anterior), 2),0))::numeric AS bono_antiguedad,
                              CASE WHEN ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL THEN es.haber_basico * 0.2
                              ELSE 0::numeric
                              END AS bono_frontera,

                              case when ofi.frontera = ''si'' and e.id_funcionario is not null then
                              (es.haber_basico + coalesce(round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), '''||v_parametros.fecha||'''::date, f.antiguedad_anterior), 2),0) + es.haber_basico * 0.2)::numeric
                              else (es.haber_basico + coalesce(round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), '''||v_parametros.fecha||'''::date, f.antiguedad_anterior), 2),0))::numeric end AS sumatoria,

                              CASE
                                  WHEN e.id_funcionario IS NOT NULL THEN orga.f_get_fechas_ini_historico(e.id_funcionario, ''' || v_parametros.fecha ||'''::date)
                              ELSE NULL::text
                              END AS "case",
                              per.ci,
                              per.expedicion,
                              lu.codigo,
                              ofi.nombre,
                              ((ger.codigo::text || '' - ''::text) || ger.nombre_unidad::text)::character varying AS "varchar",
                              dep.nombre_unidad,
                              --case when dep.nombre_unidad = ''Gerencia de Operaciones'' then '''' else dep.nombre_unidad end as nombre_unidad,
                              i.id_tipo_contrato,
                              ger.prioridad AS prioridad_gerencia,
                              --ger.nombre_unidad AS gerencia,
                              case when ger.nombre_unidad = ''Gerencia de Operaciones'' then ''Gerencia de Operaciones A.I.'' else ger.nombre_unidad end AS gerencia,
                               dep.prioridad AS prioridad_depto,
                               --dep.nombre_unidad AS departamento
                              (case when i.id_uo = any (string_to_array(btrim(''10401,''||orga.f_get_arbol_uo(10401),'',''),'','')::integer[]) then orga.f_get_depto_arbol_uo(i.id_uo) else dep.nombre_unidad end)::varchar AS departamento,

                              (case
                              when lower(ger.nombre_unidad) like ''%cobija%'' then
                                  ''6.CIJ''
                              when i.codigo = ''0'' then
                                  ''5.EVE''
                              when ca.codigo = ''SUPER'' and (f.id_funcionario not in ('||v_id_gerente||') or f.id_funcionario is null)  then
                                  ''3.ESP''
                              when (catp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and f.id_funcionario in ('||v_id_gerente||'))) then
                                  ''1.ADM''
                              when catp.desc_programa ilike ''%OPE%'' then
                                  ''2.OPE''
                              when catp.desc_programa ilike ''%COM%'' then
                                  ''4.COM''
                              else
                                  ''SINCAT''
                              end
                              )::varchar as categoria_programatica,

                              to_char(ha.fecha_finalizacion,''DD/MM/YYYY'')::varchar as fecha_finalizacion,

                              CASE WHEN e.id_funcionario IS NOT NULL
                              THEN age((''' || v_parametros.fecha ||'''::date+1)::date, substring(orga.f_get_fechas_ini_historico(e.id_funcionario,''' || v_parametros.fecha ||'''::date),1,10)::date)
                              ELSE null::interval END as tiempo_empresa

                              FROM orga.tcargo i
                              inner join param.tgestion ges on (''01/01/''||ges.gestion)::date <= ''' || v_parametros.fecha ||'''::date and
                                                      (''31/12/''||ges.gestion)::date >= ''' || v_parametros.fecha ||'''::date

                              LEFT JOIN orga.tcargo_presupuesto cp on cp.id_cargo = i.id_cargo and cp.id_gestion = ges.id_gestion
                              and cp.estado_reg = ''activo'' and (cp.fecha_fin >= ''' || v_parametros.fecha ||'''::date or cp.fecha_fin is NULL)

                              LEFT JOIN pre.tpresupuesto cc on cc.id_presupuesto = cp.id_centro_costo

                              LEFT JOIN pre.vcategoria_programatica catp on catp.id_categoria_programatica = cc.id_categoria_prog
                              JOIN orga.tescala_salarial es ON es.id_escala_salarial = i.id_escala_salarial
                              JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

                              LEFT JOIN orga.tuo_funcionario ha ON ha.id_cargo = i.id_cargo AND ha.estado_reg::text = ''activo''::text AND
                              (ha.fecha_finalizacion IS NULL OR ha.fecha_finalizacion >= ''' || v_parametros.fecha ||'''::date) AND
                              ha.fecha_asignacion <= ''' || v_parametros.fecha ||'''::date AND ha.tipo=''oficial''

                              LEFT JOIN orga.vfuncionario e ON e.id_funcionario = ha.id_funcionario
                              LEFT JOIN orga.tfuncionario f ON e.id_funcionario = f.id_funcionario
                              LEFT JOIN segu.tpersona per ON per.id_persona = f.id_persona
                              LEFT JOIN orga.toficina ofi ON i.id_oficina = ofi.id_oficina
                              LEFT JOIN param.tlugar lu ON lu.id_lugar = ofi.id_lugar


                              JOIN orga.f_get_uo_prioridades(10112) uo(out_id_uo, out_nombre_unidad, out_prioridad) ON uo.out_id_uo = i.id_uo
                              JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(uo.out_id_uo, NULL::integer, NULL::date)
                              JOIN orga.tuo dep ON dep.id_uo = orga.f_get_uo_departamento(uo.out_id_uo, NULL::integer, NULL::date)
                              WHERE case when coalesce(i.fecha_fin,''31/12/9999''::date) between date_trunc('''||v_calendario||''',''' || v_parametros.fecha ||'''::date) and ''' || v_parametros.fecha ||'''::date then i.estado_reg = ''inactivo''
			                              else (((i.estado_reg::text = ''activo''::text and coalesce(i.fecha_fin,''31/12/9999''::date) >= '''||v_parametros.fecha||'''::date ) or i.id_cargo = 15757) and i.fecha_ini <= '''||v_parametros.fecha||'''::date) end AND (i.id_tipo_contrato = 1 OR
                                    (i.id_tipo_contrato = 4 and e.id_funcionario is not null)) '||v_licencia||' and ';

        end if;

        				/*v_consulta = '
          				SELECT

                        es.nombre AS escala,
    					i.nombre AS cargo,
    					i.codigo AS nro_item,
    					COALESCE(initcap(e.desc_funcionario2), ''ACEFALO''::text) AS nombre_empleado,
                        	CASE
           			 			WHEN per.genero::text = ANY (ARRAY[''varon''::character varying,''VARON''::character varying, ''Varon''::character varying]::text[]) THEN ''M''::text
            					WHEN per.genero::text = ANY (ARRAY[''mujer''::character varying,''MUJER''::character varying, ''Mujer''::character varying]::text[]) THEN ''F''::text
           					ELSE ''''::text
        					END::character varying AS genero,
                            es.haber_basico,
        					CASE
            					WHEN e.id_funcionario IS NOT NULL THEN round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), ''' || v_parametros.fecha ||'''::date, f.antiguedad_anterior), 2)
           		 			ELSE NULL::numeric
        					END AS bono_antiguedad,
        					CASE
            					WHEN ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL THEN es.haber_basico * 0.2
            				ELSE NULL::numeric
        					END AS bono_frontera,es.haber_basico +
        					CASE
            				WHEN ofi.frontera = ''si'' AND e.id_funcionario IS NOT NULL THEN es.haber_basico * 0.2
            				ELSE 0::numeric
        					END +
        					CASE
            					WHEN e.id_funcionario IS NOT NULL THEN round(plani.f_evaluar_antiguedad(plani.f_get_fecha_primer_contrato_empleado(ha.id_uo_funcionario, ha.id_funcionario, ha.fecha_asignacion), ''' || v_parametros.fecha ||'''::date, f.antiguedad_anterior), 2)
            				ELSE 0::numeric
        					END AS sumatoria,
        					CASE
            					WHEN e.id_funcionario IS NOT NULL THEN orga.f_get_fechas_ini_historico(e.id_funcionario, ''' || v_parametros.fecha ||'''::date)
            				ELSE NULL::text
        					END AS "case",
    						per.ci,
    						per.expedicion,
    						lu.codigo,
   							ofi.nombre,
    						((ger.codigo::text || '' - ''::text) || ger.nombre_unidad::text)::varchar AS "varchar",
    						dep.nombre_unidad,
    						i.id_tipo_contrato,
                            ger.prioridad AS prioridad_gerencia,
                            ger.nombre_unidad AS gerencia,
                            dep.prioridad AS prioridad_depto,
                            --dep.nombre_unidad AS departamento,
                            orga.f_get_depto_arbol_uo(tuo1.id_uo)::varchar as departamento,
                            (case
                            when lower(ger.nombre_unidad) like ''%cobija%'' then
                            	''5.CIJ''
                            when i.codigo = ''0'' then
                            	''6.EVE''
                            when ca.codigo = ''SUPER'' and f.id_funcionario != 10 then
                            	''3.ESP''
                            when (catp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and f.id_funcionario = 10)) then
                            	''1.ADM''
                            when catp.desc_programa ilike ''%OPE%'' then
                            	''2.OPE''
                            when catp.desc_programa ilike ''%COM%'' then
                            	''4.COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar as categoria_programatica,
                            to_char(ha.fecha_finalizacion,''DD/MM/YYYY'')::varchar as fecha_finalizacion,
                            tnor.numero_nivel as nivel,
                            (''(''||ttc.codigo||'')''||ttc.descripcion)::varchar as centro_costo,
                            catp.codigo_categoria::varchar as categoria_codigo
							FROM orga.tcargo i
                            inner join param.tgestion ges on (''01/01/''||ges.gestion)::date <= ''' || v_parametros.fecha ||'''::date and
                            						(''31/12/''||ges.gestion)::date >= ''' || v_parametros.fecha ||'''::date
                            LEFT JOIN orga.tcargo_presupuesto cp on cp.id_cargo = i.id_cargo and cp.id_gestion = ges.id_gestion
                            										and cp.estado_reg = ''activo'' and (cp.fecha_fin >= ''' || v_parametros.fecha ||'''::date or cp.fecha_fin is NULL)
                            LEFT JOIN pre.tpresupuesto cc on cc.id_presupuesto = cp.id_centro_costo


                            LEFT JOIN pre.vcategoria_programatica catp on catp.id_categoria_programatica = cc.id_categoria_prog
                            INNER JOIN orga.tescala_salarial es ON es.id_escala_salarial = i.id_escala_salarial
                            INNER JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
   							LEFT JOIN orga.tuo_funcionario ha ON ha.id_cargo = i.id_cargo AND ha.estado_reg::text = ''activo''::text AND
                            		(ha.fecha_finalizacion IS NULL OR ha.fecha_finalizacion >= ''' || v_parametros.fecha ||'''::date) AND ha.fecha_asignacion <= ''' || v_parametros.fecha ||'''::date AND
                                    ha.tipo=''oficial''

                            LEFT join param.tcentro_costo tcc on tcc.id_centro_costo = cp.id_centro_costo --and tcc.id_gestion = 16
							LEFT join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc

                            LEFT JOIN orga.vfuncionario e ON e.id_funcionario = ha.id_funcionario
                            LEFT JOIN orga.tfuncionario f ON f.id_funcionario = e.id_funcionario
                            LEFT JOIN segu.tpersona per ON per.id_persona = f.id_persona
                            LEFT JOIN orga.toficina ofi ON ofi.id_oficina =  i.id_oficina
                            LEFT JOIN param.tlugar lu ON lu.id_lugar = ofi.id_lugar
   							--JOIN orga.f_get_uo_prioridades(9418) uo(out_id_uo, out_nombre_unidad, out_prioridad) ON uo.out_id_uo = i.id_uo
                            inner join unnest(string_to_array(btrim(''9419,''||orga.f_get_arbol_uo(9419),'',''),'','')::integer[]) tu2 on tu2.* = i.id_uo
                            inner join orga.tuo tuo1 on tuo1.id_uo = tu2.*
                            LEFT JOIN orga.tnivel_organizacional tnor on tnor.id_nivel_organizacional = tuo1.id_nivel_organizacional
   							LEFT JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(tuo1.id_uo, NULL::integer, NULL::date)
   							LEFT JOIN orga.tuo dep ON dep.id_uo = orga.f_get_uo_departamento(tuo1.id_uo, NULL::integer, NULL::date)
							WHERE i.estado_reg::text = ''activo''::text AND (i.id_tipo_contrato = 1 OR
                            	(i.id_tipo_contrato = 4 and e.id_funcionario is not null)) AND ';  */

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        if (v_parametros.agrupar_por = 'Organigrama') then
          v_consulta:=v_consulta||'ORDER BY categoria_programatica, uo.out_prioridad, es.haber_basico DESC, e.desc_funcionario2';
          --v_consulta = v_consulta||'ORDER BY categoria_programatica, centro_costo, es.haber_basico DESC , tnor.numero_nivel';
        elsif (v_parametros.agrupar_por = 'Regional') then
          v_consulta:=v_consulta||'ORDER BY categoria_programatica, lu.codigo, e.desc_funcionario2';
        else
          v_consulta:=v_consulta||'ORDER BY categoria_programatica, lu.codigo,ofi.nombre, e.desc_funcionario2';
        end if;

        /*if (v_parametros.agrupar_por = 'Organigrama') then
          v_consulta:=v_consulta||'ORDER BY tuo.categoria_programatica, tuo.centro_costo, tuo.haber_basico DESC , tuo.nivel, tuo.haber_basico DESC';
        end if;*/


        --Devuelve la respuesta
        raise notice '%',v_consulta;
        return v_consulta;

      end;
    /*********************************
 	#TRANSACCION:  'PLA_REP_CONTACT_SEL'
 	#DESCRIPCION:	reporte de datos de contacto Funcionarios
 	#AUTOR:		f.e.a
 	#FECHA:		31-7-2018 17:29:14
	***********************************/

	elsif(p_transaccion='PLA_REP_CONTACT_SEL')then

    	begin

        	create temp table tt_repo_filtro(
              id_funcionario integer,
              fecha_asignacion date
       		)on commit drop;


            v_consulta = 'insert into tt_repo_filtro
            select  tuo.id_funcionario, max(tuo.fecha_asignacion)
            from orga.tuo_funcionario tuo
            group by  tuo.id_funcionario';

            if(v_parametros.oficina != '0')then
            	v_filtro = ' and tl.id_lugar in ('||v_parametros.oficina||')';
            end if;

            v_mes = date_part('month', current_date);

            select tg.id_gestion
            into v_id_gestion
            from param.tgestion tg
            where tg.gestion = date_part('year', current_date);

            select tp.fecha_ini, tp.fecha_fin
            into v_fechas
            from param.tperiodo tp
            where tp.periodo = v_mes and tp.id_gestion = v_id_gestion;


    		--Sentencia de la consulta
			v_consulta:='select distinct (''(''||tuo.codigo||'')''||tuo.nombre_unidad)::varchar as gerencia,
             ttc.nombre as contrato ,
             tf.desc_funcionario2::varchar AS desc_funcionario,
             tc.nombre as cargo,
             tl.nombre as lugar,
             tl.codigo,
             tf.email_empresa,
             tpe.correo,
             (tpe.telefono1 || coalesce('' - ''||tpe.telefono2, ''''))::varchar as telefonos,
             (tpe.celular1 || coalesce('' - ''||tpe.celular2, ''''))::varchar as celulares,
             (tpe.ci ||'' ''||tpe.expedicion)::varchar as documento,
             tl.nombre as lugar_trabajo,
             tof.nombre as nombre_oficina
             from orga.vfuncionario_persona tf
             inner JOIN orga.tuo_funcionario uof ON uof.id_funcionario = tf.id_funcionario
             AND current_date < coalesce (uof.fecha_finalizacion, ''31/12/9999''::date) and uof.estado_reg = ''activo'' /*AND
             uof.fecha_asignacion  in (select fecha_asignacion
                                                        from tt_repo_filtro where id_funcionario = tf.id_funcionario)*/
             inner JOIN orga.tuo tuo on tuo.id_uo = orga.f_get_uo_gerencia(uof.id_uo,uof.id_funcionario,current_date)
             inner JOIN orga.tcargo tc ON tc.id_cargo = uof.id_cargo
             inner join orga.toficina tof on tof.id_oficina = tc.id_oficina
             inner join param.tlugar tl on tl.id_lugar = tof.id_lugar
             inner join orga.ttipo_contrato ttc on ttc.id_tipo_contrato = tc.id_tipo_contrato
             INNER JOIN segu.tpersona tpe ON tpe.id_persona = tf.id_persona
             where tc.estado_reg = ''activo'' and ttc.codigo in (''PLA'',''EVE'',''PEXT'', ''PEXTE'') and uof.tipo IN (''oficial'') '||v_filtro||'
             order by tl.codigo, gerencia, desc_funcionario';

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;
    /*********************************
 	#TRANSACCION:  'PLA_REP_CONTACT_SEL'
 	#DESCRIPCION:	Reporte Presupuesto por categoria Programatica
 	#AUTOR:		f.e.a
 	#FECHA:		10-8-2018 17:29:14
	***********************************/

	elsif(p_transaccion='PLA_REP_PRE_CP_SEL')then

    	begin

        	/*SELECT max(tp.id_planilla)
            into v_id_planilla_retroactivo
            FROM plani.tplanilla tp
            inner join plani.ttipo_planilla ttp on ttp.id_tipo_planilla = tp.id_tipo_planilla
            WHERE ttp.codigo = 'PLAREISU';

            SELECT tp.fecha_planilla
            into v_fecha_planilla
            FROM plani.tplanilla tp
            WHERE tp.id_planilla = v_id_planilla_retroactivo;

            v_fecha_inicio = ('1/1/'||date_part('year', v_fecha_planilla))::date;
            v_fecha_final = ('30/04/'||date_part('year', v_fecha_planilla))::date;*/

            select tg.gestion
            into v_gestion
            from param.tgestion tg
            where tg.id_gestion = v_parametros.id_gestion;


            v_fecha_inicio = ('01/01/'||v_gestion)::date;

            if v_gestion < date_part('year',current_date) then
            	v_fecha_final = ('31/12/'||v_gestion)::date;
            else
            	v_fecha_final = current_date;
            end if;

            if v_parametros.estado = 'activo' then
            	v_filtro = '';
            else
            	v_filtro = '';
            end if;

        	create temp table tt_plani_filtro (
    			id_uo_funcionario 			integer,
                id_cargo					integer,
                id_funcionario_planilla 	integer,
                id_centro_costo 			integer,
                id_funcionario				integer,
                fecha_ini					date,
                fecha_fin					date,
                id_uo						integer
    		) on commit drop;

            for v_funcionario in select
                                    tuo.id_uo_funcionario,
                                    tuo.id_funcionario,
                                    tuo.id_cargo,
                                    tfp.id_funcionario_planilla,
                                    tcc.id_centro_costo,
                                    ttc.id_tipo_cc,
                                    ttc.codigo as codigo_pres,
                                    tuo.fecha_asignacion,
                                    tuo.fecha_finalizacion,
                                    tuo.id_uo,
                                    tp.fecha_planilla
                                  from plani.tplanilla tp
                                  inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla

                                  inner join orga.tuo_funcionario tuo on tuo.id_funcionario = tfp.id_funcionario and
								  tuo.fecha_asignacion <= v_fecha_final and (tuo.fecha_finalizacion is null or tuo.fecha_finalizacion >= v_fecha_inicio)

                                  inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuo.id_cargo and
                                  tcp.id_gestion =  (select (case when tg.id_gestion >= 16 then tg.id_gestion else (select tge.id_gestion from param.tgestion tge where tge.gestion = extract(year from current_date)) end)  from param.tgestion tg where tg.gestion = extract(year from tuo.fecha_asignacion))
                                  inner join param.tcentro_costo tcc on tcc.id_centro_costo = tcp.id_centro_costo
                                  inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc
                                  where tp.id_planilla = v_id_planilla_retroactivo and tuo.tipo = 'oficial' and tuo.estado_reg = 'activo'
                                  order by tfp.id_funcionario, tuo.fecha_asignacion ASC loop



                if((((v_funcionario.fecha_asignacion between v_fecha_inicio and v_fecha_final) or (v_funcionario.fecha_finalizacion between v_fecha_inicio and v_fecha_final)) or v_funcionario.fecha_finalizacion is null) or (v_id_funcionario != v_funcionario.id_funcionario or v_codigo_pres != v_funcionario.codigo_pres))then
                  --if(v_codigo_pres != v_funcionario.codigo_pres)then
                  /*if(v_funcionario.id_funcionario  = 2035 and v_funcionario.id_uo_funcionario = 9335)then
                      RAISE EXCEPTION 'id_funcionario: %, %', v_funcionario.id_funcionario, v_funcionario.id_uo_funcionario;
                  end if;*/
                      v_cont_pres  = v_cont_pres + 1;
                      insert into tt_plani_filtro(
                          id_uo_funcionario,
                          id_cargo,
                          id_funcionario_planilla,
                          id_centro_costo,
                          id_funcionario,
                          fecha_ini,
                          fecha_fin,
                          id_uo
                      ) values (
                          v_funcionario.id_uo_funcionario,
                          v_funcionario.id_cargo,
                          v_funcionario.id_funcionario_planilla,
                          v_funcionario.id_centro_costo,
                          v_funcionario.id_funcionario,
                          v_funcionario.fecha_asignacion,
                          v_funcionario.fecha_finalizacion,
                          v_funcionario.id_uo
                      );
                  --end if;

                end if;
                v_codigo_pres = v_funcionario.codigo_pres;
                v_id_funcionario = v_funcionario.id_funcionario;
            end loop;
            raise notice 'v_cont_pres: %', v_cont_pres;
    		--Sentencia de la consulta
			v_consulta:=' select
            				tcon.codigo as tipo_contrato,
                          	vcp.descripcion::varchar as categoria_prog,
                            ttc.codigo::varchar as codigo_pres,
                            ttc.descripcion::varchar as presupuesto,
                            vf.desc_funcionario2::varchar as desc_func,
                            vf.ci,
                            tca.nombre as nombre_cargo,
                            tp.fecha_ini,
                            case when tp.fecha_fin is null then ''30/4/2019''::date else tp.fecha_fin end as fecha_fin,
                            EXTRACT(month from tht.fecha_ini::date)::varchar as periodo,
                            tcv.codigo_columna,
                            tcd.valor,
                            (case
                              when lower(uo.nombre_unidad) like ''%cobija%'' then
                                  ''5.CIJ''
                              when ca.codigo = ''0'' then
                                  ''6.EVE''
                              when ca.codigo = ''SUPER'' and (vf.id_funcionario != 10 or vf.id_funcionario is null)  then
                                  ''3.ESP''
                              when (vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario = 10)) then
                                  ''1.ADM''
                              when vcp.desc_programa ilike ''%OPE%'' then
                                  ''2.OPE''
                              when vcp.desc_programa ilike ''%COM%'' then
                                  ''4.COM''
                              else
                                  ''SINCAT''
                              end
                              )::varchar as modalidad
                          from tt_plani_filtro tp
                          inner join orga.vfuncionario vf on vf.id_funcionario = tp.id_funcionario

                          inner join orga.tcargo tca on tca.id_cargo = tp.id_cargo

                          INNER JOIN orga.tescala_salarial es ON es.id_escala_salarial = tca.id_escala_salarial
                          INNER JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

                          inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = tca.id_tipo_contrato

                          inner join param.tcentro_costo tcc on tcc.id_centro_costo = tp.id_centro_costo
                          inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc

                          inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tp.id_funcionario_planilla and tcv.codigo_columna IN (''REISUELDOBA'', ''REINBANT'',''BONFRONTERA'')

                          inner join plani.tcolumna_detalle tcd on tcd.id_columna_valor = tcv.id_columna_valor

                          inner join plani.thoras_trabajadas tht on  tht.id_horas_trabajadas = tcd.id_horas_trabajadas and tht.id_uo_funcionario = tp.id_uo_funcionario

                          --inner join param.tperiodo tper on (tper.fecha_ini BETWEEN (''1/''||EXTRACT(MONTH FROM tht.fecha_ini)||''/''||EXTRACT(YEAR FROM tht.fecha_ini))::DATE AND tht.fecha_ini) and tper.fecha_fin BETWEEN (''1/''||EXTRACT(MONTH FROM tht.fecha_fin)||''/''||EXTRACT(YEAR FROM tht.fecha_fin))::DATE AND tht.fecha_fin
        				  INNER JOIN param.tperiodo tper on to_char(tper.fecha_ini ,''mm/YYYY'')  = to_char(tht.fecha_ini ,''mm/YYYY'') and  to_char(tper.fecha_fin ,''mm/YYYY'') = to_char(tht.fecha_fin, ''mm/YYYY'')

                          INNER JOIN pre.tpresupuesto tpre ON tpre.id_presupuesto = tcc.id_centro_costo
                          INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tpre.id_categoria_prog

                          inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tp.id_uo, NULL,NULL)

                          ORDER BY tcon.codigo, modalidad asc, vcp.descripcion, ttc.descripcion, vf.desc_funcionario2, tcv.codigo_columna, periodo asc
                        	--left join plani.tfuncionario_planilla tfp on tfp.id_funcionario_planilla = tp.id_funcionario_planilla
                          ';

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;
    /*********************************
 	#TRANSACCION:  'PLA_REP_AGUI_SEL'
 	#DESCRIPCION:	reporte planilla aguinaldo v2018
 	#AUTOR:		f.e.a
 	#FECHA:		4-12-2018 17:29:14
	***********************************/

	elsif(p_transaccion='PLA_REP_AGUI_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
                            fun.id_funcionario,
                            fun.codigo::varchar as codigo_empleado,
                            fun.desc_funcionario2::varchar as nombre_empleado,
                            cat.descripcion::varchar,
                            car.codigo as codigo_cargo,
                            fun.ci,
                            uo.id_uo,
                            uo.nombre_unidad as gerencia,
                            (case
                            when lower(uo.nombre_unidad) like ''%cobija%'' then
                            	''5.CIJ''
                            when car.codigo = ''0'' then
                            	''6.EVE''
                            when ca.codigo = ''SUPER'' and (fun.id_funcionario != 10  or fun.id_funcionario is null)  then
                            	''3.ESP''
                            when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fun.id_funcionario = 10 )) then
                            	''1.ADM''
                            when cat.desc_programa ilike ''%OPE%'' then
                            	''2.OPE''
                            when cat.desc_programa ilike ''%COM%'' then
                            	''4.COM''
                            else
                            	''SINCAT''
                            end
                            )::varchar as categoria_prog,
                            repcol.sumar_total,
                            repcol.ancho_columna,
                            repcol.titulo_reporte_superior,
                            repcol.titulo_reporte_inferior,
                            colval.codigo_columna,
                            colval.valor as valor_columna

						from plani.tplanilla plani
            inner join plani.tfuncionario_planilla fp on fp.id_planilla = plani.id_planilla
						inner join plani.treporte repo on repo.id_tipo_planilla = plani.id_tipo_planilla
            inner join plani.tcolumna_valor colval on  colval.id_funcionario_planilla = fp.id_funcionario_planilla
            inner join plani.treporte_columna repcol  on repcol.id_reporte = repo.id_reporte and repcol.codigo_columna = colval.codigo_columna
            inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
            inner join orga.tcargo car on car.id_cargo = uofun.id_cargo

            inner JOIN orga.tescala_salarial es ON es.id_escala_salarial = car.id_escala_salarial and es.estado_reg = ''activo''
            inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial and ca.estado_reg = ''activo''

            inner join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.id_gestion = '||v_parametros.id_gestion||' and cp.estado_reg = ''activo'' and (cp.fecha_fin >= current_date or cp.fecha_fin is NULL)
            --left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
            INNER JOIN pre.tpresupuesto	pre ON pre.id_centro_costo = cp.id_centro_costo
            inner join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
            inner join orga.vfuncionario fun on fun.id_funcionario = uofun.id_funcionario
            inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL,NULL)
				    where  plani.modalidad = '''||v_parametros.modalidad||''' and plani.id_gestion = '||v_parametros.id_gestion||' and repo.id_reporte = 7
            order by categoria_prog asc, fun.desc_funcionario2 asc, repcol.orden asc';

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;
    /*********************************
 	#TRANSACCION:  'PLA_REP_RCIVA_SEL'
 	#DESCRIPCION:	reporte RC IVA
 	#AUTOR:		franklin.espinoza
 	#FECHA:		19-07-2019 17:29:14
	***********************************/

	elsif(p_transaccion='PLA_REP_RCIVA_SEL')then

    	begin

    	if pxp.f_existe_parametro(p_tabla, 'id_gestion') and pxp.f_existe_parametro(p_tabla, 'id_periodo') then
        v_where = 'plani.id_gestion = '||v_parametros.id_gestion||' and plani.id_periodo = '||v_parametros.id_periodo;
      else
        v_where = v_parametros.filtro;
      end if;
    		--Sentencia de la consulta

      select per.fecha_fin
      into v_fecha_fin
      from param.tperiodo per
      where per.id_periodo = v_parametros.id_periodo;

    	v_calendario = case when v_fecha_fin <= '31/12/2019'::date then 'month' else 'year' end;
		--raise 'a: %, b: %', v_calendario, v_fecha_fin;
			v_consulta:='select
                        tg.gestion,
                        tper.periodo,
                        tf.codigo_rc_iva,
                        tpe.nombre,
                        tpe.apellido_paterno,
                        tpe.apellido_materno,
                        tpe.ci as numero_documento,
                        case when tdoc.nombre=''Pasaporte'' then ''PAS'' else tdoc.nombre end as tipo_documento,
                        --tes.haber_basico as ingreso_neto,
                        tcv_8.valor as ingreso_neto,
                        tpv.valor*2 as dos_salario_minimo,
                        case when tes.haber_basico > tpv.valor*2 then tes.haber_basico-(tpv.valor*2) else 0 end as base_imponible,
                        case when tes.haber_basico > tpv.valor*2 then (tes.haber_basico-(tpv.valor*2))*0.13 else 0 end as impuesto_rc_iva,
                        tpv.valor*2*0.13 as trece_dos_salario_minimo,
                        tcv_1.valor as trece_facturas,
                        tcv_2.valor as saldo_per_anterior,
                        tcv_3.valor as mantenimiento_valor,
                        (case
                        	when  (tuo.fecha_finalizacion between tper.fecha_ini and tper.fecha_fin)
                              	  and
                                  (select max(coalesce(tu.fecha_finalizacion,''31/12/9999''::date))
                                  from orga.tuo_funcionario tu
                                  where tu.id_funcionario = tuo.id_funcionario and tu.estado_reg = ''activo'' and tu.tipo=''oficial'' ) <= tper.fecha_fin then ''D''
                            when (
                            		(select max(tu.fecha_asignacion)
                        			from orga.tuo_funcionario tu
                        			where tu.id_funcionario = tuo.id_funcionario and tu.estado_reg = ''activo'' and tu.tipo=''oficial'') < tper.fecha_ini
                                    and
                                    (select max(coalesce(tu.fecha_finalizacion,''31/12/9999''::date))
                        			from orga.tuo_funcionario tu
                        			where tu.id_funcionario = tuo.id_funcionario and tu.estado_reg = ''activo'' and tu.tipo=''oficial'') > tper.fecha_fin
                            	 ) then ''V''

                        	when  (
                            		(select count(tu.id_uo_funcionario)
                        			from orga.tuo_funcionario tu
                        			where tu.id_funcionario=tuo.id_funcionario and tu.estado_reg=''activo'' and tu.tipo=''oficial'') = 1
                                    and
                                    (select max(tu.fecha_asignacion)
                        			from orga.tuo_funcionario tu
                        			where tu.id_funcionario = tuo.id_funcionario and tu.estado_reg = ''activo'' and tu.tipo=''oficial'') between tper.fecha_ini and tper.fecha_fin
                                  )
                                  OR
                                    tper.fecha_ini - (select coalesce(tu.fecha_finalizacion,''31/12/9999''::date)
                        			from orga.tuo_funcionario tu
                        			where tu.id_funcionario = tuo.id_funcionario and tu.estado_reg = ''activo''
                                    order by tu.fecha_asignacion desc limit 1 offset 1) > 1
                                   then ''I''
                          else ''V''
                             end)::char as novedades,

                        coalesce(tcv_4.valor,0) as cotizable,
                        coalesce(tcv_5.valor,0) as refrigerio,
                        coalesce(tcv_6.valor,0) as viatico,
                        coalesce(tcv_7.valor,0) as prima,
                        case when tcar.nombre ilike ''%CIJ%'' then ''si''::varchar else ''no''::varchar end as es_frontera
                  from plani.tplanilla plani
                  inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = plani.id_planilla
                  inner join plani.tcolumna_valor tcv_1 on tcv_1.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_1.codigo_columna = ''IMPOFAC13''
                  inner join plani.tcolumna_valor tcv_2 on tcv_2.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_2.codigo_columna = ''SALDOPERIANTDEP''
                  inner join plani.tcolumna_valor tcv_3 on tcv_3.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_3.codigo_columna = ''MANTVAL''

                  inner join plani.tcolumna_valor tcv_4 on tcv_4.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_4.codigo_columna = ''COTIZABLE''
                  left join plani.tcolumna_valor tcv_5 on tcv_5.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_5.codigo_columna = ''REFRI''
                  left join plani.tcolumna_valor tcv_6 on tcv_6.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_6.codigo_columna = ''VIATICO''
                  left join plani.tcolumna_valor tcv_7 on tcv_7.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_7.codigo_columna = ''PRIMA''

                  inner join plani.tcolumna_valor tcv_8 on tcv_8.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_8.codigo_columna = ''SUELNETO''
                  inner join orga.tuo_funcionario tuo on tuo.id_uo_funcionario = tfp.id_uo_funcionario
                  inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo and tcar.estado_reg in (''activo'',''inactivo'')

                  /*case when coalesce(tcar.fecha_fin,''31/12/9999''::date) between date_trunc('''||v_calendario||''',''' || v_fecha_fin ||'''::date) and ''' || v_fecha_fin ||'''::date then tcar.estado_reg = ''inactivo''
                  else (tcar.estado_reg = ''activo'' and tcar.fecha_ini <= '''||v_fecha_fin||'''::date) end*/

                  --inner join orga.toficina tofi on tofi.id_lugar = tcar.id_lugar
                  inner join orga.tescala_salarial tes on tes.id_escala_salarial = tcar.id_escala_salarial and tes.estado_reg = ''activo''
                  inner join orga.tfuncionario tf on tf.id_funcionario = tfp.id_funcionario
                  inner join segu.tpersona tpe on tpe.id_persona = tf.id_persona
                  inner join segu.ttipo_documento tdoc on tdoc.id_tipo_documento = tpe.id_tipo_doc_identificacion
                  inner join param.tgestion tg on tg.id_gestion = plani.id_gestion
                  inner join param.tperiodo tper on tper.id_periodo = plani.id_periodo
                  inner join plani.tparametro_valor tpv on  tpv.codigo = ''SALMIN'' and tpv.fecha_fin is null
                  where '||v_where;

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;
	/*********************************
 	#TRANSACCION:  'PLA_R_OTROS_ING_SEL'
 	#DESCRIPCION:	reporte Otros Ingresos
 	#AUTOR:		franklin.espinoza
 	#FECHA:		19-09-2019 17:29:14
	***********************************/
	elsif(p_transaccion='PLA_R_OTROS_ING_SEL')then

    	begin
        	select pxp.list(tuo.id_funcionario::varchar)
            into v_id_gerente
            from orga.tcargo tcar
            inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
            inner join orga.tuo uo on uo.id_uo = tuo.id_uo
            where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo';

            select tper.fecha_ini, tper.fecha_fin, tp.id_periodo, tp.id_gestion, tper.periodo, tges.gestion, tp.modalidad
            into v_record
            from plani.tplanilla tp
            inner join param.tperiodo tper on tper.id_periodo = tp.id_periodo
            inner join param.tgestion tges on tges.id_gestion = tp.id_gestion
            where tp.id_proceso_wf = v_parametros.id_proceso_wf;

			if v_record.modalidad = 'piloto' then
            	v_contrato = '(ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||'))';
            else
            	v_contrato = '(ca.codigo != ''SUPER'' or vf.id_funcionario in ('||v_id_gerente||')) ';
            end if;
--RAISE notice 'v_contrato: %, %, %, %',v_contrato, v_record.id_periodo, v_record.id_gestion, v_record.modalidad;
    		--Sentencia de la consulta
			v_consulta:='

            /*(
            	select  vf.desc_funcionario2::varchar as nombre_empleado,
                		vf.ci ,
                		0::numeric as monto,
                        (uo.nombre_unidad||'' - ''||''8.REFRIGERIO_OCT'')::varchar as gerencia,
                        ''8.REFRIGERIO_OCT''::varchar as categoria_prog,
                        0::numeric refrigerio,
                        0::numeric viatico,
                        coalesce(toi.monto,0)::numeric refri_sep

                from plani.totros_ingresos toi

                inner join orga.tuo_funcionario tuo on tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(toi.id_funcionario)
                inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo
                inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
                inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                inner join param.tperiodo tper on tper.id_periodo = '||v_record.id_periodo||'
                left join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_record.id_gestion||' and
                ((tper.fecha_ini between cp.fecha_ini and cp.fecha_fin) or (tper.fecha_fin between cp.fecha_ini and cp.fecha_fin))
                left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)
                inner join orga.vfuncionario vf on vf.id_funcionario = toi.id_funcionario

                where toi.periodo = 10 and toi.sistema_fuente = ''Refrigerios'' and
                (toi.fecha_pago between ''01/09/2020''::date and ''30/09/2020''::date) and toi.gestion = 2020 and '||v_contrato||'
            )

            union*/

            (
                        with fin_contrato as (
                              select distinct toi.id_funcionario
                              from plani.totros_ingresos toi
                              inner join orga.tuo_funcionario tuo on tuo.id_funcionario = toi.id_funcionario
                              and (coalesce(tuo.fecha_finalizacion,''31/12/9999''::date) between '''||v_record.fecha_ini||'''::date and '''||v_record.fecha_fin||'''::date)
                              and tuo.id_funcionario not in (select tu.id_funcionario
                                                             from orga.tuo_funcionario tu
                                                             where tu.fecha_asignacion >= '''||v_record.fecha_ini||'''::date and
                                                             tu.id_funcionario = tuo.id_funcionario)
                              where toi.periodo = '||v_record.periodo||' and toi.gestion = '||v_record.gestion||'
                                    and toi.id_funcionario not in ( select tfp.id_funcionario
                                                                    from plani.tplanilla tp
                                                                    inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla
                                                                    where tp.id_proceso_wf = '||v_parametros.id_proceso_wf||'
                                                                  )
                        )
                        select
                        vf.desc_funcionario2::varchar as nombre_empleado,
                        vf.ci ,
                        0::numeric as monto,
                        (uo.nombre_unidad||'' - ''||''7.FINCONTRATO'')::varchar as gerencia,
                        ''7.FINCONTRATO''::varchar as categoria_prog,
                        plani.f_get_otro_ingreso(toi.id_funcionario,'||v_record.gestion||','||v_record.periodo||',''ref_fin'')::numeric as refrigerio,
                        plani.f_get_otro_ingreso(toi.id_funcionario,'||v_record.gestion||','||v_record.periodo||',''adm_ope'')::numeric as viatico,
                        0::numeric refri_sep,
                        tper.fecha_ini,
                        tper.fecha_fin

                        from fin_contrato toi
                        inner join orga.tuo_funcionario tuo on tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(toi.id_funcionario)
                        inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo
                        inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
                        inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                        inner join param.tperiodo tper on tper.id_periodo = '||v_record.id_periodo||'
                        left join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_record.id_gestion||'
                        --and ((tper.fecha_ini between cp.fecha_ini and cp.fecha_fin) or (tper.fecha_fin between cp.fecha_ini and cp.fecha_fin))
                        left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                        left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                        inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)
                        inner join orga.vfuncionario vf on vf.id_funcionario = toi.id_funcionario
                        where tuo.tipo = ''oficial'' and tuo.estado_reg = ''activo'' and '||v_contrato||'
            )

            union
            (
            	select
                  tf.desc_funcionario2::varchar as nombre_empleado,
                  tf.ci ,
                  tcv_1.valor as monto,
                    (uo.nombre_unidad||'' - ''||(case
                    when lower(uo.nombre_unidad) like ''%cobija%'' then
                        ''CIJ''
                    when tcar.codigo = ''0'' then
                        ''EVE''
                    when ca.codigo = ''SUPER'' and (tf.id_funcionario not in ('||v_id_gerente||') or tf.id_funcionario is null)  then
                        ''ESP''
                    when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tf.id_funcionario in ('||v_id_gerente||'))) then
                        ''ADM''
                    when cat.desc_programa ilike ''%OPE%'' then
                        ''OPE''
                    when cat.desc_programa ilike ''%COM%'' then
                        ''COM''
                    else
                        ''SINCAT''
                    end
                    )::varchar)::varchar as gerencia,
                (case
                    when lower(uo.nombre_unidad) like ''%cobija%'' then
                        ''5.CIJ''
                    when tcar.codigo = ''0'' then
                        ''6.EVE''
                    when ca.codigo = ''SUPER'' and (tf.id_funcionario not in ('||v_id_gerente||') or tf.id_funcionario is null)  then
                        ''3.ESP''
                    when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tf.id_funcionario in ('||v_id_gerente||'))) then
                        ''1.ADM''
                    when cat.desc_programa ilike ''%OPE%'' then
                        ''2.OPE''
                    when cat.desc_programa ilike ''%COM%'' then
                        ''4.COM''
                    else
                        ''SINCAT''
                    end
                    )::varchar as categoria_prog,
                /*case
                when coalesce(plani.f_get_otro_ingreso(tf.id_funcionario,'||v_record.gestion||','||v_record.periodo||',''ref_sep'')::numeric, 0) > 0 and tcv_2.valor > 0 then
                	tcv_2.valor - coalesce(plani.f_get_otro_ingreso(tf.id_funcionario,'||v_record.gestion||','||v_record.periodo||',''ref_sep'')::numeric, 0)
                else*/ tcv_2.valor /*end*/ refrigerio,
                tcv_3.valor viatico,
                coalesce(plani.f_get_otro_ingreso(tf.id_funcionario,'||v_record.gestion||','||v_record.periodo||',''ref_sep'')::numeric, 0)::numeric refri_sep,
                tper.fecha_ini,
                tper.fecha_fin

                from plani.tplanilla tp
                inner join param.tperiodo tper on tper.id_periodo = tp.id_periodo
                inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla
                inner join plani.tcolumna_valor tcv_1 on tcv_1.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_1.codigo_columna = ''OTROSING_RCIVA''
                inner join plani.tcolumna_valor tcv_2 on tcv_2.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_2.codigo_columna = ''REFRI''
                inner join plani.tcolumna_valor tcv_3 on tcv_3.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_3.codigo_columna = ''VIATICO''

                --left join plani.tcolumna_valor tcv_5 on tcv_5.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv_5.codigo_columna = ''PAGOVAR''



                inner join orga.tuo_funcionario tuo on tuo.id_uo_funcionario = tfp.id_uo_funcionario
                inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo --and tcar.estado_reg = ''activo''
                inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''

                inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                left join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = tp.id_gestion
                --and ((tper.fecha_ini between cp.fecha_ini and cp.fecha_fin) or (tper.fecha_fin between cp.fecha_ini and cp.fecha_fin))

                left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)

                inner join orga.vfuncionario tf on tf.id_funcionario = tfp.id_funcionario
                --inner join segu.tpersona tpe on tpe.id_persona = tf.id_persona

                where tuo.tipo = ''oficial'' and tuo.estado_reg = ''activo'' and '||v_parametros.filtro;
    			v_consulta = v_consulta||') order by categoria_prog asc, gerencia asc, nombre_empleado asc';

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;
  /*********************************
 	#TRANSACCION:  'PLA_R_OTING_FORM_SEL'
 	#DESCRIPCION:	reporte Otros Ingresos Formulario
 	#AUTOR:		franklin.espinoza
 	#FECHA:		19-09-2019 17:29:14
	***********************************/
	elsif(p_transaccion='PLA_R_OTING_FORM_SEL')then

    	begin

    	if pxp.f_existe_parametro(p_tabla , 'modalidad') then
        	if v_parametros.modalidad = 'administrativo' then
        	  v_modalidad  = 'and (ca.codigo != ''SUPER'' or tf.id_funcionario = 10)';
        	else
        	  v_modalidad  = 'and (ca.codigo = ''SUPER'' and tf.id_funcionario != 10)';
        	end if;
      end if;
    		--Sentencia de la consulta
			v_consulta = 'with funcionarios as (select
                        tf.desc_funcionario2::varchar as nombre_empleado,
                        tpe.ci ,
                        (uo.nombre_unidad||'' - ''||(case
                        when lower(uo.nombre_unidad) like ''%cobija%'' then
                            ''CIJ''
                        when tcar.codigo = ''0'' then
                            ''EVE''
                        when ca.codigo = ''SUPER'' and (tf.id_funcionario != 10 or tf.id_funcionario is null)  then
                            ''ESP''
                        when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tf.id_funcionario = 10)) then
                            ''ADM''
                        when cat.desc_programa ilike ''%OPE%'' then
                            ''OPE''
                        when cat.desc_programa ilike ''%COM%'' then
                            ''COM''
                        else
                            ''SINCAT''
                        end
                        )::varchar)::varchar as gerencia,

                        (case
                        when tuo.fecha_finalizacion between date_trunc(''month'',tper.fecha_ini - interval ''1 day'') and
                        (tper.fecha_ini - interval ''1 day'')::date and tuo.id_funcionario not in (select tu.id_funcionario
                                                                                                  from orga.tuo_funcionario tu
                                                                                                  where tu.fecha_asignacion >= tper.fecha_ini and
                                                                                                  tu.id_funcionario = tuo.id_funcionario)  then
                        	''7.FINCONTRATO''
                        when lower(uo.nombre_unidad) like ''%cobija%'' then
                            ''5.CIJ''
                        when tcar.codigo = ''0'' then
                            ''6.EVE''
                        when ca.codigo = ''SUPER'' and (tf.id_funcionario != 10 or tf.id_funcionario is null)  then
                            ''3.ESP''
                        when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tf.id_funcionario = 10)) then
                            ''1.ADM''
                        when cat.desc_programa ilike ''%OPE%'' then
                            ''2.OPE''
                        when cat.desc_programa ilike ''%COM%'' then
                            ''4.COM''
                        else
                            ''SINCAT''
                        end
                        )::varchar as categoria_prog,
                        plani.f_get_otros_ingresos_consolidado(tuo.id_funcionario,'||v_parametros.id_periodo||','||v_parametros.id_gestion||') as otros_ingresos

                        from orga.tuo_funcionario tuo
                        inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo and tcar.estado_reg = ''activo''
                        inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
                        inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                        left join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_parametros.id_gestion||'
                        left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                        left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                        inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)

                        inner join orga.vfuncionario tf on tf.id_funcionario = tuo.id_funcionario
                        inner join segu.tpersona tpe on tpe.id_persona = tf.id_persona
                        inner join orga.ttipo_contrato ttc on ttc.id_tipo_contrato = tcar.id_tipo_contrato

                        inner join param.tperiodo tper on tper.id_periodo = '||v_parametros.id_periodo||'

                        where tuo.estado_reg = ''activo'' and tuo.tipo = ''oficial''
                        and (tuo.fecha_finalizacion between date_trunc(''month'',tper.fecha_ini - interval ''1 day'') and (tper.fecha_ini - interval ''1 day'')::date)
                        and tuo.id_funcionario not in (select tu.id_funcionario
                                                      from orga.tuo_funcionario tu
                                                      where tu.fecha_asignacion >= tper.fecha_ini and tu.id_funcionario = tuo.id_funcionario)
                        and tcar.nombre != ''cadet Pilot'' and ttc.codigo in (''PLA'', ''EVE'') '||v_modalidad||'

                        union

                        select
                        tf.desc_funcionario2::varchar as nombre_empleado,
                        tpe.ci ,
                        (uo.nombre_unidad||'' - ''||(case
                        when lower(uo.nombre_unidad) like ''%cobija%'' then
                            ''CIJ''
                        when tcar.codigo = ''0'' then
                            ''EVE''
                        when ca.codigo = ''SUPER'' and (tf.id_funcionario != 10 or tf.id_funcionario is null)  then
                            ''ESP''
                        when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tf.id_funcionario = 10)) then
                            ''ADM''
                        when cat.desc_programa ilike ''%OPE%'' then
                            ''OPE''
                        when cat.desc_programa ilike ''%COM%'' then
                            ''COM''
                        else
                            ''SINCAT''
                        end
                        )::varchar)::varchar as gerencia,

                        (case
                        when tuo.fecha_finalizacion between date_trunc(''month'',tper.fecha_ini - interval ''1 day'') and
                        (tper.fecha_ini - interval ''1 day'')::date and tuo.id_funcionario not in (select tu.id_funcionario
                                                                                                  from orga.tuo_funcionario tu
                                                                                                  where tu.fecha_asignacion >= tper.fecha_ini and
                                                                                                  tu.id_funcionario = tuo.id_funcionario)  then
                        	''7.FINCONTRATO''
                        when lower(uo.nombre_unidad) like ''%cobija%'' then
                            ''5.CIJ''
                        when tcar.codigo = ''0'' then
                            ''6.EVE''
                        when ca.codigo = ''SUPER'' and (tf.id_funcionario != 10 or tf.id_funcionario is null)  then
                            ''3.ESP''
                        when (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tf.id_funcionario = 10)) then
                            ''1.ADM''
                        when cat.desc_programa ilike ''%OPE%'' then
                            ''2.OPE''
                        when cat.desc_programa ilike ''%COM%'' then
                            ''4.COM''
                        else
                            ''SINCAT''
                        end
                        )::varchar as categoria_prog,
                        plani.f_get_otros_ingresos_consolidado(tuo.id_funcionario,'||v_parametros.id_periodo||','||v_parametros.id_gestion||') as otros_ingresos

                        from orga.tuo_funcionario tuo
                        inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo and tcar.estado_reg = ''activo''
                        inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
                        inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                        left join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_parametros.id_gestion||'
                        left join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                        left join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                        inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)

                        inner join orga.vfuncionario tf on tf.id_funcionario = tuo.id_funcionario
                        inner join segu.tpersona tpe on tpe.id_persona = tf.id_persona
                        inner join orga.ttipo_contrato ttc on ttc.id_tipo_contrato = tcar.id_tipo_contrato

                        inner join param.tperiodo tper on tper.id_periodo = '||v_parametros.id_periodo||'

                        where tuo.estado_reg = ''activo''
                        and tuo.tipo = ''oficial''
                        and ((tuo.fecha_finalizacion between tper.fecha_ini and tper.fecha_fin) or current_date <= coalesce(tuo.fecha_finalizacion,''31/12/9999''::date))
                        and tcar.nombre != ''cadet Pilot'' and ttc.codigo in (''PLA'', ''EVE'') '||v_modalidad||'
                        )

                        select  funcio.nombre_empleado,
                        		funcio.ci,
                                funcio.gerencia,
                                funcio.categoria_prog,
                                funcio.otros_ingresos
                        from funcionarios funcio
                        order by funcio.categoria_prog asc, funcio.gerencia asc, funcio.nombre_empleado asc
                        ';
			--v_consulta = v_consulta||' order by categoria_prog asc, gerencia asc, tf.desc_funcionario2 asc';
            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;
		end;
		/*********************************
 	#TRANSACCION:  'PLA_PRESUPUESTO_SEL'
 	#DESCRIPCION:	reporte Planilla Presupuestaria
 	#AUTOR:		franklin.espinoza
 	#FECHA:		29-02-2020 17:29:14
	***********************************/
	elsif(p_transaccion='PLA_PRESUPUESTO_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
                          vcp.codigo_programa::varchar as programa,
                          ''578 Boliviana de Aviación''::varchar as entidad,
                          ''1 BOLIVIANA DE AVIACION - BOA''::varchar as dir_admin,
                          ''117''::varchar as objeto_gasto,
                          vcp.codigo_actividad as actividad,
                          vcp.codigo_fuente_fin::varchar as fuente,
                          vcp.codigo_origen_fin::varchar as organismo,
                          vcp.codigo_unidad_ejecutora::varchar as ue,
                          tcar.codigo::varchar as item,
                          tcar.nombre::varchar as cargo,
                          es.haber_basico,
                          (es.haber_basico*12)::numeric as costo_anual,
                          tg.gestion
                          FROM ORGA.tcargo tcar
                          INNER JOIN ORGA.tescala_salarial es ON es.id_escala_salarial = tcar.id_escala_salarial
                          INNER JOIN ORGA.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                          inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tcar.id_cargo and tcp.id_gestion = (select tg.id_gestion from param.tgestion tg where tg.gestion = date_part(''year'', '''||v_parametros.fecha||'''::date))
                          inner join param.tgestion tg on tg.id_gestion = tcp.id_gestion
                          inner join param.tcentro_costo tcc on tcc.id_centro_costo = tcp.id_centro_costo
                          inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc
                          INNER JOIN pre.tpresupuesto	tp ON tp.id_presupuesto = tcc.id_centro_costo
                          INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog
                          WHERE tcar.estado_reg = ''activo'' and tcp.id_gestion = (select tg.id_gestion from param.tgestion tg where tg.gestion = date_part(''year'', '''||v_parametros.fecha||'''::date)) and tcar.codigo != ''0''
                          ORDER BY codigo_programa asc, tcar.codigo::integer asc';

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;
    /*********************************
        #TRANSACCION:  'PLA_OTROING_CAT_SEL'
        #DESCRIPCION:	Listado de Otros Ingresos Funcionario Categoria
        #AUTOR:		franklin.espinoza
        #FECHA:		01-05-2020 16:11:04
        ***********************************/
    elsif(p_transaccion='PLA_OTROING_CAT_SEL')then

      begin

        v_periodo = v_parametros.periodo::integer;
        v_gestion = v_parametros.gestion::integer;
        if v_periodo + 1 = 13 then
        	v_periodo = 1;
            v_gestion = v_gestion + 1;
        else
        	v_periodo = v_periodo+1;
        end if;
        v_fecha_inicio = ('1/'||v_parametros.periodo||'/'||v_parametros.gestion)::date;
        v_fecha_final = ('1/'||v_periodo||'/'||v_gestion)::date-1;

        /*Verificar si existe planilla de prima, retroactivo*/
        EXECUTE('select tp.id_planilla
                  from plani.tplanilla tp
                  inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = tp.id_tipo_planilla
                  where tpla.codigo =''PLAPRI'' and tp.fecha_planilla between '''||date_trunc('year',v_fecha_inicio)||'''::date and '''||date_trunc('year',v_fecha_final+interval '1 year')::date-1||'''::date') into v_id_prima;

         EXECUTE('select tp.id_planilla
                  from plani.tplanilla tp
                  inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = tp.id_tipo_planilla
                  where tpla.codigo =''PLAREISU'' and tp.fecha_planilla between '''||date_trunc('year',v_fecha_inicio)||'''::date and '''||date_trunc('year',v_fecha_final+interval '1 year')::date-1||'''::date') into v_id_retro;

		v_col_prima = '0::numeric as prima,';
        v_col_retro = '0::numeric as retroactivo';
        if v_id_prima is not null and v_parametros.periodo::integer = 9 then
            v_col_prima = 'COALESCE ((select coalesce(tcv.valor,0)
            				 from plani.tfuncionario_planilla tfp
            				 inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''PRIMA''
                             where tfp.id_funcionario = bef.id_funcionario and tfp.id_planilla = '||v_id_prima||'),0)::numeric(18,2) as prima,';

            v_col_retro = '0::numeric as retroactivo';
        end if;

        if v_id_retro is not null and v_parametros.periodo::integer = 12 then
            v_col_retro = 'COALESCE ((select coalesce(tcv.valor,0)
            				 from plani.tfuncionario_planilla tfp
            				 inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''REINBANT''
                             where tfp.id_funcionario = bef.id_funcionario and tfp.id_planilla = '||v_id_retro||'),0)::numeric(18,2) as retroactivo';
            v_col_prima = '0::numeric as prima,';
        end if;
        /*Verificar si existe planilla de prima, retroactivo*/


        v_date_fin_contrato = v_fecha_inicio-1;
        v_date_ini_contrato = date_trunc('month',v_date_fin_contrato);

        select tg.id_gestion
        into v_id_gestion
        from param.tgestion tg
        where tg.gestion = v_parametros.gestion::integer;

        select tuo.id_funcionario
        into v_id_gerente
        from orga.tcargo tcar
        inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
        inner join orga.tuo uo on uo.id_uo = tuo.id_uo
        where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo'
        and v_fecha_inicio <= coalesce(tuo.fecha_finalizacion,'31/12/9999'::date);

        v_inner_categoria = 'INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  bef.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            and (tuo.fecha_finalizacion IS NULL OR tuo.fecha_finalizacion >= '''||v_fecha_final||'''::date or (tuo.fecha_finalizacion between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date)) AND tuo.fecha_asignacion <= '''||v_fecha_final||'''::date';

        if v_parametros.categoria = 'adm' then
        	v_where_categoria = 'WHERE (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario in ('||v_id_gerente||'))) and tcar.codigo != ''0''';
        elsif v_parametros.categoria = 'ope' then
        	v_where_categoria = 'WHERE cat.desc_programa ilike ''%OPE%'' and tcar.codigo != ''0''  AND ca.codigo != ''SUPER''';
        elsif v_parametros.categoria = 'com' then
        	v_where_categoria = 'WHERE cat.desc_programa ilike ''%COM%'' and tcar.codigo != ''0''';
        elsif v_parametros.categoria = 'eve' then
        	v_where_categoria = 'WHERE tcar.codigo = ''0''';
        elsif v_parametros.categoria = 'esp' then
        	v_where_categoria = 'WHERE ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||') and tcar.codigo != ''0''';
        elsif v_parametros.categoria = 'bajas' then
        	v_inner_categoria = 'INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  bef.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            and orga.f_get_ultima_fecha_finalizacion(bef.id_funcionario) < '''||v_fecha_inicio||'''::date
            --and (tuo.fecha_finalizacion between '''||v_date_ini_contrato||'''::date and '''||v_date_fin_contrato||'''::date)
            --and ((select coalesce(tu.fecha_finalizacion,''31/12/9999''::date) from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)) < '''||v_fecha_inicio||'''::date)';

            v_estado = 'inactivo';
        elsif v_parametros.categoria = 'externo' then
        	v_inner_categoria = 'INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  bef.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            --and tuo.fecha_finalizacion < '''||v_date_ini_contrato||'''::date
            and tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)
            and ((select tu.fecha_finalizacion from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)) < '''||v_date_ini_contrato||'''::date)';

            v_estado = 'inactivo';
        end if;

		/*if v_parametros.tipo = 'refrigerios' then
        	v_fuente = ' and toi.sistema_fuente = ''Refrigerios''';
        elsif v_parametros.tipo = 'viaticos' then
        	v_fuente = ' and toi.sistema_fuente in(''Viatico Administrativo'',''Viatico Administrativo AMP'',''Viatico Operativo'')';
        end if;*/

        v_consulta = '
            with beneficiario as (
            	select distinct toi.id_funcionario
                from plani.totros_ingresos toi
                where toi.gestion = '||v_parametros.gestion||' and toi.periodo = '||v_parametros.periodo||v_fuente||'
            )
        	SELECT
            vf.id_persona,
            vf.id_funcionario,
            vf.desc_funcionario2 AS desc_person,
            plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''ref'')::numeric as refrigerio,
            plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''vad'')::numeric as viatico_adm,
            plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''vam'')::numeric as viatico_amp,
            plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''vop'')::numeric as viatico_ope,
            plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''total'')::numeric as total_viatico,
            plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''c31'')::varchar as c31,
            vf.ci,
            tcar.nombre as cargo,
            tcon.nombre as contrato,
            '''||v_estado||'''::varchar as estado,
            '||v_col_prima||'
            '||v_col_retro||'
            --plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''ref_sep'')::numeric as ref_sep
            FROM  beneficiario bef
            INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = bef.id_funcionario
            '||v_inner_categoria||'

            inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo and tcar.estado_reg = ''activo''

            inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = tcar.id_tipo_contrato

            inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
            inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

            inner join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_id_gestion||'
            inner join pre.tpresupuesto pre on pre.id_centro_costo = cp.id_centro_costo
            inner join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
            --inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)
            '||v_where_categoria;

		    raise notice 'v_consulta: %',v_consulta;

        v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' OFFSET ' || v_parametros.puntero;
        --Devuelve la respuesta
        return v_consulta;
      end;

     /*********************************
        #TRANSACCION:  'PLA_OTROING_CAT_CONT'
        #DESCRIPCION:	Listado de Otros Ingresos Funcionario Categoria
        #AUTOR:		franklin.espinoza
        #FECHA:		01-05-2020 16:11:04
        ***********************************/
    elsif(p_transaccion='PLA_OTROING_CAT_CONT')then

      begin

      	v_periodo = v_parametros.periodo::integer;
        v_gestion = v_parametros.gestion::integer;
        if v_periodo + 1 = 13 then
        	v_periodo = 1;
            v_gestion = v_gestion + 1;
        else
        	v_periodo = v_periodo+1;
        end if;
        v_fecha_inicio = ('1/'||v_parametros.periodo||'/'||v_parametros.gestion)::date;
        v_fecha_final = ('1/'||v_periodo||'/'||v_gestion)::date-1;


        /*Verificar si existe planilla de prima, retroactivo*/
        EXECUTE('select tp.id_planilla
                  from plani.tplanilla tp
                  inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = tp.id_tipo_planilla
                  where tpla.codigo =''PLAPRI'' and tp.fecha_planilla between '''||date_trunc('year',v_fecha_inicio)||'''::date and '''||date_trunc('year',v_fecha_final+interval '1 year')::date-1||'''::date') into v_id_prima;

         EXECUTE('select tp.id_planilla
                  from plani.tplanilla tp
                  inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = tp.id_tipo_planilla
                  where tpla.codigo =''PLAREISU'' and tp.fecha_planilla between '''||date_trunc('year',v_fecha_inicio)||'''::date and '''||date_trunc('year',v_fecha_final+interval '1 year')::date-1||'''::date') into v_id_retro;

		v_col_prima = '0::numeric as tot_prima,';
        v_col_retro = '0::numeric as tot_retroactivo';
        if v_id_prima is not null and v_parametros.periodo::integer = 9 then
            v_col_prima = 'sum((select coalesce(tcv.valor,0)
            				 from plani.tfuncionario_planilla tfp
            				 inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''PRIMA''
                             where  tfp.id_funcionario = bef.id_funcionario and tfp.id_planilla = '||v_id_prima||')::numeric(18,2)) as tot_prima,';

            v_col_retro = '0::numeric as tot_retroactivo';
        end if;

        if v_id_retro is not null and v_parametros.periodo::integer = 12 then
            v_col_retro = 'sum((select coalesce(tcv.valor,0)
            				 from plani.tfuncionario_planilla tfp
            				 inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''REINBANT''
                             where  tfp.id_funcionario = bef.id_funcionario and tfp.id_planilla = '||v_id_retro||')::numeric(18,2)) as tot_retroactivo';
            v_col_prima = '0::numeric as tot_prima,';
        end if;
        /*Verificar si existe planilla de prima, retroactivo*/

        v_date_fin_contrato = v_fecha_inicio-1;
        v_date_ini_contrato = date_trunc('month',v_date_fin_contrato);

        select tg.id_gestion
        into v_id_gestion
        from param.tgestion tg
        where tg.gestion = v_parametros.gestion::integer;

        select tuo.id_funcionario
        into v_id_gerente
        from orga.tcargo tcar
        inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
        inner join orga.tuo uo on uo.id_uo = tuo.id_uo
        where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo'
        and v_fecha_inicio <= coalesce(tuo.fecha_finalizacion,'31/12/9999'::date);

        v_inner_categoria = 'INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  bef.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            and (tuo.fecha_finalizacion IS NULL OR tuo.fecha_finalizacion >= '''||v_fecha_final||'''::date or (tuo.fecha_finalizacion between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date)) AND tuo.fecha_asignacion <= '''||v_fecha_final||'''::date';

		if v_parametros.categoria = 'adm' then
        	v_where_categoria = 'WHERE (cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario in ('||v_id_gerente||'))) and tcar.codigo != ''0''';
        elsif v_parametros.categoria = 'ope' then
        	v_where_categoria = 'WHERE cat.desc_programa ilike ''%OPE%'' and tcar.codigo != ''0'' AND ca.codigo != ''SUPER''';
        elsif v_parametros.categoria = 'com' then
        	v_where_categoria = 'WHERE cat.desc_programa ilike ''%COM%'' and tcar.codigo != ''0''';
        elsif v_parametros.categoria = 'eve' then
        	v_where_categoria = 'WHERE tcar.codigo = ''0''';
        elsif v_parametros.categoria = 'esp' then
        	v_where_categoria = 'WHERE ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||') and tcar.codigo != ''0''';
        elsif v_parametros.categoria = 'bajas' then
        	v_inner_categoria = 'INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  bef.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            and orga.f_get_ultima_fecha_finalizacion(bef.id_funcionario) < '''||v_fecha_inicio||'''::date and tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)
            --and (tuo.fecha_finalizacion between '''||v_date_ini_contrato||'''::date and '''||v_date_fin_contrato||'''::date)
            --and ((select tu.fecha_finalizacion from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)) < '''||v_fecha_inicio||'''::date)';
        elsif v_parametros.categoria = 'externo' then
        	v_inner_categoria = 'INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  bef.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            --and tuo.fecha_finalizacion < '''||v_date_ini_contrato||'''::date
            and tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)
            and ((select tu.fecha_finalizacion from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)) < '''||v_date_ini_contrato||'''::date)';
        end if;

        v_consulta = '
            with beneficiario as (
            	select distinct toi.id_funcionario
                from plani.totros_ingresos toi
                where toi.gestion = '||v_parametros.gestion||' and toi.periodo = '||v_parametros.periodo||'
            )
        	SELECT
            count(vf.id_funcionario) as total,
            COALESCE (sum(plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''ref'')::numeric),0) as tot_refrigerio,
            COALESCE (sum(plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''vad'')::numeric),0) as tot_viatico_adm,
            COALESCE (sum(plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''vam'')::numeric),0) as tot_viatico_amp,
            COALESCE (sum(plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''vop'')::numeric),0) as tot_viatico_ope,
            COALESCE (sum(plani.f_get_otro_ingreso(bef.id_funcionario, '||v_parametros.gestion||', '||v_parametros.periodo||', ''total'')::numeric),0) as tot_total_viatico,
            '||v_col_prima||'
            '||v_col_retro||'
            FROM  beneficiario bef
            INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = bef.id_funcionario
            '||v_inner_categoria||'
            inner join orga.tcargo tcar on tcar.id_cargo =  tuo.id_cargo and tcar.estado_reg = ''activo''
            inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = tcar.id_tipo_contrato
            inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
            inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial

            INNER JOIN orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_id_gestion||'
            INNER JOIN pre.tpresupuesto pre on pre.id_centro_costo = cp.id_centro_costo
            INNER JOIN pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
            --inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)
            '||v_where_categoria;

		    raise notice 'v_consulta: %',v_consulta;

        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
 	#TRANSACCION:  'PLA_REP_UOITEMS_SEL'
 	#DESCRIPCION:	Reporte Planilla UO Items
 	#AUTOR:		franklin.espinoza
 	#FECHA:		19-04-2021
	***********************************/
	elsif(p_transaccion='PLA_REP_UOITEMS_SEL')then

    	begin
        	/*v_licencia = '';
          	if v_parametros.licencia != '' then
            	if v_parametros.licencia = 'no' then
              		v_licencia = 'identifador_func not in (select lic.id_funcionario from plani.tlicencia lic where lic.id_funcionario = id_funcionario and ''' || v_parametros.fecha ||'''::date between lic.desde and lic.hasta )';
            	end if;
        	end if;*/
    		--Sentencia de la consulta
			v_consulta:='SELECT escala::varchar,
                                cargo::varchar,
                                nro_item::varchar,
                                nombre_funcionario::varchar,
                                genero::varchar,
                                haber_basico::numeric,
                                bono_antiguedad::numeric,
                                bono_frontera::numeric,
                                sumatoria::numeric,
                                fecha_inicio::varchar,
                                ci::varchar,
                                expedicion::varchar,
                                codigo::varchar,
                                nombre::varchar,
                                codigo_nombre_gerencia::varchar,
                                nombre_unidad::varchar,
                                id_tipo_contrato::integer,
                                gerencia::varchar,
                                departamento::varchar,
                                categoria_programatica::varchar,
                                fecha_finalizacion::varchar,
                                correlativo::integer
                      FROM plani.f_listar_uo_items('''||v_parametros.fecha||'''::date, '''||v_parametros.licencia||'''::varchar) uoitem(escala, cargo, nro_item, nombre_funcionario, genero, haber_basico,
                                bono_antiguedad, bono_frontera, sumatoria, fecha_inicio, ci, expedicion, codigo, nombre, codigo_nombre_gerencia,
                                nombre_unidad, id_tipo_contrato, gerencia, departamento, categoria_programatica, fecha_finalizacion, id_uo, correlativo, id_funcionario)
                      ORDER BY categoria_programatica asc, correlativo asc, nro_item::integer asc
                      ';

            RAISE NOTICE 'v_consulta: %', v_consulta;
			--Devuelve la respuesta
			return v_consulta;

		end;

    else

      raise exception 'Transaccion inexistente';

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

ALTER FUNCTION plani.ft_reporte_sel (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
  OWNER TO postgres;