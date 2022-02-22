CREATE OR REPLACE FUNCTION plani.ft_planilla_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
  /**************************************************************************
   SISTEMA:		Sistema de Planillas
   FUNCION: 		plani.ft_planilla_sel
   DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'plani.tplanilla'
   AUTOR: 		 (admin)
   FECHA:	        22-01-2014 16:11:04
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
    v_filtro			varchar;

    --variables reporte certificacion presupuestaria
    v_record_op					record;
    v_index						integer;
    v_record					record;
    v_record_funcionario		record;
    v_firmas					varchar[];
    v_firma_fun					varchar;
    v_nombre_entidad			varchar;
    v_direccion_admin			varchar;
    v_unidad_ejecutora			varchar;
    v_cod_proceso				varchar;
    v_cont						integer;
    v_gerencia					varchar;
    v_id_funcionario			integer;

    v_desc_funcionario			varchar;

    v_id_gestion				integer;
    v_desc_planilla				varchar;
	v_porcentaje				varchar='';
    v_inner_periodo				varchar='';

    v_id_periodo				integer;
    v_gestion					integer;
    v_mes						varchar[];
    v_cond_categoria			varchar;
    v_cond_gestion				varchar;

    v_periodo_retro				varchar='';
    v_join_retro				varchar='';
    v_id_uo_func_retro			varchar='';
    v_columna_valor				varchar = '';
    v_periodo_group				varchar = '';
    v_cond_periodo				varchar = '';
    v_cond_admin				varchar = '';
    v_sumatoria					varchar = '';
    v_codigo					varchar = '';

    v_total						varchar='';
    v_retroactivo				varchar='';

    v_id_seg_cordes				integer;
    v_id_seg_umss				integer;

    v_periodo					integer;

    v_fecha_inicio   			date;
    v_fecha_final     			date;

    v_factor_zona_franca		varchar;

    --(franklin.espinoza)variables rentenciones
    v_afp						varchar = '';
    v_total_monto				numeric = 0;
    v_categoria_prog			varchar = '';
    v_retencion 				varchar = '';
    v_desc_retencion			varchar = '';

    v_inner_c31					varchar = '';
    v_campos_c31 				varchar = '';
    v_group_c31					varchar = '';

    v_inner_categoria	varchar = '';
    v_where_categoria	varchar = '';

    v_date_fin_contrato	date;
    v_date_ini_contrato	date;

    v_id_gerente				varchar;

    --reporte otros ingresos
    v_col_prima 				  varchar = '';
    v_col_retro 				  varchar = '';
    v_id_prima			      integer;
    v_id_retro			      integer;
    v_with_header				  varchar = '';
    v_with_body					  varchar = '';
    v_with_footer				  varchar = '';
    v_planilla_extra			varchar='';
    v_id_planilla_extra		integer;

    v_datos_cargo				record;

    v_fuente			varchar = '';
  BEGIN

    v_nombre_funcion = 'plani.ft_planilla_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'PLA_PLANI_SEL'
     #DESCRIPCION:	Consulta de datos
     #AUTOR:		admin
     #FECHA:		22-01-2014 16:11:04
    ***********************************/

    if(p_transaccion='PLA_PLANI_SEL')then

      begin
        IF p_administrador !=1 THEN
          v_filtro = ' plani.id_depto IN (' ||(case when (param.f_get_lista_deptos_x_usuario(p_id_usuario, 'ORGA') = '')
            then  '-1'
                                               else param.f_get_lista_deptos_x_usuario(p_id_usuario, 'ORGA')
                                               end) || ') and ';
        else
          v_filtro = '';
        END IF;

        IF (pxp.f_existe_parametro(p_tabla, 'tipo_interfaz')) THEN
        	v_filtro = '';
        END IF;

        --Sentencia de la consulta
        v_consulta:='select
						plani.id_planilla,
						plani.id_periodo,
						plani.id_gestion,
						plani.id_uo,
						plani.id_tipo_planilla,
						plani.id_proceso_macro,
						plani.id_proceso_wf,
						plani.id_estado_wf,
						plani.estado_reg,
						plani.observaciones,
						plani.nro_planilla,
						plani.estado,
						plani.fecha_reg,
						plani.id_usuario_reg,
						plani.id_usuario_mod,
						plani.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						ges.gestion,
						per.periodo,
						tippla.codigo as nombre_planilla,
						uo.nombre_unidad,
						plani.id_depto,
						depto.nombre,
						tippla.calculo_horas,
						pxp.f_get_variable_global(''plani_tiene_presupuestos''),
						pxp.f_get_variable_global(''plani_tiene_costos''),
						plani.fecha_planilla,
            plani.codigo_poa,
            plani.obs_poa,
            perp.periodo as periodo_pago,
            plani.fecha_sigma,
            plani.modalidad,
            plani.momento_planilla
						from plani.tplanilla plani
						inner join segu.tusuario usu1 on usu1.id_usuario = plani.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = plani.id_usuario_mod
						inner join param.tgestion ges on ges.id_gestion = plani.id_gestion
						left join param.tperiodo per on per.id_periodo = plani.id_periodo
                        left join param.tperiodo perp on perp.id_periodo = plani.id_periodo_pago
						inner join plani.ttipo_planilla tippla on tippla.id_tipo_planilla = plani.id_tipo_planilla
						left join orga.tuo uo on uo.id_uo = plani.id_uo
						inner join param.tdepto depto on depto.id_depto = plani.id_depto
				        where  ' || v_filtro;

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;
        v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
		raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
     #TRANSACCION:  'PLA_PLANI_CONT'
     #DESCRIPCION:	Conteo de registros
     #AUTOR:		admin
     #FECHA:		22-01-2014 16:11:04
    ***********************************/

    elsif(p_transaccion='PLA_PLANI_CONT')then

      begin
        --Sentencia de la consulta de conteo de registros

        IF p_administrador !=1 THEN
          v_filtro = ' plani.id_depto IN (' ||(case when (param.f_get_lista_deptos_x_usuario(p_id_usuario, 'ORGA') = '')
            then  '-1'
                                               else param.f_get_lista_deptos_x_usuario(p_id_usuario, 'ORGA')
                                               end) || ') and ';
        else
          v_filtro = '';
        END IF;


        v_consulta:='select count(id_planilla)
					    from plani.tplanilla plani
					    inner join segu.tusuario usu1 on usu1.id_usuario = plani.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = plani.id_usuario_mod
						inner join param.tgestion ges on ges.id_gestion = plani.id_gestion
						left join param.tperiodo per on per.id_periodo = plani.id_periodo
						inner join plani.ttipo_planilla tippla on tippla.id_tipo_planilla = plani.id_tipo_planilla
						left join orga.tuo uo on uo.id_uo = plani.id_uo
					    where ' || v_filtro;

        --Definicion de la respuesta
        v_consulta:=v_consulta||v_parametros.filtro;

        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
#TRANSACCION:  'PLA_REPMINCABE_SEL'
#DESCRIPCION:	Listado de datos para cabecera de reporte de ministerio de trabajo
#AUTOR:		admin
#FECHA:		22-01-2014 16:11:04
***********************************/

    elsif(p_transaccion='PLA_REPMINCABE_SEL')then

      begin
        --Sentencia de la consulta de conteo de registros

        if (exists (	select 1
                      from param.tdepto d
                      where id_depto = v_parametros.id_depto and
                            d.id_entidad is null)) then
          raise exception 'El Departamento de RRHH seleccionado no esta relacionado con una entidad para la obtencion de los datos de la empresa';
        end if;



        v_consulta:='select en.nombre,en.nit,en.identificador_min_trabajo,identificador_caja_salud
					    from param.tdepto dep
                        inner join param.tentidad en on en.id_entidad = dep.id_entidad

					    where dep.id_depto =  ' || v_parametros.id_depto;


        --Devuelve la respuesta
        return v_consulta;

      end;

    /*********************************
    #TRANSACCION:  'PLA_PLANI_CONT'
    #DESCRIPCION:	Conteo de registros
    #AUTOR:		admin
    #FECHA:		22-01-2014 16:11:04
    ***********************************/

    elsif(p_transaccion='PLA_REPMINPRIMA_SEL')then

      begin
        v_consulta = 'with empleados as (
                select
                uo.prioridad,
                uo.id_uo,
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then 1
                        when perso.id_tipo_doc_identificacion = 5 then
                        3
                        ELSE
                        0
                        end)::integer as tipo_documento,
                perso.ci,perso.expedicion,afp.nombre as afp,fafp.nro_afp,perso.apellido_paterno,
                perso.apellido_materno,''''::varchar as apellido_casada,
                split_part(perso.nombre,'' '',1)::varchar as primer_nombre,

                trim(both '' '' from replace(perso.nombre,split_part(perso.nombre,'' '',1), ''''))::varchar as otros_nombres,
                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,
                (case when upper(genero)= ''VARON'' then
                1 else
                0 end)::integer as sexo,
                (case when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                1
                else
                0 end)::integer as jubilado,
                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,
                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,
                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion < (''31/12/''||ges.gestion)::date) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,
                8::integer as horas_dia,
                30::integer as dias_mes,
				ofi.nombre as oficina,
                (case when perso.discapacitado= ''no''  or perso.discapacitado is null then
                ''no'' else
                ''si'' end)::varchar as discapacitado,

                EXTRACT(year from age( (''31/12/''||ges.gestion)::date,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar
                from plani.tplanilla p
                inner join param.tgestion ges on ges.id_gestion = p.id_gestion
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where tp.codigo = ''PLAPRI'' and ges.id_gestion = ' || v_parametros.id_gestion || '
                order by fun.desc_funcionario2 ASC
                )

                select
                emp.fila,emp.tipo_documento,emp.ci,emp.expedicion, emp.afp,emp.nro_afp,emp.apellido_paterno,emp.apellido_materno,emp.apellido_casada,
                emp.primer_nombre,emp.otros_nombres,emp.nacionalidad,to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),emp.sexo,emp.jubilado,emp.clasificacion_laboral,emp.cargo,
                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),emp.modalidad_contrato,to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),emp.horas_dia,cv.codigo_columna,
                (case when cv.codigo_columna = ''HORNORM'' then
                	cv.valor/emp.horas_dia
                else
                	cv.valor
                end)::numeric as valor,
                emp.oficina,emp.discapacitado,
                emp.edad,
                emp.lugar
                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                where cv.codigo_columna in (''PRIMA'',''IMPDET'',''OTDESC'',''TOTDESC'',''LIQPAG'')
                order by emp.fila,tc.orden';
        raise notice '%',v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
        #TRANSACCION:  'PLA_REPMINAGUI_SEL'
        #DESCRIPCION:	Reporte para ministerio de trabajo Aguinaldo
        #AUTOR:		admin
        #FECHA:		22-01-2014 16:11:04
        ***********************************/

    elsif(p_transaccion='PLA_REPMINAGUI_SEL')then

      begin
        v_consulta = 'with empleados as (
                select
                uo.prioridad,
                uo.id_uo,
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then 1
                        when perso.id_tipo_doc_identificacion = 5 then
                        3
                        ELSE
                        0
                        end)::integer as tipo_documento,
                perso.ci,perso.expedicion,(case when afp.nombre = ''PREVISION'' then ''1'' else ''2'' end)::varchar as afp,fafp.nro_afp,perso.apellido_paterno,
                perso.apellido_materno,''''::varchar as apellido_casada,
                split_part(perso.nombre,'' '',1)::varchar as primer_nombre,

                trim(both '' '' from replace(perso.nombre,split_part(perso.nombre,'' '',1), ''''))::varchar as otros_nombres,
                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,
                (case when upper(genero)= ''VARON'' then
                1 else
                0 end)::integer as sexo,
                (case when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                1
                else
                0 end)::integer as jubilado,
                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,
                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,
                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion < (''31/12/''||ges.gestion)::date) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,
                8::integer as horas_dia,
                30::integer as dias_mes,
				ofi.nombre as oficina,
                (case when perso.discapacitado= ''no''  or perso.discapacitado is null then
                ''no'' else
                ''si'' end)::varchar as discapacitado,

                EXTRACT(year from age( (''31/12/''||ges.gestion)::date,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar
                from plani.tplanilla p
                inner join param.tgestion ges on ges.id_gestion = p.id_gestion
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where tp.codigo = ''PLAGUIN'' and ges.id_gestion = ' || v_parametros.id_gestion || '
                order by fun.desc_funcionario2 ASC
                )

                select
                emp.fila,emp.tipo_documento,emp.ci,emp.expedicion, emp.afp,emp.nro_afp,emp.apellido_paterno,emp.apellido_materno,emp.apellido_casada,
                emp.primer_nombre,emp.otros_nombres,emp.nacionalidad,to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),emp.sexo,emp.jubilado,emp.clasificacion_laboral,emp.cargo,
                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),emp.modalidad_contrato,to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),emp.horas_dia,cv.codigo_columna,
                (case when cv.codigo_columna = ''HORNORM'' then
                	cv.valor/emp.horas_dia
                else
                	cv.valor
                end)::numeric as valor,
                emp.oficina,emp.discapacitado,
                emp.edad,
                emp.lugar
                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                where cv.codigo_columna in (''PROMHAB'',''PROMANT'',''PROMFRO'',''PROME'',''DIASAGUI'',''LIQPAG'')
                order by emp.fila,tc.orden';
        raise notice '%',v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
        #TRANSACCION:  'PLA_REPSEGAGUI_SEL'
        #DESCRIPCION:	Reporte para ministerio de trabajo Segundo Aguinaldo
        #AUTOR:		admin
        #FECHA:		22-01-2014 16:11:04
        ***********************************/

    elsif(p_transaccion='PLA_REPSEGAGUI_SEL')then

      begin
        v_consulta = 'with empleados as (
                select
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                uo.prioridad,
                uo.id_uo,

                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then 1
                        when perso.id_tipo_doc_identificacion = 5 then
                        3
                        ELSE
                        0
                        end)::integer as tipo_documento,
                perso.ci,perso.expedicion,afp.nombre as afp,fafp.nro_afp,fun.desc_funcionario2,
                perso.nombre,perso.apellido_paterno,perso.apellido_materno,
                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,
                (case when upper(genero)= ''VARON'' then
                ''M'' else
                ''F'' end)::varchar as sexo,
                (case when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                1
                else
                0 end)::integer as jubilado,
                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,
                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,
                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion < (''31/12/''||ges.gestion)::date) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,
                8::integer as horas_dia,
                30::integer as dias_mes,
				ofi.nombre as oficina,
                (case when perso.discapacitado= ''no''  or perso.discapacitado is null then
                ''no'' else
                ''si'' end)::varchar as discapacitado,
                EXTRACT(year from age( (''31/12/''||ges.gestion)::date,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar
                from plani.tplanilla p
                inner join param.tgestion ges on ges.id_gestion = p.id_gestion
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                 inner join orga.ttipo_contrato tc on car.id_tipo_contrato = tc.id_tipo_contrato
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where tp.codigo = ''PLASEGAGUI'' and tc.codigo in (''PLA'',''EVE'') and ges.id_gestion = ' || v_parametros.id_gestion || '

                )

                select
                emp.fila,emp.ci,emp.apellido_paterno,emp.apellido_materno,emp.nombre,
                emp.nacionalidad,to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),emp.sexo,emp.cargo,
                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),cv.codigo_columna,
               	cv.valor,emp.jubilado,emp.discapacitado
                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                where cv.codigo_columna in (''PROME'',''DIASAGUI'',''AGUINA'')
                order by emp.fila,tc.orden';
        raise notice '%',v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
        #TRANSACCION:  'PLA_R_MINTRASUE_SEL'
        #DESCRIPCION:	Reporte para ministerio de trabajo Formato Nuevo
        #AUTOR:		f.e.a
        #FECHA:		22-02-2018 16:11:04
        ***********************************/
    elsif(p_transaccion='PLA_R_MINTRASUE_SEL')then

      begin
      	--Creamos una tabla donde obtenemos la ultima asignacion de un funcionario
       	/*create temp table tt_orga_filtro (
          	id_funcionario integer,
          	id_uo_funcionario integer
       	)on commit drop;

        v_consulta = 'insert into tt_orga_filtro
                      select tuo.id_funcionario,  max(tuo.id_uo_funcionario)
                      from orga.tuo_funcionario tuo
                      group by  tuo.id_funcionario';

        execute(v_consulta);*/


        v_consulta = 'with empleados as (
                select
                uo.prioridad,
                uo.id_uo,
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then ''CI''
                      when perso.id_tipo_doc_identificacion = 5 then ''PASAPORTE''
                      ELSE ''0'' end)::varchar as tipo_documento,
                perso.ci,perso.expedicion,afp.nombre as afp,fafp.nro_afp,perso.apellido_paterno,
                perso.apellido_materno,''''::varchar as apellido_casada,
                split_part(perso.nombre,'' '',1)::varchar as primer_nombre,

                trim(both '' '' from replace(perso.nombre,split_part(perso.nombre,'' '',1), ''''))::varchar as otros_nombres,
                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,
                (case when upper(genero)= ''VARON'' then
                ''M'' else
                ''F'' end)::varchar as sexo,
                (case
                 when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                  1
                 when fp.id_funcionario = 2710 then
                  1
                else
                  0 end)::integer as jubilado,
                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,
                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,
                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion <= per.fecha_fin) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,
                8::integer as horas_dia,
				ofi.nombre as oficina,
                (case when (perso.discapacitado= ''no'' OR perso.discapacitado= ''NO'') or perso.discapacitado is null then
                0 else
                1 end)::integer as discapacitado,
                per.fecha_ini as inicio_periodo,
                per.fecha_fin as fin_periodo,
                EXTRACT(year from age( per.fecha_fin,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar,
                uofun.observaciones_finalizacion as motivo_retiro,
                car.id_tipo_contrato,
                lug.nombre as lugar_oficina,
                f1.es_tutor,
                per.periodo,
                p.id_planilla
                from plani.tplanilla p
                inner join param.tperiodo per on per.id_periodo = p.id_periodo
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where tp.codigo = ''PLASUE'' and per.id_periodo = ' || v_parametros.id_periodo || '
                order by fun.desc_funcionario2 ASC
                )

                select
                emp.fila,
                emp.tipo_documento,
                emp.ci,
                emp.expedicion,
                to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),
                emp.apellido_paterno,
                emp.apellido_materno,
                (emp.primer_nombre||'' ''||emp.otros_nombres)::varchar as nombres,
                emp.nacionalidad,
                emp.sexo,
                emp.jubilado,
                (case when emp.afp is null and emp.nro_afp is null then 0 else 1 end)::integer as aporta_afp,
                emp.discapacitado,
                (case when emp.es_tutor = ''si'' then 1::integer else 0::integer end) as tutor_discapacidad,
                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),
                coalesce(to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),'''')::text,
                (case when emp.fecha_finalizacion is not null and emp.motivo_retiro = ''fin contrato'' then ''2''
                	  when (emp.fecha_finalizacion is not null or coalesce(to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),'''') != '''') and (emp.motivo_retiro = ''retiro'' or emp.motivo_retiro = ''renuncia'')  then ''1''
                      else '''' end)::varchar as motivo_retiro,
                case when emp.ci = ''630048'' then ''7''
                	 when emp.ci = ''771216'' then ''2''::varchar
                     else ''6''::varchar end as caja_salud,
                (case when emp.afp = ''PREVISION'' then 1 else 2 end)::integer as afp,
                emp.nro_afp,
                --emp.oficina,
                --(''REGIONAL''||'' ''||emp.lugar_oficina)::varchar as oficina,
                (case emp.lugar_oficina when ''COCHABAMBA'' then 1 when ''LA PAZ'' then 2 when ''SANTA CRUZ'' then 3 when ''TRINIDAD'' then 4 when ''TARIJA'' then 5
                when ''COBIJA'' then 6 when ''SUCRE'' then 7 when ''UYUNI'' then 8 when ''POTOSI'' then 9 when ''ORURO'' then 10 when ''CHIMORE'' then 11
                when ''YACUIBA'' then 12 when ''MONTEAGUDO'' then 13 end)::integer as oficina,
                emp.clasificacion_laboral,
                emp.cargo,
                (case when tcont.id_tipo_contrato = 1 then 1 when tcont.id_tipo_contrato = 4 then 2 end)::integer as modalidad_contrato,
                1::integer as tipo_contrato,

                (case when cv.codigo_columna = ''HORNORM'' then
                	cv.valor/emp.horas_dia
                else
                	cv.valor
                end)::numeric as valor,

                emp.horas_dia,cv.codigo_columna,

                (case when emp.fecha_ingreso >= emp.inicio_periodo then
                ''si''
                else
                ''no'' end):: varchar as contrato_periodo,

                (case when emp.fecha_finalizacion < emp.fin_periodo then
                ''si''
                else
                ''no'' end):: varchar as retiro_periodo,

                emp.edad,
                emp.lugar
                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                inner join orga.ttipo_contrato tcont on tcont.id_tipo_contrato = emp.id_tipo_contrato
                where cv.codigo_columna in (''HORNORM'',''SUELDOBA'',''BONANT'',''BONFRONTERA'',''REINBANT'',''COTIZABLE'',''AFP_LAB'',''IMPURET'',''OTRO_DESC'',''TOT_DESC'',''LIQPAG'',''CAJSAL'',''PAGOVAR'',''PAGOFIJ'')
                order by emp.fila,tc.orden';
		raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    elsif(p_transaccion='PLA_REPMINTRASUE_SEL')then

      begin
        v_consulta = 'with empleados as (
                select
                uo.prioridad,
                uo.id_uo,
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then 1
                        when perso.id_tipo_doc_identificacion = 5 then
                        3
                        ELSE
                        0
                        end)::integer as tipo_documento,
                perso.ci,perso.expedicion,afp.nombre as afp,fafp.nro_afp,perso.apellido_paterno,
                perso.apellido_materno,''''::varchar as apellido_casada,
                split_part(perso.nombre,'' '',1)::varchar as primer_nombre,

                trim(both '' '' from replace(perso.nombre,split_part(perso.nombre,'' '',1), ''''))::varchar as otros_nombres,
                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,
                (case when upper(genero)= ''VARON'' then
                1 else
                0 end)::integer as sexo,
                (case when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                1
                else
                0 end)::integer as jubilado,
                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,
                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,
                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion < per.fecha_fin) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,
                8::integer as horas_dia,
				ofi.nombre as oficina,
                (case when perso.discapacitado= ''no''  or perso.discapacitado is null then
                ''no'' else
                ''si'' end)::varchar as discapacitado,
                per.fecha_ini as inicio_periodo,
                per.fecha_fin as fin_periodo,
                EXTRACT(year from age( per.fecha_fin,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar,
                car.id_tipo_contrato
                from plani.tplanilla p
                inner join param.tperiodo per on per.id_periodo = p.id_periodo
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where tp.codigo = ''PLASUE'' and per.id_periodo = ' || v_parametros.id_periodo || '
                order by fun.desc_funcionario2 ASC
                )

                select
                emp.fila,emp.tipo_documento,emp.ci,emp.expedicion, emp.afp,emp.nro_afp,emp.apellido_paterno,emp.apellido_materno,emp.apellido_casada,
                emp.primer_nombre,emp.otros_nombres,emp.nacionalidad,to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),emp.sexo,emp.jubilado,emp.clasificacion_laboral,emp.cargo,
                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),
                --emp.modalidad_contrato,
                (case when tcont.id_tipo_contrato = 1 then 1 when tcont.id_tipo_contrato = 4 then 2 end)::integer as modalidad_contrato,
                to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),emp.horas_dia,cv.codigo_columna,
                (case when cv.codigo_columna = ''HORNORM'' then
                	cv.valor/emp.horas_dia
                else
                	cv.valor
                end)::numeric as valor,

                emp.oficina,emp.discapacitado,
                (case when emp.fecha_ingreso >= emp.inicio_periodo then
                ''si''
                else
                ''no'' end):: varchar as contrato_periodo,
                (case when emp.fecha_finalizacion < emp.fin_periodo then
                ''si''
                else
                ''no'' end):: varchar as retiro_periodo,
                emp.edad,
                emp.lugar
                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                inner join orga.ttipo_contrato tcont on tcont.id_tipo_contrato = emp.id_tipo_contrato
                where cv.codigo_columna in (''HORNORM'',''SUELDOBA'',''BONANT'',''BONFRONTERA'',''REINBANT'',''COTIZABLE'',''AFP_LAB'',''IMPURET'',''OTRO_DESC'',''TOT_DESC'',''LIQPAG'',''CAJSAL'')
                order by emp.fila,tc.orden';

        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
 	#TRANSACCION:  'PLA_REPCERPRE_SEL'
 	#DESCRIPCION:	Reporte Certificación Presupuestaria Planillas
 	#AUTOR:		FEA
 	#FECHA:		14-02-2018 15:00
	***********************************/

	elsif(p_transaccion='PLA_REPCERPRE_SEL')then

		begin

        	SELECT tpl.codigo, tp.id_gestion
            INTO v_desc_planilla, v_id_gestion
            FROM plani.tplanilla tp
            INNER JOIN plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
            WHERE tp.id_proceso_wf =  v_parametros.id_proceso_wf;

            if v_desc_planilla = 'PLASUB' then
            	v_porcentaje = '/0.87';
            else
            	v_porcentaje = '';
            end if;

            --raise exception 'v_desc_planilla: %, v_id_gestion: %', v_desc_planilla, v_id_gestion;
            if v_desc_planilla = 'PLASUB' or v_desc_planilla = 'PLASUE' then

            	select tg.gestion
				into v_gestion
                from param.tgestion tg
                where tg.id_gestion = v_id_gestion;

            	v_inner_periodo = 'inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo
				        		   inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                                   ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                                   (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
                v_id_uo_func_retro = 'tfp.id_uo_funcionario';
                v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla';
                v_factor_zona_franca = '(select fzf.valor  from plani.tcolumna_valor fzf where fzf.id_funcionario_planilla = tfp.id_funcionario_planilla and fzf.codigo_columna = ''FAC_ZONAFRAN'')';
                v_total = 'sum(CASE WHEN ((tcv.codigo_columna = ''SUBLACGAS'' or tcv.codigo_columna = ''SUBPREGAS'') and '||v_factor_zona_franca||' = 1) THEN tcv.valor '||v_porcentaje||' ELSE case when tcv.codigo_columna !=''BONANT'' then tcv.valor else tcv.valor + 0/*(select tcv.valor
                                                                                                                                                                                                                                        from plani.tcolumna_valor tcv
                                                                                                                                                                                                                                        where tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''REINBANT'')*/ end END)::numeric AS precio_total';
            else
             	if v_desc_planilla = 'PLAPRI' then

                	v_cond_categoria =  '(ca.codigo = ''SUPER'' and ((fp.id_funcionario != 10 and fp.id_funcionario !=1030) or (fp.id_funcionario = 10 and tper.periodo <= 7 and (plani.id_gestion = 16 or plani.id_gestion = 15))))';
            		v_cond_admin = '(cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and fp.id_funcionario = 10 and (tper.periodo > 7 or plani.id_gestion >= 16))) AND fp.tipo_contrato != ''CONS''';
            		v_codigo = 'car.codigo = ''0'' and fp.tipo_contrato = ''EVE''';

            		v_id_gestion = v_id_gestion + 1;

                    select tg.gestion
                    into v_gestion
                    from param.tgestion tg
                    where tg.id_gestion = v_id_gestion;

                    v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = 6 and tper.id_gestion = '||v_id_gestion||'
                                       inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                                       ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                                       (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
                    v_id_uo_func_retro = 'tfp.id_uo_funcionario';
                    v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla';
                    v_total = 'sum(CASE WHEN tcv.codigo_columna = ''SUBLACGAS'' or tcv.codigo_columna = ''SUBPREGAS'' THEN tcv.valor '||v_porcentaje||' ELSE tcv.valor END)::numeric AS precio_total';

                elsif v_desc_planilla in ('PLAGUIN', 'PLASEGAGUI') then


                    select tg.gestion
                    into v_gestion
                    from param.tgestion tg
                    where tg.id_gestion = v_id_gestion;
                    --raise exception 'v_desc_planilla: %, v_id_gestion: %, v_gestion: %', v_desc_planilla, v_id_gestion, v_gestion;
                    v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
                    v_id_uo_func_retro = 'tfp.id_uo_funcionario';
                    v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla';
                    v_total = 'sum(CASE WHEN tcv.codigo_columna = ''SUBLACGAS'' or tcv.codigo_columna = ''SUBPREGAS'' THEN tcv.valor '||v_porcentaje||' ELSE tcv.valor END)::numeric AS precio_total';

                elsif v_desc_planilla in ('PLAREISU') then

                    select tg.gestion
                    into v_gestion
                    from param.tgestion tg
                    where tg.id_gestion = v_id_gestion;

                    v_inner_periodo = '--inner join param.tperiodo tper on tper.periodo = 7 and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tht.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tht.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';

                    v_id_uo_func_retro = 'tht.id_uo_funcionario';
                    v_total = 'sum(tcd.valor)::numeric AS precio_total';
                    v_retroactivo = 'inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla
        							 inner join plani.tcolumna_detalle tcd on tcd.id_columna_valor = tcv.id_columna_valor
        							 inner join plani.thoras_trabajadas tht on tht.id_horas_trabajadas = tcd.id_horas_trabajadas';
            	else

                	select tg.gestion
                    into v_gestion
                    from param.tgestion tg
                    where tg.id_gestion = v_id_gestion;

            		v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion||'
				    				   inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                                   	   ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';

                    v_id_uo_func_retro = 'tfp.id_uo_funcionario';
                    v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla';
                    v_total = 'sum(CASE WHEN tcv.codigo_columna = ''SUBLACGAS'' or tcv.codigo_columna = ''SUBPREGAS'' THEN tcv.valor '||v_porcentaje||' ELSE tcv.valor END)::numeric AS precio_total';
                end if;
            end if;

            /*select g.id_gestion
             into v_id_gestion
             from param.tgestion g
             where g.gestion = EXTRACT(YEAR FROM current_date);*/

            v_id_funcionario = 57;

			select vf.desc_funcionario1
            into v_desc_funcionario
            from orga.vfuncionario vf
            where vf.id_funcionario = v_id_funcionario;

        	--Gerencia del funcionario solicitante
        	/*WITH RECURSIVE gerencia(id_uo, id_nivel_organizacional, nombre_unidad, nombre_cargo, codigo) AS (
              SELECT tu.id_uo, tu.id_nivel_organizacional, tu.nombre_unidad, tu.nombre_cargo, tu.codigo
              FROM orga.tuo  tu
              INNER JOIN orga.tuo_funcionario tf ON tf.id_uo = tu.id_uo
              WHERE tf.id_funcionario = v_id_funcionario and tu.estado_reg = 'activo'

              UNION ALL

              SELECT teu.id_uo_padre, tu1.id_nivel_organizacional, tu1.nombre_unidad, tu1.nombre_cargo, tu1.codigo
              FROM orga.testructura_uo teu
              INNER JOIN gerencia g ON g.id_uo = teu.id_uo_hijo
              INNER JOIN orga.tuo tu1 ON tu1.id_uo = teu.id_uo_padre
              WHERE substring(g.nombre_cargo,1,7) <> 'Gerente'
          	)

            SELECT (codigo||'-'||nombre_unidad)::varchar
            INTO v_gerencia
            FROM gerencia
            ORDER BY id_nivel_organizacional asc limit 1;*/
            SELECT tu.id_uo, tu.id_nivel_organizacional, tu.nombre_unidad, tu.nombre_cargo, tu.codigo
            into v_datos_cargo
            FROM orga.tuo  tu
            INNER JOIN orga.tuo_funcionario tf ON tf.id_uo = tu.id_uo
            WHERE tf.id_funcionario = v_id_funcionario and tu.estado_reg = 'activo' and tf.tipo = 'oficial' and tf.estado_reg = 'activo';

            SELECT (tger.codigo||'-'||tger.nombre_unidad)::varchar
            INTO v_gerencia
            FROM orga.tuo  tger
            WHERE tger.id_uo = orga.f_get_uo_gerencia(v_datos_cargo.id_uo, v_id_funcionario, null);
            --end gerencia

            SELECT tpla.estado, tpla.id_estado_wf, 'ninguna 7.7.7'::varchar as obs
            INTO v_record_op
            FROM plani.tplanilla tpla
            WHERE tpla.id_proceso_wf = v_parametros.id_proceso_wf;


            SELECT tpo.nombre
            INTO v_cod_proceso
            FROM wf.tproceso_wf tpw
            INNER JOIN wf.ttipo_proceso ttp ON ttp.id_tipo_proceso = tpw.id_tipo_proceso
            INNER JOIN wf.tproceso_macro tpo ON tpo.id_proceso_macro = ttp.id_proceso_macro
            WHERE tpw.id_proceso_wf = v_parametros.id_proceso_wf;

            IF(v_record_op.estado IN ('vbpresupuestos', 'suppresu', 'comprobante_generado', 'planilla_finalizada'))THEN
              v_index = 1;
              FOR v_record IN (WITH RECURSIVE firmas(id_estado_fw, id_estado_anterior,fecha_reg, codigo, id_funcionario) AS (
                                SELECT tew.id_estado_wf, tew.id_estado_anterior , tew.fecha_reg, te.codigo, tew.id_funcionario
                                FROM wf.testado_wf tew
                                INNER JOIN wf.ttipo_estado te ON te.id_tipo_estado = tew.id_tipo_estado
                                WHERE tew.id_estado_wf = v_record_op.id_estado_wf

                                UNION ALL

                                SELECT ter.id_estado_wf, ter.id_estado_anterior, ter.fecha_reg, te.codigo, ter.id_funcionario
                                FROM wf.testado_wf ter
                                INNER JOIN firmas f ON f.id_estado_anterior = ter.id_estado_wf
                                INNER JOIN wf.ttipo_estado te ON te.id_tipo_estado = ter.id_tipo_estado
                                WHERE f.id_estado_anterior IS NOT NULL
                            )SELECT distinct on (codigo) codigo, fecha_reg , id_estado_fw, id_estado_anterior, id_funcionario FROM firmas ORDER BY codigo, fecha_reg DESC) LOOP

                  IF(v_record.codigo = 'vbpoa' OR v_record.codigo = 'suppresu' OR v_record.codigo = 'vbpresupuestos' OR v_record.codigo = 'comprobante_generado')THEN
                    	SELECT vf.desc_funcionario1, vf.nombre_cargo, vf.oficina_nombre
                        INTO v_record_funcionario
                        FROM orga.vfuncionario_cargo_lugar vf
                        WHERE vf.id_funcionario = v_record.id_funcionario;
                        v_firmas[v_index] = v_record.codigo::VARCHAR||','||v_record.fecha_reg::VARCHAR||','||v_record_funcionario.desc_funcionario1::VARCHAR||','||v_record_funcionario.nombre_cargo::VARCHAR||','||v_record_funcionario.oficina_nombre;
                        v_index = v_index + 1;
                  END IF;
              END LOOP;
            	v_firma_fun = array_to_string(v_firmas,';');
            ELSE
            	v_firma_fun = '';
        	END IF;
        	------
            SELECT (''||te.codigo||' '||te.nombre)::varchar
            INTO v_nombre_entidad
            FROM param.tempresa te;
            ------
            SELECT (''||tda.codigo||' '||tda.nombre)::varchar
            INTO v_direccion_admin
            FROM pre.tdireccion_administrativa tda;
			------
            SELECT (''||tue.codigo||' '||tue.nombre)::varchar
            INTO v_unidad_ejecutora
            FROM pre.tunidad_ejecutora tue;
            ---
      --consulta para obtener entidad tranferencia caja

            select tet.id_entidad_transferencia
            into v_id_seg_cordes
            from pre.tentidad_transferencia tet
            where tet.codigo = '424' and tet.id_gestion = v_id_gestion;

            select tet.id_entidad_transferencia
            into v_id_seg_umss
            from pre.tentidad_transferencia tet
            where tet.codigo = '425'and tet.id_gestion = v_id_gestion;

            --raise notice 'a: %, b: %, c: %, d: %, e: %, f: %, g: %', v_retroactivo,v_id_uo_func_retro, v_inner_periodo, v_columna_valor, v_id_gestion, v_id_seg_cordes, v_id_seg_umss;
            --raise 'fin';
			--Sentencia de la consulta de conteo de registros
			v_consulta:='
            SELECT

            	vcp.id_categoria_programatica AS id_cp, ttc.codigo AS centro_costo,
       			vcp.codigo_programa , vcp.codigo_proyecto, vcp.codigo_actividad, vcp.codigo_fuente_fin, vcp.codigo_origen_fin,
            	tpar.codigo AS codigo_partida, tpar.nombre_partida AS nombre_partida,
            	tcg.codigo AS codigo_cg, tcg.nombre AS nombre_cg,
            	--sum(tcv.valor '||v_porcentaje||')::numeric AS precio_total,

                '||v_total||',

            	''Bs''::varchar AS codigo_moneda, tpla.nro_planilla as num_tramite,

            '''||v_nombre_entidad||'''::varchar AS nombre_entidad,
            COALESCE('''||v_direccion_admin||'''::varchar, '''') AS direccion_admin,
            '''||v_unidad_ejecutora||'''::varchar AS unidad_ejecutora,

            COALESCE('''||v_firma_fun||'''::varchar, '''') AS firmas,

            COALESCE(tpla.observaciones::varchar,'''')::varchar as justificacion,
            COALESCE(tet.codigo::varchar,''00''::varchar) AS codigo_transf,

            '''||v_gerencia||'''::varchar AS unidad_solicitante,

            vfp.desc_funcionario1::varchar as funcionario_solicitante,


            '''||v_cod_proceso||'''::varchar AS codigo_proceso,

            COALESCE(tpla.fecha_planilla,null::date) AS fecha_soli,
            --COALESCE(tg.gestion, (extract(year from now()::date))::integer) AS gestion,
            extract(year from fecha_planilla)::integer as gestion,
            --ts.codigo_poa,
            tpla.codigo_poa as codigo_poa,
            --''descripcion prueba''::varchar as codigo_descripcion
            (select  pxp.list(distinct ob.codigo|| '' ''||ob.descripcion||'' '')
            from pre.tobjetivo ob
            where ob.codigo = ANY (string_to_array(tpla.codigo_poa,'',''))
            )::varchar as codigo_descripcion,
            tfp.tipo_contrato



        FROM plani.tplanilla tpla
        INNER JOIN segu.tusuario tusu on tusu.id_usuario = tpla.id_usuario_reg
        INNER JOIN orga.vfuncionario_persona vfp on vfp.id_persona = tusu.id_persona

        inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpla.id_planilla

		'||v_retroactivo||'

        INNER JOIN orga.tuo_funcionario tuof on tuof.id_uo_funcionario = '||v_id_uo_func_retro||'

     	'||v_inner_periodo||'

        inner join orga.vfuncionario vf on vf.id_funcionario = tfp.id_funcionario

        '||v_columna_valor||'

        inner JOIN conta.trelacion_contable trc on trc.id_tabla = tcv.id_tipo_columna and trc.id_centro_costo = tcp.id_centro_costo and
        case when tfp.tipo_contrato = ''PLA'' then trc.id_tipo_relacion_contable = 27 when tfp.tipo_contrato = ''EVE'' then trc.id_tipo_relacion_contable = 28 when tfp.tipo_contrato = ''CONS'' then trc.id_tipo_relacion_contable = 103 else false end

        inner join param.tcentro_costo tcc on tcc.id_centro_costo = tcp.id_centro_costo
        inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc



        INNER JOIN pre.tpresupuesto	tp ON tp.id_presupuesto = tcc.id_centro_costo
        INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog

		INNER JOIN pre.tpartida tpar ON tpar.id_partida = trc.id_partida and tpar.id_gestion = '||v_id_gestion||'

        left join pre.tpresupuesto_partida_entidad tppe on tppe.id_partida = trc.id_partida and tppe.id_presupuesto = tp.id_presupuesto and tppe.id_gestion = '||v_id_gestion||'
        and case when tcv.codigo_columna = ''CAJSAL'' THEN (case when vf.ci = ''630048'' then tppe.id_entidad_transferencia = '||v_id_seg_umss||' else tppe.id_entidad_transferencia = '||v_id_seg_cordes||' end) else (tppe.id_entidad_transferencia not in ('||v_id_seg_cordes||','||v_id_seg_umss||')) end

        left join pre.tentidad_transferencia tet on tet.id_entidad_transferencia = tppe.id_entidad_transferencia and tet.id_gestion = '||v_id_gestion||'

        left join pre.tclase_gasto_partida tcgp on tcgp.id_partida = trc.id_partida
        left join pre.tclase_gasto tcg on tcg.id_clase_gasto = tcgp.id_clase_gasto
        WHERE tcp.id_gestion = '||v_id_gestion||' and tpla.estado_reg = ''activo'' AND tpla.id_proceso_wf = '||v_parametros.id_proceso_wf;

        v_consulta =  v_consulta ||
            ' GROUP BY
              vcp.id_categoria_programatica,
              ttc.codigo,
              vcp.codigo_programa,vcp.codigo_proyecto, vcp.codigo_actividad, vcp.codigo_fuente_fin, vcp.codigo_origen_fin,
              tpar.codigo , tpar.nombre_partida,
              tcg.codigo, tcg.nombre, tpla.nro_planilla, tet.codigo, tpla.fecha_planilla, tpla.observaciones, tpla.codigo_poa, vfp.desc_funcionario1,
              tfp.tipo_contrato';

		v_consulta =  v_consulta || '
        ORDER BY vcp.codigo_programa, tpar.codigo, tcg.nombre, ttc.codigo asc /*vcp.id_categoria_programatica,*/
        ';

        --Devuelve la respuesta
        RAISE NOTICE 'v_consulta %',v_consulta;
        return v_consulta;

        end;

    /*********************************
 	#TRANSACCION:  'PLA_REPCLACATPRO_SEL'
 	#DESCRIPCION:	Reporte Clasificacion categoria programatica Planillas
 	#AUTOR:		FEA
 	#FECHA:		14-02-2018 15:00
	***********************************/

	elsif(p_transaccion='PLA_REPCLACATPRO_SEL')then

		begin

        	SELECT tpl.codigo, tp.id_gestion
            INTO v_desc_planilla, v_id_gestion
            FROM plani.tplanilla tp
            INNER JOIN plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
            WHERE tp.id_proceso_wf =  v_parametros.id_proceso_wf;

            if v_desc_planilla = 'PLASUB' then
            	v_porcentaje = '/0.87';
            /*else
            	v_porcentaje = '';*/
            end if;

            --raise exception 'v_desc_planilla: %, v_id_gestion: %', v_desc_planilla, v_id_gestion;
            if v_desc_planilla = 'PLASUB' or v_desc_planilla = 'PLASUE' then
            	v_inner_periodo = 'inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo
				        		   inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                                   ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)) or
                                   (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)))';
            else
            	v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion||'
				        		   inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                                   ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)) or
                                   (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)))';
            end if;

            /*select g.id_gestion
             into v_id_gestion
             from param.tgestion g
             where g.gestion = EXTRACT(YEAR FROM current_date);*/

            v_id_funcionario = 57;

			select vf.desc_funcionario1
            into v_desc_funcionario
            from orga.vfuncionario vf
            where vf.id_funcionario = v_id_funcionario;

        	--Gerencia del funcionario solicitante
        	WITH RECURSIVE gerencia(id_uo, id_nivel_organizacional, nombre_unidad, nombre_cargo, codigo) AS (
              SELECT tu.id_uo, tu.id_nivel_organizacional, tu.nombre_unidad, tu.nombre_cargo, tu.codigo
              FROM orga.tuo  tu
              INNER JOIN orga.tuo_funcionario tf ON tf.id_uo = tu.id_uo
              WHERE tf.id_funcionario = v_id_funcionario and tu.estado_reg = 'activo'

              UNION ALL

              SELECT teu.id_uo_padre, tu1.id_nivel_organizacional, tu1.nombre_unidad, tu1.nombre_cargo, tu1.codigo
              FROM orga.testructura_uo teu
              INNER JOIN gerencia g ON g.id_uo = teu.id_uo_hijo
              INNER JOIN orga.tuo tu1 ON tu1.id_uo = teu.id_uo_padre
              WHERE substring(g.nombre_cargo,1,7) <> 'Gerente'
          	)

            SELECT (codigo||'-'||nombre_unidad)::varchar
            INTO v_gerencia
            FROM gerencia
            ORDER BY id_nivel_organizacional asc limit 1;
            --end gerencia

            SELECT tpla.estado, tpla.id_estado_wf, 'ninguna 7.7.7'::varchar as obs
            INTO v_record_op
            FROM plani.tplanilla tpla
            WHERE tpla.id_proceso_wf = v_parametros.id_proceso_wf;


            SELECT tpo.nombre
            INTO v_cod_proceso
            FROM wf.tproceso_wf tpw
            INNER JOIN wf.ttipo_proceso ttp ON ttp.id_tipo_proceso = tpw.id_tipo_proceso
            INNER JOIN wf.tproceso_macro tpo ON tpo.id_proceso_macro = ttp.id_proceso_macro
            WHERE tpw.id_proceso_wf = v_parametros.id_proceso_wf;

            IF(v_record_op.estado IN ('vbpresupuestos', 'suppresu', 'comprobante_generado', 'planilla_finalizada'))THEN
              v_index = 1;
              FOR v_record IN (WITH RECURSIVE firmas(id_estado_fw, id_estado_anterior,fecha_reg, codigo, id_funcionario) AS (
                                SELECT tew.id_estado_wf, tew.id_estado_anterior , tew.fecha_reg, te.codigo, tew.id_funcionario
                                FROM wf.testado_wf tew
                                INNER JOIN wf.ttipo_estado te ON te.id_tipo_estado = tew.id_tipo_estado
                                WHERE tew.id_estado_wf = v_record_op.id_estado_wf

                                UNION ALL

                                SELECT ter.id_estado_wf, ter.id_estado_anterior, ter.fecha_reg, te.codigo, ter.id_funcionario
                                FROM wf.testado_wf ter
                                INNER JOIN firmas f ON f.id_estado_anterior = ter.id_estado_wf
                                INNER JOIN wf.ttipo_estado te ON te.id_tipo_estado = ter.id_tipo_estado
                                WHERE f.id_estado_anterior IS NOT NULL
                            )SELECT distinct on (codigo) codigo, fecha_reg , id_estado_fw, id_estado_anterior, id_funcionario FROM firmas ORDER BY codigo, fecha_reg DESC) LOOP

                  IF(v_record.codigo = 'vbpoa' OR v_record.codigo = 'suppresu' OR v_record.codigo = 'vbpresupuestos' OR v_record.codigo = 'comprobante_generado')THEN
                    	SELECT vf.desc_funcionario1, vf.nombre_cargo, vf.oficina_nombre
                        INTO v_record_funcionario
                        FROM orga.vfuncionario_cargo_lugar vf
                        WHERE vf.id_funcionario = v_record.id_funcionario;
                        v_firmas[v_index] = v_record.codigo::VARCHAR||','||v_record.fecha_reg::VARCHAR||','||v_record_funcionario.desc_funcionario1::VARCHAR||','||v_record_funcionario.nombre_cargo::VARCHAR||','||v_record_funcionario.oficina_nombre;
                        v_index = v_index + 1;
                  END IF;
              END LOOP;
            	v_firma_fun = array_to_string(v_firmas,';');
            ELSE
            	v_firma_fun = '';
        	END IF;
        	------
            SELECT (''||te.codigo||' '||te.nombre)::varchar
            INTO v_nombre_entidad
            FROM param.tempresa te;
            ------
            SELECT (''||tda.codigo||' '||tda.nombre)::varchar
            INTO v_direccion_admin
            FROM pre.tdireccion_administrativa tda;
			------
            SELECT (''||tue.codigo||' '||tue.nombre)::varchar
            INTO v_unidad_ejecutora
            FROM pre.tunidad_ejecutora tue;
            ---
      --consulta para obtener entidad tranferencia caja

            select tet.id_entidad_transferencia
            into v_id_seg_cordes
            from pre.tentidad_transferencia tet
            where tet.codigo = '424' and tet.id_gestion = v_id_gestion;

            select tet.id_entidad_transferencia
            into v_id_seg_umss
            from pre.tentidad_transferencia tet
            where tet.codigo = '425'and tet.id_gestion = v_id_gestion;
			--Sentencia de la consulta de conteo de registros
			v_consulta:='
            SELECT

            vcp.codigo_categoria::varchar,
            (''(''||ttc.codigo||'')''||ttc.descripcion)::varchar as presupuesto,
            vf.desc_funcionario2::varchar as desc_funcionario,
            tcar.nombre::varchar as cargo,
            tofi.nombre::varchar as oficina,
            ''Bs''::varchar AS codigo_moneda,
            tpla.nro_planilla as num_tramite,
            '''||v_nombre_entidad||'''::varchar AS nombre_entidad,
            COALESCE('''||v_direccion_admin||'''::varchar, '''') AS direccion_admin,
            '''||v_unidad_ejecutora||'''::varchar AS unidad_ejecutora,
             COALESCE('''||v_firma_fun||'''::varchar, '''') AS firmas,
            COALESCE(tpla.observaciones::varchar,'''')::varchar as justificacion,
            COALESCE(tet.codigo::varchar,''00''::varchar) AS codigo_transf,
            '''||v_gerencia||'''::varchar AS unidad_solicitante,
            vfp.desc_funcionario1::varchar as funcionario_solicitante,
            '''||v_cod_proceso||'''::varchar AS codigo_proceso,
            COALESCE(tpla.fecha_planilla,null::date) AS fecha_soli,
            extract(year from fecha_planilla)::integer as gestion,
            tpla.codigo_poa as codigo_poa,
            (select  pxp.list(distinct ob.codigo|| '' ''||ob.descripcion||'' '')
            from pre.tobjetivo ob
            where ob.codigo = ANY (string_to_array(tpla.codigo_poa,'',''))
            )::varchar as codigo_descripcion
            FROM plani.tplanilla tpla
            INNER JOIN segu.tusuario tusu on tusu.id_usuario = tpla.id_usuario_reg
        	INNER JOIN orga.vfuncionario_persona vfp on vfp.id_persona = tusu.id_persona

            inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpla.id_planilla
            INNER JOIN orga.tuo_funcionario tuof on tuof.id_uo_funcionario = tfp.id_uo_funcionario
            '||v_inner_periodo||'
            inner join plani.ttipo_planilla ttp on ttp.id_tipo_planilla = tpla.id_tipo_planilla
            inner join orga.tcargo tcar on tcar.id_cargo = tcp.id_cargo
            inner join orga.toficina tofi on tofi.id_oficina = tcar.id_oficina
            inner join orga.vfuncionario vf on vf.id_funcionario = tfp.id_funcionario
            inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla
            inner JOIN conta.trelacion_contable trc on trc.id_tabla = tcv.id_tipo_columna and trc.id_centro_costo = tcp.id_centro_costo and trc.id_gestion = 16 and
            case when tfp.tipo_contrato = ''PLA'' then trc.id_tipo_relacion_contable = 27 when tfp.tipo_contrato = ''EVE'' then trc.id_tipo_relacion_contable = 28  end
            inner join param.tcentro_costo tcc on tcc.id_centro_costo = tcp.id_centro_costo and tcc.id_gestion = '||v_id_gestion||'
            inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc
            INNER JOIN pre.tpresupuesto	tp ON tp.id_presupuesto = tcc.id_centro_costo
            INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog and vcp.id_gestion = 1'||v_id_gestion||'

            INNER JOIN pre.tpartida tpar ON tpar.id_partida = trc.id_partida and tpar.id_gestion = '||v_id_gestion||'

            left join pre.tpresupuesto_partida_entidad tppe on tppe.id_partida = trc.id_partida and tppe.id_presupuesto = tp.id_presupuesto and tppe.id_gestion = '||v_id_gestion||'
            and case when tcv.codigo_columna = ''CAJSAL'' THEN (case when vf.ci = ''630048'' then tppe.id_entidad_transferencia = '||v_id_seg_umss||' else tppe.id_entidad_transferencia = '||v_id_seg_cordes||' end) else (tppe.id_entidad_transferencia not in ('||v_id_seg_cordes||','||v_id_seg_umss||')) end

            left join pre.tentidad_transferencia tet on tet.id_entidad_transferencia = tppe.id_entidad_transferencia and tet.id_gestion = '||v_id_gestion||'

            INNER join pre.tclase_gasto_partida tcgp on tcgp.id_partida = trc.id_partida
            INNER join pre.tclase_gasto tcg on tcg.id_clase_gasto = tcgp.id_clase_gasto
            WHERE tcp.id_gestion = 16 and tpla.estado_reg = ''activo'' AND tpla.id_proceso_wf = '||v_parametros.id_proceso_wf;

        v_consulta =  v_consulta ||
            ' GROUP BY
              vcp.codigo_categoria, presupuesto, vf.desc_funcionario2,tcar.nombre, tofi.nombre ';

		v_consulta =  v_consulta || 'ORDER BY vcp.codigo_categoria asc, presupuesto asc, vf.desc_funcionario2 asc  ';

        --Devuelve la respuesta
        RAISE NOTICE 'v_consulta %',v_consulta;
        return v_consulta;

        end;
    /*********************************
        #TRANSACCION:  'PLA_MINTRA_AGUI_SEL'
        #DESCRIPCION:	Reporte para ministerio de trabajo Formato Nuevo AGUINALDO
        #AUTOR:		f.e.a
        #FECHA:		18-02-2018 15:00:00
        ***********************************/
    elsif(p_transaccion='PLA_MINTRA_AGUI_SEL')then

      begin

        v_consulta = 'with empleados as (
                select
                uo.prioridad,
                uo.id_uo,
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then ''CI''
                      when perso.id_tipo_doc_identificacion = 5 then ''PASAPORTE''
                      ELSE ''0'' end)::varchar as tipo_documento,
                perso.ci,
                perso.expedicion,
                afp.nombre as afp,
                fafp.nro_afp,
                perso.apellido_paterno,
                perso.apellido_materno,
                ''''::varchar as apellido_casada,
                split_part(perso.nombre,'' '',1)::varchar as primer_nombre,

                trim(both '' '' from replace(perso.nombre,split_part(perso.nombre,'' '',1), ''''))::varchar as otros_nombres,

                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,

                (case when upper(genero)= ''VARON'' then
                ''M'' else
                ''F'' end)::varchar as sexo,

                (case when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                1
                else
                0 end)::integer as jubilado,

                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,

                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,

                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion <= p.fecha_planilla) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,

                8::integer as horas_dia,
                30::integer as dias_mes,
				ofi.nombre as oficina,
                (case when (perso.discapacitado= ''no'' OR perso.discapacitado= ''NO'') or perso.discapacitado is null then
                0 else
                1 end)::integer as discapacitado,

                p.fecha_planilla as inicio_periodo,
                p.fecha_planilla as fin_periodo,

                EXTRACT(year from age( p.fecha_planilla,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar,
                uofun.observaciones_finalizacion as motivo_retiro,
                car.id_tipo_contrato,
                lug.nombre as lugar_oficina,
                f1.es_tutor
                from plani.tplanilla p
                --inner join param.tperiodo per on per.id_periodo = p.id_periodo
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where p.modalidad in (''administrativo'',''piloto'') and tp.codigo = ''PLAGUIN'' and p.id_gestion = ' || v_parametros.id_gestion || '
                order by fun.desc_funcionario2 ASC
                )

                select
                emp.fila,
                emp.tipo_documento,
                emp.ci,
                emp.expedicion,
                to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),
                emp.apellido_paterno,
                emp.apellido_materno,
                (emp.primer_nombre||'' ''||emp.otros_nombres)::varchar as nombres,
                emp.nacionalidad,
                emp.sexo,
                emp.jubilado,

                (case when emp.afp is null and emp.nro_afp is null then 0 else 1 end)::integer as aporta_afp,
                emp.discapacitado,
                (case when emp.es_tutor = ''si'' then 1::integer else 0::integer end) as tutor_discapacidad,

                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),
                coalesce(to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),'''')::text,

                (case when emp.fecha_finalizacion is not null and emp.motivo_retiro = ''fin contrato'' then ''2''
                	  when (emp.fecha_finalizacion is not null or coalesce(to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),'''') != '''') and (emp.motivo_retiro = ''retiro'' or emp.motivo_retiro = ''renuncia'')  then ''1''
                      else '''' end)::varchar as motivo_retiro,

                case when emp.ci = ''630048'' then ''7'' else ''6''::varchar end as caja_salud,
                (case when emp.afp = ''PREVISION'' then 1 else 2 end)::integer as afp,
                emp.nro_afp,
                --emp.oficina,
                --(''REGIONAL''||'' ''||emp.lugar_oficina)::varchar as oficina,
                (case emp.lugar_oficina when ''COCHABAMBA'' then 1 when ''LA PAZ'' then 2 when ''SANTA CRUZ'' then 3 when ''TRINIDAD'' then 4 when ''TARIJA'' then 5
                when ''COBIJA'' then 6 when ''SUCRE'' then 7 when ''UYUNI'' then 8 when ''POTOSI'' then 9 when ''ORURO'' then 10 when ''CHIMORE'' then 11
                when ''YACUIBA'' then 12 when ''MONTEAGUDO'' then 13 end)::integer as oficina,
                emp.clasificacion_laboral,
                emp.cargo,
                (case when tcont.id_tipo_contrato = 1 then 1 when tcont.id_tipo_contrato = 4 then 2 end)::integer as modalidad_contrato,
                1::integer as tipo_contrato,

                (case when cv.codigo_columna = ''HORNORM'' then
                	cv.valor/emp.horas_dia
                else
                	cv.valor
                end)::numeric as valor,

                emp.horas_dia,
                cv.codigo_columna,

                (case when emp.fecha_ingreso >= emp.inicio_periodo then
                ''si''
                else
                ''no'' end):: varchar as contrato_periodo,

                (case when emp.fecha_finalizacion < emp.fin_periodo then
                ''si''
                else
                ''no'' end):: varchar as retiro_periodo,

                emp.edad,
                emp.lugar

                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                inner join orga.ttipo_contrato tcont on tcont.id_tipo_contrato = emp.id_tipo_contrato
                where cv.codigo_columna in (''PROMHAB'',''PROMANT'',''PROMFRO'',''PROME'',''DIASAGUI'',''LIQPAG'')
                order by emp.fila,tc.orden';
		raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
        #TRANSACCION:  'PLA_MINTRA_SAGUI_SEL'
        #DESCRIPCION:	Reporte para ministerio de trabajo Formato Nuevo Segundo AGUINALDO
        #AUTOR:		f.e.a
        #FECHA:		01-12-2018 15:00:00
        ***********************************/
    elsif(p_transaccion='PLA_MINTRA_SAGUI_SEL')then

      begin

        v_consulta = 'with empleados as (
                select
                uo.prioridad,
                uo.id_uo,
                (row_number() over (ORDER BY fun.desc_funcionario2 ASC))::integer as fila,
                fp.id_funcionario_planilla,
                (case when perso.id_tipo_doc_identificacion = 1 then ''CI''
                      when perso.id_tipo_doc_identificacion = 5 then ''PASAPORTE''
                      ELSE ''0'' end)::varchar as tipo_documento,
                perso.ci,
                perso.expedicion,
                afp.nombre as afp,
                fafp.nro_afp,
                perso.apellido_paterno,
                perso.apellido_materno,
                ''''::varchar as apellido_casada,
                split_part(perso.nombre,'' '',1)::varchar as primer_nombre,

                trim(both '' '' from replace(perso.nombre,split_part(perso.nombre,'' '',1), ''''))::varchar as otros_nombres,

                (case when lower(perso.nacionalidad) like ''%bolivi%'' then
                ''Bolivia''
                ELSE
                perso.nacionalidad
                end)::varchar as nacionalidad,
                perso.fecha_nacimiento,

                (case when upper(genero)= ''VARON'' then
                ''M'' else
                ''F'' end)::varchar as sexo,

                (case when fafp.tipo_jubilado in (''jubilado_65'',''jubilado_55'') then
                1
                else
                0 end)::integer as jubilado,

                ''''::varchar as clasificacion_laboral,
                car.nombre as cargo,

                 plani.f_get_fecha_primer_contrato_empleado(fp.id_uo_funcionario, fp.id_funcionario, uofun.fecha_asignacion) as fecha_ingreso,
                1::integer as modalidad_contrato,

                (case when (uofun.fecha_finalizacion is not null and uofun.fecha_finalizacion <= p.fecha_planilla) then
                	(case when (orga.f_existe_sgte_asignacion(uofun.fecha_finalizacion, uofun.id_funcionario) = 1) then
                    	NULL
                    else
                    	uofun.fecha_finalizacion
                    end)
                else
                	NULL
                end)::date as fecha_finalizacion,

                8::integer as horas_dia,
                30::integer as dias_mes,
				ofi.nombre as oficina,
                (case when (perso.discapacitado= ''no'' OR perso.discapacitado= ''NO'') or perso.discapacitado is null then
                0 else
                1 end)::integer as discapacitado,

                p.fecha_planilla as inicio_periodo,
                p.fecha_planilla as fin_periodo,

                EXTRACT(year from age( p.fecha_planilla,perso.fecha_nacimiento ))::integer as edad,
                lug.nombre as lugar,
                uofun.observaciones_finalizacion as motivo_retiro,
                car.id_tipo_contrato,
                lug.nombre as lugar_oficina,
                f1.es_tutor
                from plani.tplanilla p
                --inner join param.tperiodo per on per.id_periodo = p.id_periodo
                inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                inner join orga.tfuncionario f1 on f1.id_funcionario = fp.id_funcionario
                inner join segu.tpersona perso on perso.id_persona = f1.id_persona
                inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                left join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(uofun.id_uo, NULL, NULL)
                inner join plani.tfuncionario_afp fafp on fafp.id_funcionario_afp = fp.id_afp
                inner join plani.tafp afp on afp.id_afp = fafp.id_afp
                where tp.codigo = ''PLASEGAGUI'' and (p.fecha_planilla between ''20/12/2018''::date and ''31/12/2018''::date) and p.id_gestion = ' || v_parametros.id_gestion || '
                order by fun.desc_funcionario2 ASC
                )

                select
                emp.fila,
                emp.tipo_documento,
                emp.ci,
                emp.expedicion,
                to_char(emp.fecha_nacimiento,''DD/MM/YYYY''),
                emp.apellido_paterno,
                emp.apellido_materno,
                (emp.primer_nombre||'' ''||emp.otros_nombres)::varchar as nombres,
                emp.nacionalidad,
                emp.sexo,
                emp.jubilado,

                (case when emp.afp is null and emp.nro_afp is null then 0 else 1 end)::integer as aporta_afp,
                emp.discapacitado,
                (case when emp.es_tutor = ''si'' then 1::integer else 0::integer end) as tutor_discapacidad,

                to_char(emp.fecha_ingreso,''DD/MM/YYYY''),
                coalesce(to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),'''')::text,

                (case when emp.fecha_finalizacion is not null and emp.motivo_retiro = ''fin contrato'' then ''2''
                	  when (emp.fecha_finalizacion is not null or coalesce(to_char(emp.fecha_finalizacion,''DD/MM/YYYY''),'''') != '''') and (emp.motivo_retiro = ''retiro'' or emp.motivo_retiro = ''renuncia'')  then ''1''
                      else '''' end)::varchar as motivo_retiro,

                case when emp.ci = ''630048'' then ''7'' else ''6''::varchar end as caja_salud,
                (case when emp.afp = ''PREVISION'' then 1 else 2 end)::integer as afp,
                emp.nro_afp,
                --emp.oficina,
                --(''REGIONAL''||'' ''||emp.lugar_oficina)::varchar as oficina,
                (case emp.lugar_oficina when ''COCHABAMBA'' then 1 when ''LA PAZ'' then 2 when ''SANTA CRUZ'' then 3 when ''TRINIDAD'' then 4 when ''TARIJA'' then 5
                when ''COBIJA'' then 6 when ''SUCRE'' then 7 when ''UYUNI'' then 8 when ''POTOSI'' then 9 when ''ORURO'' then 10 when ''CHIMORE'' then 11
                when ''YACUIBA'' then 12 when ''MONTEAGUDO'' then 13 end)::integer as oficina,
                emp.clasificacion_laboral,
                emp.cargo,
                (case when tcont.id_tipo_contrato = 1 then 1 when tcont.id_tipo_contrato = 4 then 2 end)::integer as modalidad_contrato,
                1::integer as tipo_contrato,

                (case when cv.codigo_columna = ''HORNORM'' then
                	cv.valor/emp.horas_dia
                else
                	cv.valor
                end)::numeric as valor,

                emp.horas_dia,
                cv.codigo_columna,

                (case when emp.fecha_ingreso >= emp.inicio_periodo then
                ''si''
                else
                ''no'' end):: varchar as contrato_periodo,

                (case when emp.fecha_finalizacion < emp.fin_periodo then
                ''si''
                else
                ''no'' end):: varchar as retiro_periodo,

                emp.edad,
                emp.lugar

                from empleados emp
                inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = emp.id_funcionario_planilla
                inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                inner join orga.ttipo_contrato tcont on tcont.id_tipo_contrato = emp.id_tipo_contrato
                where cv.codigo_columna in (''PROMHAB'',''PROMANT'',''PROMFRO'',''PROME'',''DIASAGUI'',''LIQPAG'')
                order by emp.fila,tc.orden';
		raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
        #TRANSACCION:  'PLA_REP_SIGMAC31_SEL'
        #DESCRIPCION:	Reporte para sacar Formulario C31 SIGMA
        #AUTOR:		f.e.a
        #FECHA:		30-01-2019 15:00:00
        ***********************************/
    elsif(p_transaccion='PLA_REP_SIGMAC31_SEL')then

      begin

      	SELECT tpl.codigo, tp.id_gestion, coalesce(tp.id_periodo, 0)
        INTO v_desc_planilla, v_id_gestion, v_id_periodo
        FROM plani.tplanilla tp
        INNER JOIN plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
        WHERE tp.id_proceso_wf =  v_parametros.id_proceso_wf;



        if v_desc_planilla in ('PLASUB', 'PLASUE', 'PLAGUIN', 'PLASEGAGUI') then

        	  v_cond_categoria = '(ca.codigo = ''SUPER'' and tfp.id_funcionario NOT IN (select tuo.id_funcionario
            from  orga.tuo_funcionario tuo
            inner join orga.tcargo tca on tca.id_cargo = tuo.id_cargo
            where  tuo.estado_reg = ''activo'' and  tca.codigo = ''1'' and tca.estado_reg = ''activo''))';

            v_cond_gestion = 'tcp.id_gestion = '||v_id_gestion||' and ';

            v_cond_admin = '(vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario IN (select tuo.id_funcionario
            from  orga.tuo_funcionario tuo
            inner join orga.tcargo tca on tca.id_cargo = tuo.id_cargo
            where  tuo.estado_reg = ''activo'' and  tca.codigo = ''1'' and tca.estado_reg = ''activo'') AND tfp.tipo_contrato != ''CONS''))';

            v_codigo = 'tcar.codigo = ''0'' and tfp.tipo_contrato = ''EVE''';
            --v_sumatoria = 'sum(tcv.valor)::numeric';
            v_sumatoria = 'sum(CASE WHEN ((tcv.codigo_columna = ''SUBLACGAS'' or tcv.codigo_columna = ''SUBPREGAS'') AND tcv.valor!=0) THEN CASE WHEN (2000*0.13 + tcv.valor)>2000 THEN (4000*0.13 + tcv.valor) ELSE (2000*0.13 + tcv.valor) END ELSE case when tcv.codigo_columna != ''BONANT'' then tcv.valor else tcv.valor + (select tcv.valor
                                                                                                                                                                                                                                                                                                                                     from plani.tcolumna_valor tcv
                                                                                                                                                                                                                                                                                                                                     where tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = ''REINBANT'') end END)::numeric';
        elsif v_desc_planilla = 'PLAPRI' then

            v_cond_categoria =  '(ca.codigo = ''SUPER'' and ((tfp.id_funcionario != 10 and tfp.id_funcionario !=1030) or (tfp.id_funcionario = 10 and tper.periodo <= 7 and (tpla.id_gestion = 16 or tpla.id_gestion = 15))))';
            v_cond_gestion = 'tpla.id_gestion = '||v_id_gestion||' and ';
            v_cond_admin = '(vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario = 10 and (tper.periodo > 7 or tpla.id_gestion >= 16))) AND tfp.tipo_contrato != ''CONS''';
            v_sumatoria = 'sum(tcv.valor)::numeric';
            v_codigo = 'tcar.codigo = ''0'' and tfp.tipo_contrato = ''EVE''';

            v_id_gestion = v_id_gestion + 1;
        elsif v_desc_planilla = 'PLAREISU' then
        	v_cond_categoria = '(ca.codigo = ''SUPER'' and (tfp.id_funcionario != 10 or (tfp.id_funcionario = 10 and tpla.id_gestion = 16)))';
            v_cond_admin = '(vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario = 10 and (tpla.id_gestion >= 16))) AND tfp.tipo_contrato != ''CONS''';
            v_cond_gestion = 'tcp.id_gestion = '||v_id_gestion||' and ';
            v_sumatoria = 'sum(tcd.valor)::numeric';
            v_codigo = 'tcar.codigo = ''0''';
        end if;

        select tg.gestion
        into v_gestion
        from param.tgestion tg
        where tg.id_gestion = v_id_gestion;

        if v_desc_planilla = 'PLASUB' or v_desc_planilla = 'PLASUE' then
        	v_id_uo_func_retro = 'tfp.id_uo_funcionario';
            v_inner_periodo = 'inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';

            v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla ';
            v_periodo_group = 'tper.periodo,';
        elsif v_desc_planilla = 'PLAPRI' then
        	v_id_uo_func_retro = 'tfp.id_uo_funcionario';
        	v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = 6 and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
        	v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla ';
            v_periodo_group = 'tper.periodo,';
        elsif v_desc_planilla = 'PLAREISU' then
        	v_id_uo_func_retro = 'tht.id_uo_funcionario';
        	v_periodo_retro = '
            				inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla
                      		inner join plani.tcolumna_detalle tcd on tcd.id_columna_valor = tcv.id_columna_valor
                      		inner join plani.thoras_trabajadas tht on tht.id_horas_trabajadas = tcd.id_horas_trabajadas';

            v_inner_periodo = 'inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                        ((tht.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)) or
                        (tht.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)))';

            v_periodo_group = '0::integer,';
        else
        	v_id_uo_func_retro = 'tfp.id_uo_funcionario';
            v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
            v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla ';
            v_periodo_group = 'tper.periodo,';
        end if;



        --v_mes = {'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre', 'Diciembre'};
        --consulta para obtener entidad tranferencia caja

            select tet.id_entidad_transferencia
            into v_id_seg_cordes
            from pre.tentidad_transferencia tet
            where tet.codigo = '424' and tet.id_gestion = v_id_gestion;

            select tet.id_entidad_transferencia
            into v_id_seg_umss
            from pre.tentidad_transferencia tet
            where tet.codigo = '425'and tet.id_gestion = v_id_gestion;

        v_consulta = 'SELECT
                      (case
                                when lower(ger.nombre_unidad) like ''%cobija%'' or tcar.nombre like ''%CIJ%'' then
                                    ''5.CIJ''
                                when '||v_codigo||' then
                                    ''6.EVE''
                                when '||v_cond_categoria||' then
                                    ''3.ESP''
                                when '||v_cond_admin||'  then
                                    ''1.ADM''
                                when vcp.desc_programa ilike ''%OPE%'' then
                                    ''2.OPE''
                                when vcp.desc_programa ilike ''%COM%'' then
                                    ''4.COM''
                                else
                                    ''7.CONSULTORES''
                                end
                                )::varchar as categoria_prog,
                      vcp.codigo_programa::varchar as programa,
                      vcp.codigo_proyecto::varchar as proyecto,
                      vcp.codigo_actividad::varchar as actividad,
                      vcp.codigo_fuente_fin::varchar as fuente_fin,
                      vcp.codigo_origen_fin::varchar as origen_fin,

                      COALESCE(tet.codigo::varchar,''00''::varchar) AS codigo_transf,
                      tpar.codigo::varchar as cod_partida,
                      tpar.nombre_partida::varchar AS nombre_partida,
                      '||v_sumatoria||' AS precio_total,

                      extract(year from fecha_planilla)::varchar as gestion,
                      ''<b>578</b> Boliviana de Aviación - BoA''::varchar AS entidad,
                      ''<b>1</b> Boliviana de Aviación - BoA''::varchar AS direccion_admin,
                      ''<b>1</b> Boliviana de Aviación - BoA''::varchar AS unidad_ejecutora,
                      tcg.codigo::varchar AS clase_gasto,
                      tipp.periodicidad::varchar as tipo_proceso,
                      vcp.desc_programa::varchar,
                      '||v_periodo_group||'--tper.periodo::varchar,
                      '''||v_desc_planilla||'''::varchar as tipo_planilla,
                      tpla.observaciones::varchar


                      FROM plani.tplanilla tpla
                      inner join plani.ttipo_planilla tipp on tipp.id_tipo_planilla = tpla.id_tipo_planilla
                      inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpla.id_planilla
                      '||v_periodo_retro||'
                      INNER JOIN orga.tuo_funcionario tuof on tuof.id_uo_funcionario = '||v_id_uo_func_retro||'
                      INNER JOIN ORGA.tcargo tcar on tcar.id_cargo = tuof.id_cargo
                      INNER JOIN ORGA.tescala_salarial es ON es.id_escala_salarial = tcar.id_escala_salarial
                      INNER JOIN ORGA.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                      inner JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(tuof.id_uo, NULL::integer, NULL::date)

                      '||v_inner_periodo||'

                      inner join orga.vfuncionario vf on vf.id_funcionario = tfp.id_funcionario

                      '||v_columna_valor||'

                      inner JOIN conta.trelacion_contable trc on trc.id_tabla = tcv.id_tipo_columna and trc.id_centro_costo = tcp.id_centro_costo and
                      case when tfp.tipo_contrato = ''PLA'' then trc.id_tipo_relacion_contable = 27 when tfp.tipo_contrato = ''EVE'' then trc.id_tipo_relacion_contable = 28 when tfp.tipo_contrato = ''CONS'' then trc.id_tipo_relacion_contable = 103 else false end

                      inner join param.tcentro_costo tcc on tcc.id_centro_costo = tcp.id_centro_costo
                      inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc

                      INNER JOIN pre.tpresupuesto	tp ON tp.id_presupuesto = tcc.id_centro_costo
                      INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog

                      INNER JOIN pre.tpartida tpar ON tpar.id_partida = trc.id_partida and tpar.id_gestion = '||v_id_gestion||'

                      left join pre.tpresupuesto_partida_entidad tppe on tppe.id_partida = trc.id_partida and tppe.id_presupuesto = tp.id_presupuesto and tppe.id_gestion = '||v_id_gestion||'
                      and case when tcv.codigo_columna = ''CAJSAL'' THEN (case when vf.ci = ''630048'' then tppe.id_entidad_transferencia = '||v_id_seg_umss||' else tppe.id_entidad_transferencia = '||v_id_seg_cordes||' end) else (tppe.id_entidad_transferencia not in ('||v_id_seg_cordes||','||v_id_seg_umss||')) end

                      left join pre.tentidad_transferencia tet on tet.id_entidad_transferencia = tppe.id_entidad_transferencia and tet.id_gestion = '||v_id_gestion||'

                      left join pre.tclase_gasto_partida tcgp on tcgp.id_partida = trc.id_partida
                      left join pre.tclase_gasto tcg on tcg.id_clase_gasto = tcgp.id_clase_gasto
                      WHERE '||v_cond_gestion||' tpla.estado_reg = ''activo'' AND tpla.id_proceso_wf = '||v_parametros.id_proceso_wf||'
                      GROUP BY
                            vcp.codigo_categoria,
                            vcp.codigo_programa, vcp.codigo_proyecto, vcp.codigo_actividad, vcp.codigo_fuente_fin, vcp.codigo_origen_fin,
                            ger.nombre_unidad, tcar.codigo, ca.codigo,tfp.id_funcionario,vcp.desc_programa,
                            tpar.codigo,
                            tpar.nombre_partida,
                            tet.codigo,
                            tcg.codigo,
                            fecha_planilla,
                            tipp.periodicidad,
                            '||v_periodo_group||'
                            tcar.nombre,
                            tpla.id_gestion,
                            tpla.observaciones,
                            tfp.tipo_contrato
                      ORDER BY categoria_prog asc, vcp.codigo_categoria,  tpar.codigo asc';
		raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
    #TRANSACCION:  'PLA_RETEN_C31_SEL'
    #DESCRIPCION:	Detalle para sacar Formulario C31 SIGMA Retenciones
    #AUTOR:		f.e.a
    #FECHA:		30-01-2019 15:00:00
    ***********************************/
    elsif(p_transaccion='PLA_RETEN_C31_SEL')then

      begin

      	SELECT tpl.codigo, tp.id_gestion, coalesce(tp.id_periodo, 0)
        INTO v_desc_planilla, v_id_gestion, v_id_periodo
        FROM plani.tplanilla tp
        INNER JOIN plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
        WHERE tp.id_proceso_wf =  v_parametros.id_proceso_wf;



        if v_desc_planilla in ('PLASUB', 'PLASUE', 'PLAGUIN', 'PLASEGAGUI') then

        	v_cond_categoria = '(ca.codigo = ''SUPER'' and (tfp.id_funcionario != 10 or (tfp.id_funcionario = 10 and tper.periodo <= 7 and tpla.id_gestion = 16)))';
            v_cond_gestion = 'tcp.id_gestion = '||v_id_gestion||' and ';
            v_cond_admin = '(vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario = 10 and (tper.periodo > 7 or tpla.id_gestion >= 16))) AND tfp.tipo_contrato != ''CONS''';
            v_codigo = 'tcar.codigo = ''0'' and tfp.tipo_contrato = ''EVE''';
            v_sumatoria = 'sum(CASE WHEN ((tcv.codigo_columna = ''SUBLACGAS'' or tcv.codigo_columna = ''SUBPREGAS'') AND tcv.valor!=0) THEN CASE WHEN (2000*0.13 + tcv.valor)>2000 THEN (4000*0.13 + tcv.valor) ELSE (2000*0.13 + tcv.valor) END ELSE tcv.valor END)::numeric';

        elsif v_desc_planilla = 'PLAPRI' then
            v_cond_categoria =  '(ca.codigo = ''SUPER'' and ((tfp.id_funcionario != 10 and tfp.id_funcionario !=1030) or (tfp.id_funcionario = 10 and tper.periodo <= 7 and (tpla.id_gestion = 16 or tpla.id_gestion = 15))))';
            v_cond_gestion = 'tpla.id_gestion = '||v_id_gestion||' and ';
            v_cond_admin = '(vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario = 10 and (tper.periodo > 7 or tpla.id_gestion >= 16))) AND tfp.tipo_contrato != ''CONS''';
            v_sumatoria = 'sum(tcv.valor)::numeric';
            v_codigo = 'tcar.codigo = ''0'' and tfp.tipo_contrato = ''EVE''';

            v_id_gestion = v_id_gestion + 1;
        elsif v_desc_planilla = 'PLAREISU' then
        	v_cond_categoria = '(ca.codigo = ''SUPER'' and (tfp.id_funcionario != 10 or (tfp.id_funcionario = 10 and tpla.id_gestion = 16)))';
            v_cond_admin = '(vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario = 10 and (tpla.id_gestion >= 16))) AND tfp.tipo_contrato != ''CONS''';
            v_cond_gestion = 'tcp.id_gestion = '||v_id_gestion||' and ';
            v_sumatoria = 'sum(tcd.valor)::numeric';
            v_codigo = 'tcar.codigo = ''0''';
        end if;

        select tg.gestion
        into v_gestion
        from param.tgestion tg
        where tg.id_gestion = v_id_gestion;

        if v_desc_planilla = 'PLASUB' or v_desc_planilla = 'PLASUE' then
        	v_id_uo_func_retro = 'tfp.id_uo_funcionario';
            v_inner_periodo = 'inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';

            v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla ';
            v_periodo_group = 'tper.periodo,';
        elsif v_desc_planilla = 'PLAPRI' then
        	v_id_uo_func_retro = 'tfp.id_uo_funcionario';
        	v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = 6 and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
        	v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla ';
            v_periodo_group = 'tper.periodo,';
        elsif v_desc_planilla = 'PLAREISU' then
        	v_id_uo_func_retro = 'tht.id_uo_funcionario';
        	v_periodo_retro = '
            				inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla
                      		inner join plani.tcolumna_detalle tcd on tcd.id_columna_valor = tcv.id_columna_valor
                      		inner join plani.thoras_trabajadas tht on tht.id_horas_trabajadas = tcd.id_horas_trabajadas';

            v_inner_periodo = 'inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                        ((tht.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)) or
                        (tht.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/2018''::date)))';

            v_periodo_group = '0::integer,';
        else
        	v_id_uo_func_retro = 'tfp.id_uo_funcionario';
            v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion||'
                               inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                               ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                               (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))';
            v_columna_valor = 'inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla ';
            v_periodo_group = 'tper.periodo,';
        end if;



        --v_mes = {'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre', 'Diciembre'};
        --consulta para obtener entidad tranferencia caja

            select tet.id_entidad_transferencia
            into v_id_seg_cordes
            from pre.tentidad_transferencia tet
            where tet.codigo = '424' and tet.id_gestion = v_id_gestion;

            select tet.id_entidad_transferencia
            into v_id_seg_umss
            from pre.tentidad_transferencia tet
            where tet.codigo = '425'and tet.id_gestion = v_id_gestion;

        /*v_consulta = 'SELECT
                      (case
                                when lower(ger.nombre_unidad) like ''%cobija%'' or tcar.nombre like ''%CIJ%'' then
                                    ''5.CIJ''
                                when tcar.codigo = ''0'' and tfp.tipo_contrato = ''EVE'' then
                                    ''6.EVE''
                                when ca.codigo = ''SUPER''  and es.codigo != ''GEREN'' then
                                    ''3.ESP''
                                when vcp.desc_programa ilike ''%ADM%'' AND tfp.tipo_contrato != ''CONS''  then
                                    ''1.ADM''
                                when vcp.desc_programa ilike ''%OPE%'' then
                                    ''2.OPE''
                                when vcp.desc_programa ilike ''%COM%'' then
                                    ''4.COM''
                                else
                                    ''7.CONSULTORES''
                                end
                                )::varchar as categoria_prog,

                      (case
                                when tcv.codigo_columna =  ''AFP_APNALSOL'' then
                                    ''91.AFP_APNALSOL''
                                when tcv.codigo_columna = ''AFP_APPAT'' then
                                    ''80.AFP_APPAT''
                                when tcv.codigo_columna = ''AFP_APSOL''  then
                                    ''90.AFP_APSOL''
                                when tcv.codigo_columna = ''AFP_CADM'' then
                                    ''60.AFP_CADM''
                                when tcv.codigo_columna = ''AFP_RCOM'' then
                                    ''50.AFP_RCOM''
                                when tcv.codigo_columna = ''AFP_RIEPRO'' then
                                    ''70.AFP_RIEPRO''
                                when tcv.codigo_columna = ''AFP_SSO'' then
                                    ''40.AFP_SSO''
                                when tcv.codigo_columna = ''AFP_VIVIE'' then
                                    ''20.AFP_VIVIE''
                                when tcv.codigo_columna = ''CAJSAL'' then
                                    ''30.CAJSAL''
                                when tcv.codigo_columna = ''IMPURET'' then
                                    ''10.IMPURET''
                                end
                                )::varchar as retencion,

                      tcv.codigo_columna,
                      sum(tcv.valor)::numeric AS precio_total,
                      vcp.desc_programa::varchar,
                      tper.periodo,
                      ''PLASUE''::varchar as tipo_planilla,
                      tpla.observaciones::varchar,
                      taf.nombre as afp

                      FROM plani.tplanilla tpla
                      inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpla.id_planilla
                      inner join plani.tfuncionario_afp tfa on tfa.id_funcionario = tfp.id_funcionario
                      inner join plani.tafp taf on taf.id_afp = tfa.id_afp
                      INNER JOIN orga.tuo_funcionario tuof on tuof.id_uo_funcionario = tfp.id_uo_funcionario
                      INNER JOIN ORGA.tcargo tcar on tcar.id_cargo = tuof.id_cargo
                      INNER JOIN ORGA.tescala_salarial es ON es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
                      INNER JOIN ORGA.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                      inner JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(tuof.id_uo, NULL::integer, NULL::date)
                      inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo
                      inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                      ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                      (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))
                      inner join orga.vfuncionario vf on vf.id_funcionario = tfp.id_funcionario
                      inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla
                      INNER JOIN pre.tpresupuesto tp ON tp.id_presupuesto = tcp.id_centro_costo
                      INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog
                      WHERE tcp.id_gestion = '||v_id_gestion||' and tpla.estado_reg = ''activo'' AND tpla.id_proceso_wf = '||v_parametros.id_proceso_wf||' and
                      tcv.codigo_columna in (''IMPURET'',''AFP_VIVIE'',''CAJSAL'',''AFP_SSO'',''AFP_RCOM'',''AFP_CADM'',''AFP_RIEPRO'',''AFP_APPAT'',''AFP_APSOL'',''AFP_APNALSOL'')
                      GROUP BY  ger.nombre_unidad,tcar.codigo,ca.codigo,es.codigo,vcp.desc_programa,tcv.codigo_columna,
                      			tper.periodo,tcar.nombre,tpla.observaciones,tfp.tipo_contrato,taf.nombre
                      ORDER BY categoria_prog asc,/*tcv.codigo_columna,*/retencion asc, taf.nombre asc';*/

        create temp table tt_retenciones(
        	categoria_prog 	varchar,
            retencion 		varchar,
            desc_retencion	varchar,
            afp 			varchar,
            monto 			numeric
        )on commit drop;

        for v_record in SELECT
                      (case
                                when lower(ger.nombre_unidad) like '%cobija%' or tcar.nombre like '%CIJ%' then
                                    '5.CIJ'
                                when tcar.codigo = '0' and tfp.tipo_contrato = 'EVE' then
                                    '6.EVE'
                                when ca.codigo = 'SUPER'  and es.codigo != 'GEREN' then
                                    '3.ESP'
                                when vcp.desc_programa ilike '%ADM%' AND tfp.tipo_contrato != 'CONS'  then
                                    '1.ADM'
                                when vcp.desc_programa ilike '%OPE%' then
                                    '2.OPE'
                                when vcp.desc_programa ilike '%COM%' then
                                    '4.COM'
                                else
                                    '7.CONSULTORES'
                                end
                                )::varchar as categoria_prog,

                      (case
                                when tcv.codigo_columna =  'AFP_APNALSOL' then
                                    '90.AFP_APNALSOL'
                                when tcv.codigo_columna = 'AFP_APPAT' then
                                    '70.AFP_APPAT'
                                when tcv.codigo_columna = 'AFP_APSOL'  then
                                    '80.AFP_APSOL'
                                when tcv.codigo_columna = 'AFP_CADM' then
                                    '30.AFP_CADM'
                                when tcv.codigo_columna = 'AFP_RCOM' then
                                    '20.AFP_RCOM'
                                when tcv.codigo_columna = 'AFP_RIEPRO' then
                                    '40.AFP_RIEPRO'
                                when tcv.codigo_columna = 'AFP_SSO' then
                                    '10.AFP_SSO'
                                when tcv.codigo_columna = 'AFP_VIVIE' then
                                    '60.AFP_VIVIE'
                                when tcv.codigo_columna = 'CAJSAL' then
                                    '50.CAJSAL'
                                when tcv.codigo_columna = 'IMPURET' then
                                    '91.IMPURET'
                                end
                                )::varchar as retencion,

                      tcv.codigo_columna,
                      sum(tcv.valor)::numeric AS monto,
                      vcp.desc_programa::varchar,
                      tper.periodo,
                      'PLASUE'::varchar as tipo_planilla,
                      tpla.observaciones::varchar,
                      taf.nombre::varchar as afp,
                      ttc.nombre as desc_retencion

                      FROM plani.tplanilla tpla
                      inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpla.id_planilla
                      inner join plani.tfuncionario_afp tfa on tfa.id_funcionario = tfp.id_funcionario
                      inner join plani.tafp taf on taf.id_afp = tfa.id_afp
                      INNER JOIN orga.tuo_funcionario tuof on tuof.id_uo_funcionario = tfp.id_uo_funcionario
                      INNER JOIN ORGA.tcargo tcar on tcar.id_cargo = tuof.id_cargo
                      INNER JOIN ORGA.tescala_salarial es ON es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = 'activo'
                      INNER JOIN ORGA.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                      inner JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(tuof.id_uo, NULL::integer, NULL::date)
                      inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo
                      inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = v_id_gestion and
                      ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,('31/12/'||v_gestion)::date)) or
                      (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,('31/12/'||v_gestion)::date)))
                      inner join orga.vfuncionario vf on vf.id_funcionario = tfp.id_funcionario
                      inner JOIN plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla
                      inner join plani.ttipo_columna ttc on ttc.id_tipo_columna = tcv.id_tipo_columna
                      INNER JOIN pre.tpresupuesto tp ON tp.id_presupuesto = tcp.id_centro_costo
                      INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog
                      WHERE tcp.id_gestion = v_id_gestion and tpla.estado_reg = 'activo' AND tpla.id_proceso_wf = v_parametros.id_proceso_wf and
                      tcv.codigo_columna in ('IMPURET','AFP_VIVIE','CAJSAL','AFP_SSO','AFP_RCOM','AFP_CADM','AFP_RIEPRO','AFP_APPAT','AFP_APSOL','AFP_APNALSOL')
                      --and (lower(ger.nombre_unidad) like '%cobija%' or tcar.nombre like '%CIJ%')
                      GROUP BY  ger.nombre_unidad,tcar.codigo,ca.codigo,es.codigo,vcp.desc_programa,tcv.codigo_columna,
                      			tper.periodo,tcar.nombre,tpla.observaciones,tfp.tipo_contrato,taf.nombre, desc_retencion
                      ORDER BY categoria_prog asc,retencion asc, taf.nombre asc loop

        	if v_categoria_prog != v_record.categoria_prog and v_categoria_prog != '' then
            	if v_retencion in ('50.CAJSAL', '60.AFP_VIVIE', '91.IMPURET') then
                  insert into tt_retenciones(
                    categoria_prog,
                    retencion,
                    desc_retencion,
                    afp,
                    monto
                  )values(
                    v_categoria_prog::varchar,
                    v_retencion::varchar,
                    v_desc_retencion,
                    '',
                    v_total_monto::numeric
                  );
                else
                  insert into tt_retenciones(
                    categoria_prog,
                    retencion,
                    desc_retencion,
                    afp,
                    monto
                  )values(
                    v_categoria_prog::varchar,
                    v_retencion::varchar,
                    (v_desc_retencion||' '||v_afp)::varchar,
                    v_afp::varchar,
                    v_total_monto::numeric
                  );
                end if;
              	v_total_monto = 0;
                v_total_monto = v_total_monto + v_record.monto;
            else
              if v_retencion != v_record.retencion and v_retencion != '' then
              	if v_retencion in ('50.CAJSAL', '60.AFP_VIVIE', '91.IMPURET') then
                	insert into tt_retenciones(
                        categoria_prog,
                        retencion,
                        desc_retencion,
                        afp,
                        monto
                    )values(
                        v_categoria_prog::varchar,
                        v_retencion::varchar,
                        v_desc_retencion,
                        '',
                        v_total_monto::numeric
                    );
                else
                	insert into tt_retenciones(
                        categoria_prog,
                        retencion,
                        desc_retencion,
                        afp,
                        monto
                    )values(
                        v_categoria_prog::varchar,
                        v_retencion::varchar,
                        (v_desc_retencion||' '||v_afp)::varchar,
                        v_afp::varchar,
                        v_total_monto::numeric
                    );
                end if;
              		v_total_monto = 0;
                	v_total_monto = v_total_monto + v_record.monto;
              else
                if v_afp != v_record.afp and v_afp != '' then
                	if v_retencion not in ('50.CAJSAL', '60.AFP_VIVIE', '91.IMPURET') then
                        insert into tt_retenciones(
                          categoria_prog,
                          retencion,
                          desc_retencion,
                          afp,
                          monto
                        )values(
                          v_categoria_prog::varchar,
                          v_retencion::varchar,
                          (v_desc_retencion||' '||v_afp)::varchar,
                          v_afp::varchar,
                          v_total_monto::numeric
                        );
                    	v_total_monto= 0;
                    	v_total_monto = v_total_monto + v_record.monto;
                    else
                    	v_total_monto = v_total_monto + v_record.monto;
                    end if;

                else
                    v_total_monto = v_total_monto + v_record.monto;
                end if;
              end if;
            end if;

            v_retencion = v_record.retencion;
            v_categoria_prog = v_record.categoria_prog;
            v_afp = v_record.afp;
            v_desc_retencion = v_record.desc_retencion;

        end loop;

        v_total_monto = v_total_monto + v_record.monto;
        if v_retencion in ('50.CAJSAL', '60.AFP_VIVIE', '91.IMPURET') then
          insert into tt_retenciones(
            categoria_prog,
            retencion,
            desc_retencion,
            afp,
            monto
          )values(
            v_categoria_prog::varchar,
            v_retencion::varchar,
            v_desc_retencion,
            '',
            v_total_monto::numeric
          );
        else
          insert into tt_retenciones(
          	categoria_prog,
            retencion,
            desc_retencion,
            afp,
            monto
          )values(
            v_categoria_prog::varchar,
            v_retencion::varchar,
            (v_desc_retencion||' '||v_afp)::varchar,
            v_afp::varchar,
            v_total_monto::numeric
          );
        end if;

        v_consulta = '
        	select ttr.categoria_prog::varchar,
            	   ttr.retencion::varchar,
                   ttr.desc_retencion::varchar,
                   ttr.afp::varchar,
                   ttr.monto::numeric
            from tt_retenciones ttr
        ';
		    raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;
    end;
    /*********************************
        #TRANSACCION:  'PLA_OTROS_ING_SEL'
        #DESCRIPCION:	Listado de Otros Ingresos Funcionario
        #AUTOR:		f.e.a
        #FECHA:		24-09-2019 16:11:04
        ***********************************/
    elsif(p_transaccion='PLA_OTROS_ING_SEL')then

      begin

		    /*select tp.periodo
        into v_periodo
        from param.tperiodo tp
        where tp.id_periodo = v_parametros.id_periodo;

        select tg.gestion
        into v_gestion
        from param.tgestion tg
        where tg.id_gestion = v_parametros.id_gestion;*/

        v_fecha_inicio = (date_trunc('month', current_date))::date;
        v_fecha_final  = (date_trunc('month', current_date) + INTERVAL '1 month - 1 day')::date;

        v_consulta = '
        	SELECT
            funcio.id_funcionario,
            funcio.id_persona,
            person.nombre_completo2 AS desc_person,
            funcio.id_usuario_reg,
            funcio.id_usuario_mod,
            usu1.cuenta as usr_reg,
            usu2.cuenta as usr_mod,
            funcio.estado_reg,
            funcio.fecha_reg,
            funcio.fecha_mod,
            tar.nombre_archivo,
        	tar.extension,
            toi.sistema_fuente,
            toi.monto,
            toi.fecha_pago::date,
            toi.id_otros_ingresos
            FROM orga.tfuncionario funcio
            inner join orga.tuo_funcionario tuo on tuo.id_funcionario = funcio.id_funcionario and (current_date <=coalesce(tuo.fecha_finalizacion,''31/12/9999''::date) or (tuo.fecha_finalizacion between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date))
            inner join plani.totros_ingresos toi on toi.id_funcionario = funcio.id_funcionario
            INNER JOIN segu.vpersona person ON person.id_persona=funcio.id_persona
            inner join segu.tusuario usu1 on usu1.id_usuario = funcio.id_usuario_reg
            left join segu.tusuario usu2 on usu2.id_usuario = funcio.id_usuario_mod
            left join param.tarchivo tar on tar.id_tabla = funcio.id_funcionario and tar.id_tipo_archivo = 10
            WHERE tuo.estado_reg = ''activo'' and (toi.fecha_pago::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date)'; --toi.gestion='||v_gestion||' and toi.periodo = '||v_periodo||' and toi.id_funcionario = '||v_parametros.id_funcionario;
		    raise notice 'v_consulta: %',v_consulta;
        v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' OFFSET ' || v_parametros.puntero;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
        #TRANSACCION:  'PLA_OTROS_ING_CONT'
        #DESCRIPCION:	contador del listado de Otros Ingresos Funcionario
        #AUTOR:		f.e.a
        #FECHA:		24-09-2019 16:11:04
        ***********************************/
    elsif(p_transaccion='PLA_OTROS_ING_CONT')then

      begin

		    /*select tp.periodo
        into v_periodo
        from param.tperiodo tp
        where tp.id_periodo = v_parametros.id_periodo;

        select tg.gestion
        into v_gestion
        from param.tgestion tg
        where tg.id_gestion = v_parametros.id_gestion;*/

        v_consulta = '
        	SELECT
            count(funcio.id_funcionario)
            FROM orga.tfuncionario funcio
            inner join orga.tuo_funcionario tuo on tuo.id_funcionario = funcio.id_funcionario and current_date <=coalesce(tuo.fecha_finalizacion,''31/12/9999''::date)
            inner join plani.totros_ingresos toi on toi.id_funcionario = funcio.id_funcionario
            INNER JOIN segu.vpersona person ON person.id_persona=funcio.id_persona
            inner join segu.tusuario usu1 on usu1.id_usuario = funcio.id_usuario_reg
            left join segu.tusuario usu2 on usu2.id_usuario = funcio.id_usuario_mod
            left join param.tarchivo tar on tar.id_tabla = funcio.id_funcionario and tar.id_tipo_archivo = 10
            WHERE tuo.estado_reg = ''activo'' and (toi.fecha_pago::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date)'; --toi.gestion='||v_gestion||' and toi.periodo = '||v_periodo||' and toi.id_funcionario = '||v_parametros.id_funcionario;
		--v_consulta = v_consulta||v_parametros.filtro;
        --Devuelve la respuesta
        raise notice 'v_consulta: %', v_consulta;
        return v_consulta;
      end;
    /*********************************
    #TRANSACCION:  'PLA_RP_OTROS_ING_SEL'
    #DESCRIPCION:	Listado de Otros Ingresos Funcionario
    #AUTOR:		f.e.a
    #FECHA:		06-02-2020 16:11:04
    ***********************************/
    /*elsif(p_transaccion='PLA_RP_OTROS_ING_SEL')then

      begin


        v_gestion = date_part('year',v_parametros.fecha_fin);
        v_periodo = date_part('month',v_parametros.fecha_fin);

        v_consulta = '
        	SELECT
            fun.desc_funcionario2 AS nombre_empleado,
            toi.sistema_fuente,
            sum (toi.monto),
            fun.ci,
            (case when toi.sistema_fuente = ''Refrigerios'' then ''ref''
            	  when toi.sistema_fuente = ''Viatico Administrativo AMP'' then ''amp''
            	  when toi.sistema_fuente = ''Viatico Administrativo'' then ''adm''
                  when toi.sistema_fuente = ''Viatico Operativo'' then ''ope'' end)::varchar as codigo
            FROM plani.totros_ingresos toi
            inner join orga.vfuncionario fun on fun.id_funcionario = toi.id_funcionario
            WHERE toi.gestion = '||v_gestion||' and toi.periodo = '||v_periodo||' and toi.sistema_fuente != ''Refrigerios''
		    group by nombre_empleado, toi.sistema_fuente, fun.ci
            order by fun.desc_funcionario2 asc, toi.sistema_fuente asc';
        raise notice 'v_consulta: %',v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;*/
    /*********************************
        #TRANSACCION:  'PLA_REP_PLANIC31_SEL'
        #DESCRIPCION:	Reporte para sacar Planillas C31 SIGMA
        #AUTOR:		f.e.a
        #FECHA:		17-02-2020 15:00:00
        ***********************************/
    elsif(p_transaccion='PLA_REP_PLANIC31_SEL')then

      begin

      	SELECT tpl.codigo, tp.id_gestion, coalesce(tp.id_periodo, 0)
        INTO v_desc_planilla, v_id_gestion, v_id_periodo
        FROM plani.tplanilla tp
        INNER JOIN plani.ttipo_planilla tpl on tpl.id_tipo_planilla = tp.id_tipo_planilla
        WHERE tp.id_proceso_wf =  v_parametros.id_proceso_wf;

        select tg.gestion
        into v_gestion
        from param.tgestion tg
        where tg.id_gestion = v_id_gestion;

        if v_desc_planilla = 'PLASUE' then

        	v_inner_c31 = 'inner JOIN plani.tcolumna_valor dia on dia.id_funcionario_planilla = tfp.id_funcionario_planilla and dia.codigo_columna = ''HORNORM''
                      inner JOIN plani.tcolumna_valor hab on hab.id_funcionario_planilla = tfp.id_funcionario_planilla and hab.codigo_columna = ''SUELDOBA''
                      inner JOIN plani.tcolumna_valor bon on bon.id_funcionario_planilla = tfp.id_funcionario_planilla and bon.codigo_columna = ''BONANT''
                      inner JOIN plani.tcolumna_valor otr on otr.id_funcionario_planilla = tfp.id_funcionario_planilla and otr.codigo_columna = ''PAGOVAR''
                      inner JOIN plani.tcolumna_valor fijo on fijo.id_funcionario_planilla = tfp.id_funcionario_planilla and fijo.codigo_columna = ''PAGOFIJ''
                      inner JOIN plani.tcolumna_valor tot on tot.id_funcionario_planilla = tfp.id_funcionario_planilla and tot.codigo_columna = ''COTIZABLE''
                      inner JOIN plani.tcolumna_valor iva on iva.id_funcionario_planilla = tfp.id_funcionario_planilla and iva.codigo_columna = ''IMPURET''
                      inner JOIN plani.tcolumna_valor afp on afp.id_funcionario_planilla = tfp.id_funcionario_planilla and afp.codigo_columna = ''AFP_LAB''
                      inner JOIN plani.tcolumna_valor des on des.id_funcionario_planilla = tfp.id_funcionario_planilla and des.codigo_columna = ''OTRO_DESC''
                      inner JOIN plani.tcolumna_valor des_t on des_t.id_funcionario_planilla = tfp.id_funcionario_planilla and des_t.codigo_columna = ''TOT_DESC''
                      inner JOIN plani.tcolumna_valor liq on liq.id_funcionario_planilla = tfp.id_funcionario_planilla and liq.codigo_columna = ''LIQPAG''';

          v_campos_c31 = ',(dia.valor/8)::integer as dias,hab.valor::numeric as haber,bon.valor::numeric as bono,(case when otr.valor::numeric = 0 then fijo.valor::numeric else otr.valor::numeric end) as otros_ing,
                      tot.valor::numeric as total_ing,iva.valor::numeric as rc_iva,afp.valor::numeric as afp_lab,des.valor::numeric as descuento,
                      des_t.valor::numeric as total_descuento,liq.valor::numeric as liquido,0::numeric as subsidio';

          v_group_c31 = ',dias,haber,bono,otros_ing,total_ing,rc_iva,afp_lab,descuento,total_descuento,liquido';

        	v_inner_periodo = 'inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo';

        elsif v_desc_planilla = 'PLASUB' then

        	v_inner_c31 = 'inner JOIN plani.tcolumna_valor liq on liq.id_funcionario_planilla = tfp.id_funcionario_planilla and liq.codigo_columna = ''TOTSUB''';

          v_campos_c31 = ',0::integer as dias,0::numeric as haber,0::numeric as bono,0::numeric as otros_ing,
                      liq.valor::numeric as total_ing,0::numeric as rc_iva,0::numeric as afp_lab,0::numeric as descuento,
                      0::numeric as total_descuento,liq.valor::numeric as liquido, liq.valor as subsidio';

          v_group_c31 = ',liq.valor';

        	v_inner_periodo = 'inner join param.tperiodo tper on tper.id_periodo = tpla.id_periodo';

        elsif  v_desc_planilla = 'PLAGUIN' then
        	v_inner_c31 = '
                      inner JOIN plani.tcolumna_valor dia on dia.id_funcionario_planilla = tfp.id_funcionario_planilla and dia.codigo_columna = ''DIASAGUI''
                      inner JOIN plani.tcolumna_valor otr on otr.id_funcionario_planilla = tfp.id_funcionario_planilla and otr.codigo_columna = ''AGUINA''
                      inner JOIN plani.tcolumna_valor tot on tot.id_funcionario_planilla = tfp.id_funcionario_planilla and tot.codigo_columna = ''AGUINA''
                      inner JOIN plani.tcolumna_valor des on des.id_funcionario_planilla = tfp.id_funcionario_planilla and des.codigo_columna = ''DESCCHEQ''
                      inner JOIN plani.tcolumna_valor liq on liq.id_funcionario_planilla = tfp.id_funcionario_planilla and liq.codigo_columna = ''LIQPAG''';

          v_campos_c31 = ',dia.valor::integer as dias,0::numeric as haber,0::numeric as bono,otr.valor::numeric as otros_ing,
                    tot.valor::numeric as total_ing,0::numeric as rc_iva,0::numeric as afp_lab,des.valor::numeric as descuento,
                    des.valor::numeric as total_descuento,liq.valor::numeric as liquido, 0::numeric as subsidio';

          v_group_c31 = ',dias,otros_ing,total_ing,des.valor,liquido';

          v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion||'';
        elsif  v_desc_planilla = 'PLAPRI' then

        	v_gestion = v_gestion + 1;
          v_id_gestion = v_id_gestion + 1 ;

        	v_inner_c31 = '
                      inner JOIN plani.tcolumna_valor dia on dia.id_funcionario_planilla = tfp.id_funcionario_planilla and dia.codigo_columna = ''DIASAGUI''
                      inner JOIN plani.tcolumna_valor otr on otr.id_funcionario_planilla = tfp.id_funcionario_planilla and otr.codigo_columna = ''PRIMA''
                      inner JOIN plani.tcolumna_valor liq on liq.id_funcionario_planilla = tfp.id_funcionario_planilla and liq.codigo_columna = ''LIQPAG''';

          v_campos_c31 = ',dia.valor::integer as dias,0::numeric as haber,0::numeric as bono,otr.valor::numeric as otros_ing,
                      otr.valor::numeric as total_ing,0::numeric as rc_iva,0::numeric as afp_lab,0::numeric as descuento,
                      0::numeric as total_descuento,liq.valor::numeric as liquido, 0::numeric as subsidio';

          v_group_c31 = ',dias,otr.valor,liquido';

          v_inner_periodo = 'inner join param.tperiodo tper on tper.periodo = extract(''month'' from tpla.fecha_planilla) and tper.id_gestion = '||v_id_gestion;
        end if;

        select pxp.list(tuo.id_funcionario::varchar)
        into v_id_gerente
        from orga.tcargo tcar
        inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
        inner join orga.tuo uo on uo.id_uo = tuo.id_uo
        where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo';

        v_consulta = '
        			select
                      (case
                      when lower(ger.nombre_unidad) like ''%cobija%'' or tcar.nombre like ''%CIJ%'' then
                          ''5.CIJ''
                      when tcar.codigo = ''0'' and tfp.tipo_contrato = ''EVE'' then
                          ''6.EVE''
                      when ca.codigo = ''SUPER'' and tfp.id_funcionario not in ('||v_id_gerente||') then
                          ''3.ESP''
                      when (vcp.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and tfp.id_funcionario in ('||v_id_gerente||'))) AND tfp.tipo_contrato != ''CONS''  then
                          ''1.ADM''
                      when vcp.desc_programa ilike ''%OPE%'' then
                          ''2.OPE''
                      when vcp.desc_programa ilike ''%COM%'' then
                          ''4.COM''
                      else
                          ''7.CONSULTORES''
                      end
                      )::varchar as categoria_prog,
                      vcp.codigo_programa::varchar,
                      vcp.desc_programa::varchar,
                      tlug.nombre::varchar as lugar,
                      (ttc.codigo||'' - ''||ttc.descripcion)::varchar as presupuesto,
                      tges.gestion::varchar,
                      ''578''::varchar as entidad,
                      ''1''::varchar as dir_admin,
                      vcp.desc_actividad::varchar as actividad,
                      initcap(tipp.periodicidad)::varchar as tipo_proceso,
                      tper.periodo::varchar,
                      tper.fecha_ini::date,
                      tper.fecha_fin::date,
                      vcp.codigo_fuente_fin::varchar as fuente,
                      vcp.codigo_origen_fin::varchar as organismo,
                      vcp.codigo_unidad_ejecutora::varchar as ue,
                      vf.desc_funcionario2::varchar as funcionario,
                      vf.ci,
                      tcar.codigo::varchar as item,
                      tpla.fecha_planilla
                      '||v_campos_c31||'
                      FROM plani.tplanilla tpla
                      inner join param.tgestion tges on tges.id_gestion = tpla.id_gestion
                      inner join plani.ttipo_planilla tipp on tipp.id_tipo_planilla = tpla.id_tipo_planilla
                      inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpla.id_planilla
                      INNER JOIN orga.tuo_funcionario tuof on tuof.id_uo_funcionario = tfp.id_uo_funcionario
                      INNER JOIN ORGA.tcargo tcar on tcar.id_cargo = tuof.id_cargo
                      INNER JOIN param.tlugar tlug on tlug.id_lugar = tcar.id_lugar
                      INNER JOIN ORGA.tescala_salarial es ON es.id_escala_salarial = tcar.id_escala_salarial
                      INNER JOIN ORGA.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                      inner JOIN orga.tuo ger ON ger.id_uo = orga.f_get_uo_gerencia(tuof.id_uo, NULL::integer, NULL::date)

                      '||v_inner_periodo||'
                      inner join orga.tcargo_presupuesto tcp on tcp.id_cargo = tuof.id_cargo and tcp.id_gestion = '||v_id_gestion||' and
                      ((tper.fecha_ini between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)) or
                      (tper.fecha_fin between tcp.fecha_ini and coalesce(tcp.fecha_fin,''31/12/'||v_gestion||'''::date)))

                      inner join orga.vfuncionario vf on vf.id_funcionario = tfp.id_funcionario

                      '||v_inner_c31||'
                      inner join param.tcentro_costo tcc on tcc.id_centro_costo = tcp.id_centro_costo
                      inner join param.ttipo_cc ttc on ttc.id_tipo_cc = tcc.id_tipo_cc
                      INNER JOIN pre.tpresupuesto	tp ON tp.id_presupuesto = tcc.id_centro_costo
                      INNER JOIN pre.vcategoria_programatica vcp ON vcp.id_categoria_programatica = tp.id_categoria_prog
                      WHERE tcp.id_gestion = '||v_id_gestion||' and tpla.estado_reg = ''activo'' AND tpla.id_proceso_wf = '||v_parametros.id_proceso_wf||'
                      GROUP BY
                            vcp.codigo_categoria,vcp.codigo_programa, vcp.codigo_proyecto, vcp.codigo_actividad, vcp.codigo_fuente_fin, vcp.codigo_origen_fin,
                            ger.nombre_unidad, tcar.codigo, ca.codigo,tfp.id_funcionario,vcp.desc_programa,fecha_planilla,tper.periodo,tcar.nombre,
                            tpla.id_gestion,tpla.observaciones,tfp.tipo_contrato,funcionario,presupuesto,lugar,tges.gestion,vcp.desc_actividad,tipo_proceso,tper.fecha_ini,tper.fecha_fin, ue, vf.ci
                            '||v_group_c31||'
                      ORDER BY categoria_prog asc, /*vcp.codigo_categoria asc,*/ lugar asc,  /*presupuesto asc,*/ funcionario asc
        ';
		    raise notice 'v_consulta: %', v_consulta;
        --Devuelve la respuesta
        return v_consulta;
      end;
    /*********************************
    #TRANSACCION:  'PLA_RP_OTROS_ING_SEL'
    #DESCRIPCION:	Listado de Otros Ingresos Funcionario
    #AUTOR:		f.e.a
    #FECHA:		06-02-2020 16:11:04
    ***********************************/
    elsif(p_transaccion='PLA_RP_OTROS_ING_SEL')then

      begin

        v_periodo = v_parametros.periodo::integer;
        v_gestion = v_parametros.gestion::integer;
        --RAISE 'CAMPOS: %, %',v_periodo, v_gestion;

        if v_periodo + 1 = 13 then
        	v_periodo = 1;
          v_gestion = v_gestion + 1;
        else
        	v_periodo = v_periodo+1;
        end if;

        v_fecha_inicio = ('1/'||v_parametros.periodo||'/'||v_parametros.gestion)::date;
        v_fecha_final = ('1/'||v_periodo||'/'||v_gestion)::date-1;

        v_date_fin_contrato = v_fecha_inicio-1;
        v_date_ini_contrato = date_trunc('month',v_date_fin_contrato);
		--RAISE 'v_parametros.periodo: %, v_parametros.gestion: %, v_periodo: %, v_gestion: %, v_fecha_inicio: %, v_fecha_final: %, v_date_ini_contrato: %, v_date_fin_contrato: %',v_parametros.periodo,v_parametros.gestion,v_periodo,v_gestion,v_fecha_inicio,v_fecha_final,v_date_ini_contrato,v_date_fin_contrato;
        select tg.id_gestion
        into v_id_gestion
        from param.tgestion tg
        where tg.gestion = v_parametros.gestion::integer;

        select pxp.list(tuo.id_funcionario::varchar)
        into v_id_gerente
        from orga.tcargo tcar
        inner join orga.tuo_funcionario tuo on tuo.id_cargo = tcar.id_cargo
        inner join orga.tuo uo on uo.id_uo = tuo.id_uo
        where tuo.estado_reg = 'activo' and tuo.tipo = 'oficial' and tcar.codigo = '1' and uo.estado_reg = 'activo';


        /*Verificar si existe planilla de prima, retroactivo*/
        EXECUTE('select tp.id_planilla
                  from plani.tplanilla tp
                  inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = tp.id_tipo_planilla
                  where tpla.codigo =''PLAPRI'' and tp.fecha_planilla between '''||date_trunc('year',v_fecha_inicio)||'''::date and '''||date_trunc('year',v_fecha_final+interval '1 year')::date-1||'''::date') into v_id_prima;

         EXECUTE('select tp.id_planilla
                  from plani.tplanilla tp
                  inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = tp.id_tipo_planilla
                  where tpla.codigo =''PLAREISU'' and tp.fecha_planilla between '''||date_trunc('year',v_fecha_inicio)||'''::date and '''||date_trunc('year',v_fecha_final+interval '1 year')::date-1||'''::date') into v_id_retro;

        if v_parametros.periodo::integer = 9 and v_gestion = 2019 then
        	v_planilla_extra = 'PRIMA';
            v_id_planilla_extra = v_id_prima;
        elsif v_parametros.periodo::integer = 12 and v_gestion = 2019 then
        	v_planilla_extra = 'RETROACTIVO';
            v_id_planilla_extra = v_id_retro;
        end if;

		v_col_prima = '0::numeric as prima,';
        v_col_retro = '0::numeric as retroactivo';

        if v_parametros.periodo::integer in (9,12) and v_gestion = 2019 then
            v_with_header = 'with otros_ingresos as ((';
            v_with_body = ') union all';
            v_with_footer = '

            	select
                vf.desc_funcionario2 AS nombre_empleado,
                '''||v_planilla_extra||'''::varchar as sistema_fuente,
                tcv.valor::numeric(18,2) monto,
                vf.ci::varchar,
                tcar.nombre::varchar as cargo,
                tcon.nombre::varchar as contrato,
                (case
                    when lower(uo.nombre_unidad) like ''%cobija%'' then
                        ''5.CIJ''
                    when tcar.codigo = ''0'' then
                        ''6.EVE''
                    when ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||')  then
                        ''3.ESP''
                    when cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario in ('||v_id_gerente||')) then
                        ''1.ADM''
                    when cat.desc_programa ilike ''%OPE%'' then
                        ''2.OPE''
                    when cat.desc_programa ilike ''%COM%'' then
                        ''4.COM''
                    end
                    )::varchar as categoria,
                (case
                    when lower(uo.nombre_unidad) like ''%cobija%'' then
                        ''COBIJA''
                    when tcar.codigo = ''0'' then
                        ''EVENTUAL''
                    when ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||')  then
                        ''ESPECIAL''
                    when cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario in ('||v_id_gerente||')) then
                        ''ADMINISTRACIÓN''
                    when cat.desc_programa ilike ''%OPE%'' then
                        ''OPERACIÓN''
                    when cat.desc_programa ilike ''%COM%'' then
                        ''COMERCIAL''
                    end
                    )::varchar as area,
                tlug.codigo::varchar as regional,
                (case when tcom.c31 is not null then tcom.c31 else tcom.nro_cbte end)::varchar as c31,
                tpl.fecha_planilla::date as fecha_pago,
                (case when '''||v_planilla_extra||''' = ''PRIMA'' then ''pri'' else ''ret'' end)::varchar as tipo,
                ''ACTIVO''::varchar as estado,
                0::numeric as tasa_nacional,
                0::numeric as tasa_internacional,
                0::numeric as importe_retencion,
                tcom.nro_tramite::varchar as orden
                from plani.tplanilla tpl
                inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tpl.id_planilla
                inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = '''||v_planilla_extra||'''
                INNER join conta.tint_comprobante tcom on tcom.id_int_comprobante = tpl.id_int_comprobante

                INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario = tfp.id_funcionario and tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial'' and
                (
                  (
                    (tuo.fecha_finalizacion IS NULL OR tuo.fecha_finalizacion >= '''||v_fecha_final||'''::date or
                    (tuo.fecha_finalizacion between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date)) AND
                    tuo.fecha_asignacion <= '''||v_fecha_final||'''::date
                  )
                 OR
                  (
                    (tuo.fecha_finalizacion between '''||v_date_ini_contrato||'''::date and '''||v_date_fin_contrato||'''::date)
                    and ((select coalesce(tu.fecha_finalizacion,''31/12/9999''::date) from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(tfp.id_funcionario)) <= '''||v_date_fin_contrato||'''::date)
                  )
                 OR
                  (
                    tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(tfp.id_funcionario)
                    and ((select tu.fecha_finalizacion from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(tfp.id_funcionario)) < '''||v_date_ini_contrato||'''::date)
                  )
                )

                INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = tuo.id_funcionario
                inner join orga.tcargo tcar on tcar.id_cargo = tuo.id_cargo --and tcar.estado_reg = ''activo''
                inner join param.tlugar tlug on tlug.id_lugar = tcar.id_lugar
                inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = tcar.id_tipo_contrato
                inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and es.estado_reg = ''activo''
                inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
                --inner join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_id_gestion||'

                inner join param.tperiodo tper on tper.periodo = '||v_parametros.periodo::integer||' and tper.id_gestion = '||v_id_gestion||'
                inner join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_id_gestion||'  and
                ((tper.fecha_ini between cp.fecha_ini and coalesce(cp.fecha_fin,''31/12/'||v_parametros.gestion||'''::date)) or
                (tper.fecha_fin between cp.fecha_ini and coalesce(cp.fecha_fin,''31/12/'||v_parametros.gestion||'''::date)))

                inner join pre.vpresupuesto_cc pre on pre.id_centro_costo = cp.id_centro_costo
                inner join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
                inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)
                where tpl.id_planilla = '||v_id_planilla_extra||'
                )
                select
                otro.nombre_empleado,
                otro.sistema_fuente,
                otro.monto,
                otro.ci,
                otro.cargo,
                otro.contrato,
                otro.categoria,
                otro.area,
                otro.regional,
                otro.c31,
                otro.fecha_pago::date,
                otro.tipo,
                otro.estado,
                otro.tasa_nacional,
                otro.tasa_internacional,
                otro.importe_retencion,
                otro.orden
                from otros_ingresos otro';
        end if;

        /*if v_parametros.tipo = 'refrigerios' then
        	v_fuente = 'bef.sistema_fuente = ''Refrigerios'' and ';
        elsif v_parametros.tipo = 'viaticos' then
        	v_fuente = 'bef.sistema_fuente in (''Viatico Administrativo'',''Viatico Administrativo AMP'',''Viatico Operativo'') and ';
        end if;*/
        --raise 'v_fecha_inicio: %,v_id_gerente: %, v_id_gestion: %, v_fecha_final: %, a: % b: %', v_fecha_inicio,v_id_gerente, v_id_gestion, v_fecha_final, v_parametros.gestion, v_parametros.periodo;
        v_consulta = v_with_header||'
            	/*with beneficiario as (
            	select distinct tuo.id_uo_funcionario, ''activo'' as estado
                from plani.totros_ingresos toi
                INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  toi.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            	and (tuo.fecha_finalizacion IS NULL OR tuo.fecha_finalizacion > '''||v_fecha_final||'''::date)
                where toi.gestion = '||v_parametros.gestion||' and ((toi.fecha_pago between '''||v_fecha_inicio||'''::date and '''|| v_fecha_final||'''::date) or toi.periodo = '||v_parametros.periodo||')
                and tuo.id_uo_funcionario != 1000568

                union

                select distinct tuo.id_uo_funcionario, ''activo'' as estado
                from plani.totros_ingresos toi
                INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  toi.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            	and (tuo.fecha_finalizacion between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date) AND tuo.fecha_asignacion <= '''||v_fecha_final||'''::date
                and ((select coalesce(tu.fecha_finalizacion,''31/12/9999''::date) from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(toi.id_funcionario)) <= '''||v_fecha_final||'''::date)
                where toi.gestion = '||v_parametros.gestion||' and ((toi.fecha_pago between '''||v_fecha_inicio||'''::date and '''|| v_fecha_final||'''::date) or toi.periodo = '||v_parametros.periodo||')
				and tuo.id_uo_funcionario != 1000568

                union

                select distinct tuo.id_uo_funcionario, ''inactivo'' as estado
                from plani.totros_ingresos toi
                INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  toi.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            	and (tuo.fecha_finalizacion between '''||v_date_ini_contrato||'''::date and '''||v_date_fin_contrato||'''::date)
            	and ((select coalesce(tu.fecha_finalizacion,''31/12/9999''::date) from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(toi.id_funcionario)) <= '''||v_date_fin_contrato||'''::date)
                where toi.gestion = '||v_parametros.gestion||' and ((toi.fecha_pago between '''||v_fecha_inicio||'''::date and '''|| v_fecha_final||'''::date) or toi.periodo = '||v_parametros.periodo||')

                union

                select distinct tuo.id_uo_funcionario, ''inactivo'' as estado
                from plani.totros_ingresos toi
                INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario =  toi.id_funcionario AND tuo.estado_reg = ''activo'' AND tuo.tipo = ''oficial''
            	and tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(toi.id_funcionario)
            	and ((select coalesce(tu.fecha_finalizacion,''31/12/9999''::date) from orga.tuo_funcionario tu where tu.id_uo_funcionario = orga.f_get_ultima_asignacion(toi.id_funcionario)) < '''||v_date_ini_contrato||'''::date)
                where toi.gestion = '||v_parametros.gestion||' and ((toi.fecha_pago between '''||v_fecha_inicio||'''::date and '''|| v_fecha_final||'''::date) or toi.periodo = '||v_parametros.periodo||')
            	)*/
            SELECT
            distinct vf.desc_funcionario2 AS nombre_empleado,
            vf.id_funcionario,
            bef.sistema_fuente::varchar,
            bef.monto::numeric,
            vf.ci::varchar,
            tcar.nombre::varchar as cargo,
            tcon.nombre::varchar as contrato,
            (case
                when coalesce(tuo.fecha_finalizacion,''31/12/9999''::date) <  '''||v_fecha_inicio||'''::date then
                     ''7.FIN''
                when lower(uo.nombre_unidad) like ''%cobija%'' then
                    ''5.CIJ''
                when tcar.codigo = ''0'' then
                    ''6.EVE''
                when ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||')  then
                    ''3.ESP''
                when cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario in ('||v_id_gerente||')) then
                    ''1.ADM''
                when cat.desc_programa ilike ''%OPE%'' then
                    ''2.OPE''
                when cat.desc_programa ilike ''%COM%'' then
                    ''4.COM''
                end
                )::varchar as categoria,
            (case
                when lower(uo.nombre_unidad) like ''%cobija%'' then
                    ''COBIJA''
                when tcar.codigo = ''0'' then
                    ''EVENTUAL''
                when ca.codigo = ''SUPER'' and vf.id_funcionario not in ('||v_id_gerente||')  then
                    ''ESPECIAL''
                when cat.desc_programa ilike ''%ADM%'' or (ca.codigo = ''SUPER'' and vf.id_funcionario in ('||v_id_gerente||')) then
                    ''ADMINISTRACIÓN''
                when cat.desc_programa ilike ''%OPE%'' then
                    ''OPERACIÓN''
                when cat.desc_programa ilike ''%COM%'' then
                    ''COMERCIAL''
                end
                )::varchar as area,
            tlug.codigo::varchar as regional,
            bef.nro_comprobante::varchar as c31,
            bef.fecha_pago::date,
            (case when bef.sistema_fuente = ''Refrigerios'' then ''ref''
            	  when bef.sistema_fuente = ''Viatico Administrativo'' OR bef.sistema_fuente = ''Viatico Administrativo AMP'' then ''adm''
                  when bef.sistema_fuente = ''Viatico Operativo'' then ''ope'' end)::varchar as tipo,
            (case when coalesce(tuo.fecha_finalizacion,''31/12/9999''::date) <  '''||v_fecha_inicio||'''::date then ''BAJA'' else ''ACTIVO'' end)::varchar as estado,
            bef.tasa_nacional,
            bef.tasa_internacional,
            bef.importe_retencion,
            bef.nro_orden::varchar as orden,
            0::numeric as ref_sep,
            bef.id_fuente
            --plani.f_get_otro_ingreso(vf.id_funcionario, 2020, 11, ''ref_sep'')::numeric as ref_sep
            --FROM  beneficiario bef
            FROM plani.totros_ingresos bef
            --INNER JOIN orga.tuo_funcionario tuo ON tuo.id_uo_funcionario = bef.id_uo_funcionario and tuo.estado_reg = ''activo'' and tuo.tipo = ''oficial''
            INNER JOIN orga.tuo_funcionario tuo ON tuo.id_funcionario = bef.id_funcionario and tuo.estado_reg = ''activo'' and tuo.tipo = ''oficial'' and tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(bef.id_funcionario)
            INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = tuo.id_funcionario
            --INNER JOIN plani.totros_ingresos toi on toi.id_funcionario = vf.id_funcionario
            inner join orga.tcargo tcar on tcar.id_cargo = tuo.id_cargo and (tcar.estado_reg in (''activo'',''inactivo'') or tcar.fecha_fin = ''28/02/2021''::date)
            inner join param.tlugar tlug on tlug.id_lugar = tcar.id_lugar
            inner join orga.ttipo_contrato tcon on tcon.id_tipo_contrato = tcar.id_tipo_contrato
            inner join orga.tescala_salarial es on es.id_escala_salarial = tcar.id_escala_salarial and (es.estado_reg = ''activo'' or tcar.fecha_fin = ''28/02/2021''::date)
            inner JOIN orga.tcategoria_salarial ca ON ca.id_categoria_salarial = es.id_categoria_salarial
            inner join orga.tcargo_presupuesto cp on cp.id_cargo = tcar.id_cargo and cp.id_gestion = '||v_id_gestion||'
            inner join pre.tpresupuesto pre on pre.id_centro_costo = cp.id_centro_costo
            inner join pre.vcategoria_programatica cat on cat.id_categoria_programatica = pre.id_categoria_prog
            inner join orga.tuo uo on uo.id_uo = orga.f_get_uo_gerencia(tuo.id_uo, NULL,NULL)
            where '||v_fuente||' bef.gestion = '||v_parametros.gestion||' and ((bef.fecha_pago between '''||v_fecha_inicio||'''::date and '''|| v_fecha_final||'''::date) or bef.periodo = '||v_parametros.periodo||')
            '||v_with_body||'
            '||v_with_footer;

        v_consulta = v_consulta||' ORDER BY categoria asc, regional asc,  nombre_empleado asc ';

        raise notice 'v_consulta: %',v_consulta;
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

ALTER FUNCTION plani.ft_planilla_sel (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
  OWNER TO postgres;