--------------- SQL ---------------

CREATE OR REPLACE FUNCTION plani.f_prorratear_pres_cos_empleados (
  p_id_planilla integer,
  p_tipo_generacion varchar,
  p_id_usuario integer
)
RETURNS varchar AS
$body$
/*
    Autor: Guy Ribera Rojas
    Fecha: 28-09-2013
    Descripción:  calculo de prorrateo por centro de costo apra determinar el gasto de las planillas

  ***************************************************************************************************


    HISTORIAL DE MODIFICACIONES:

 ISSUE            FECHA:              AUTOR                 DESCRIPCION

 #0               28-09-2013        GUY BOA             Creacion
 #1               22-02-2019        Rarteaga            Integracion con sistema de asistencias , hoja_calculo
 #7               22-05-2019        Rarteaga            considerar columnas ci_contable en las hojas de tiempo
 #63              21-10-2019        Rarteaga KPLIAN     refactorizacion plnailla aguinlados, comentarios, etc
 #113             05/05/2020        RAC KPIAN           Solucion de bug en nombre de tabla y validacion en cambio de gestion para planilla de primas

*/
DECLARE
  v_registros        record;
  v_columnas        record;
  v_id_prorrateo    integer;
  v_id_pres_adm        integer;
  v_resp                    varchar;
  v_nombre_funcion          text;
  v_mensaje_error           text;
  v_planilla                record;
  v_consulta                varchar;
  v_presupuesto                record;
  v_id_presupuesto            integer;
  v_count                    integer;
  v_dias_aguinaldo            integer;
  v_suma                    numeric;
  v_porcentaje                numeric;
  v_valor_total                numeric;
  v_valor_horas                numeric;
  v_subsidio_actual            numeric;
  v_horas_laborales            numeric;
  v_id_gestion_contable        integer;
  v_registros_det           record;
  v_registros_aux           record;
  v_id_cc_aux               integer;

BEGIN
    v_nombre_funcion = 'plani.f_prorratear_pres_cos_empleados';


    SELECT p.*,tp.tipo_presu_cc,tp.calculo_horas,tp.codigo as tipo_planilla,per.fecha_fin as fecha_periodo, per.id_periodo
    into v_planilla
    from plani.tplanilla p
    inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
    left join param.tperiodo per on per.id_periodo = p.id_periodo
    where p.id_planilla = p_id_planilla;

    if (v_planilla.fecha_planilla is null) then
        raise exception 'La fecha de la planilla no puede estar vacia. La fecha de la planilla se toma como base para afectaciones contables y presupuestarias';
    end if;

    --obtener la gestion de los presupuestos a partir de la fecha de la planilla

    select po_id_gestion into v_id_gestion_contable
    from param.f_get_periodo_gestion(v_planilla.fecha_planilla);

    --raise exception '%,%',v_planilla.tipo_presu_cc,  v_planilla.calculo_horas;

    -----------------------------------------------------
    --llenar tprorrateo con datos de la parametrizazion
    -----------------------------------------------------
    if (v_planilla.tipo_presu_cc = 'parametrizacion' and v_planilla.calculo_horas = 'si') then

            v_horas_laborales = plani.f_get_valor_parametro_valor('HORLAB',v_planilla.fecha_periodo);

            for v_registros in (select
                                    fp.id_funcionario_planilla,ht.id_horas_trabajadas, fun.desc_funcionario1,
                                       ht.porcentaje_sueldo,ht.horas_normales,ht.sueldo
                                        from plani.thoras_trabajadas ht
                                        inner join plani.tfuncionario_planilla fp on
                                            fp.id_funcionario_planilla = ht.id_funcionario_planilla
                                        inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                                        where fp.id_planilla = p_id_planilla) loop

                    --obtener sueldo total y horas totales de columna valor

                    select c.valor into v_valor_horas
                    from plani.tcolumna_valor c
                    where id_funcionario_planilla = v_registros.id_funcionario_planilla
                    and c.codigo_columna = 'HORNORM' and c.estado_reg = 'activo';

                    select c.valor into v_valor_total
                    from plani.tcolumna_valor c
                    where id_funcionario_planilla = v_registros.id_funcionario_planilla
                    and c.codigo_columna = 'SUELDOBA' and c.estado_reg = 'activo';

                    v_presupuesto = NULL;
                    v_consulta = 'select
                                    ofi.id_oficina,
                                    ofi.id_lugar,
                                    cp.fecha_ini,
                                    sum(cp.porcentaje) as suma,
                                    pxp.aggarray(cp.id_centro_costo) as ids_presupuesto,
                                     pxp.aggarray(cp.porcentaje) as porcentajes,
                                     sum(ht.horas_normales) as suma_horas,
                                     sum(ht.horas_normales*ht.sueldo/' || v_horas_laborales || ') as suma_sueldos,
                                     ht.tipo_contrato
                                  from plani.thoras_trabajadas ht
                                  inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = ht.id_funcionario_planilla
                                  inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                                  inner join param.tperiodo per on per.id_periodo = p.id_periodo
                                  inner join orga.tuo_funcionario uofun on ht.id_uo_funcionario = uofun.id_uo_funcionario
                                  inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                  inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina';

                    --hacer el join con cargo_presupeusto o cargo_centro_costo segun corresponda
                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta = v_consulta || ' inner join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.estado_reg = ''activo''  ';
                    else
                        v_consulta = v_consulta || ' inner join orga.tcargo_centro_costo cp on cp.id_cargo = car.id_cargo and cp.estado_reg = ''activo'' ';
                    end if;

                    --obtener los presupeustos por contrato
                    v_consulta = v_consulta || ' where     cp.id_gestion = p.id_gestion and p.id_gestion = cp.id_gestion and
                                          ht.id_horas_trabajadas = ' || v_registros.id_horas_trabajadas||  ' and cp.fecha_ini<= ht.fecha_ini
                                  group by ofi.id_oficina,ofi.id_lugar,cp.fecha_ini,ht.tipo_contrato
                                  order by cp.fecha_ini desc
                                  limit 1 offset 0';

                    execute v_consulta
                    into v_presupuesto;

                    if (v_presupuesto is null) then

                        raise exception 'El cargo del funcionario % no tiene registrado un presupuesto',v_registros.desc_funcionario1;
                    end if;

                    if (v_presupuesto.suma != 100) then
                        raise exception 'El cargo del funcionario % no tiene registrado presupuesto al 100 porciento',v_registros.desc_funcionario1;
                    end if;
                    v_count = 1;

                    --para cada presupeusto en el array de presupuestos
                    foreach v_id_presupuesto in array v_presupuesto.ids_presupuesto loop

                            INSERT INTO
                              plani.tprorrateo
                            (
                              id_usuario_reg,
                              fecha_reg,
                              estado_reg,
                              id_funcionario_planilla,
                              id_horas_trabajadas,
                              id_presupuesto,
                              id_cc,
                              tipo_prorrateo,
                              porcentaje,
                              porcentaje_dias,
                              id_oficina,
                              id_lugar,
                              tipo_contrato
                            )
                            VALUES (
                              p_id_usuario,
                              now(),
                              'activo',
                              v_registros.id_funcionario_planilla,
                              v_registros.id_horas_trabajadas,
                              case when p_tipo_generacion = 'presupuestos' then
                                v_id_presupuesto
                              else
                                NULL
                              END,
                              case when p_tipo_generacion = 'costos' then
                                v_id_presupuesto
                              else
                                NULL
                              END,
                              p_tipo_generacion,
                              v_presupuesto.porcentajes[v_count]*v_registros.sueldo/v_horas_laborales*v_registros.horas_normales/v_valor_total,
                              v_presupuesto.porcentajes[v_count]*v_registros.horas_normales/v_valor_horas,
                              v_presupuesto.id_oficina,
                              v_presupuesto.id_lugar,
                              v_presupuesto.tipo_contrato
                            );
                            v_count = v_count + 1;
                    end loop;

            end loop;

     ---------------------------------------------------------------------------------------
     -- #1  llenar prorrateo desde sistema de asistencia segun hojas de calculo cargadas
     ---------------------------------------------------------------------------------------

     elsif (v_planilla.tipo_presu_cc = 'hoja_calculo') THEN

            v_mensaje_error = '';  --inicia mensaje de error

            for v_registros in (
                               select
                                    fp.id_funcionario,
                                    fp.id_planilla,
                                    fp.id_funcionario_planilla,
                                    mtc.id_centro_costo,
                                    mtc.total_horas,
                                    mtc.factor,
                                    ta.codigo_aplicacion,
                                    max(ht.id_horas_trabajadas)  id_horas_trabajadas
                                from plani.tfuncionario_planilla fp
                                inner join plani.thoras_trabajadas ht ON ht.id_funcionario_planilla = fp.id_funcionario_planilla
                                inner join plani.tplanilla pla on pla.id_planilla = fp.id_planilla
                                inner join asis.tmes_trabajo mt on mt.id_funcionario  = fp.id_funcionario  and mt.id_periodo = pla.id_periodo
                                inner join  asis.tmes_trabajo_con   mtc ON mtc.id_mes_trabajo = mt.id_mes_trabajo
                                inner join asis.ttipo_aplicacion ta ON ta.id_tipo_aplicacion = mtc.id_tipo_aplicacion
                                where fp.id_planilla = p_id_planilla
                                group by
                                    fp.id_funcionario,
                                    fp.id_planilla,
                                    fp.id_funcionario_planilla,
                                    mtc.id_centro_costo,
                                    mtc.total_horas,
                                    mtc.factor,
                                    ta.codigo_aplicacion

                                ) loop

                          select
                             ht.tipo_contrato,
                             ofi.id_lugar,
                             ofi.id_oficina
                           into v_registros_aux
                          from   plani.thoras_trabajadas ht
                          inner join orga.tuo_funcionario uofun on ht.id_uo_funcionario = uofun.id_uo_funcionario
                          inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                          inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                          where ht.id_horas_trabajadas = v_registros.id_horas_trabajadas;


                        INSERT INTO
                            plani.tprorrateo
                          (
                            id_usuario_reg,
                            fecha_reg,
                            estado_reg,
                            id_funcionario_planilla,
                            id_horas_trabajadas,
                            id_presupuesto,
                            id_cc,
                            tipo_prorrateo,
                            porcentaje,
                            porcentaje_dias,
                            id_oficina,
                            id_lugar,
                            tipo_contrato,
                            tipo_horario
                          )
                          VALUES (
                            p_id_usuario,
                            now(),
                            'activo',
                            v_registros.id_funcionario_planilla,
                            v_registros.id_horas_trabajadas,
                            v_registros.id_centro_costo,
                            NULL,
                            'presupuestos',
                            v_registros.factor,
                            v_registros.factor,
                            v_registros_aux.id_oficina,
                            v_registros_aux.id_lugar,
                            v_registros_aux.tipo_contrato,
                            v_registros.codigo_aplicacion
                          );

            end loop;
    -----------------------------------------------------------------TEST
     elsif (v_planilla.tipo_presu_cc = 'hoja_calculo_2') THEN

            v_mensaje_error = '';  --inicia mensaje de error




            v_horas_laborales = plani.f_get_valor_parametro_valor('HORLAB',v_planilla.fecha_periodo);

            for v_registros in ( select
                                    fp.id_funcionario,
                                    fp.id_planilla,
                                    fp.id_funcionario_planilla,
                                    ofi.id_oficina,
                                    ofi.id_lugar,
                                    ht.tipo_contrato,


                                    sum( toc.total_normal ) as total_normal,
                                    sum(toc.total_nocturna ) as total_nocturna,
                                    sum(toc.total_extra) as total_extra,
                                    sum( toc.extra_autorizada) as total_extra_autorizada

                                  from plani.tfuncionario_planilla fp
                                  inner join plani.thoras_trabajadas ht ON ht.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join plani.tplanilla pla on pla.id_planilla = fp.id_planilla
                                  inner join asis.vtotales_horas_centro_costo  toc ON toc.id_funcionario = fp.id_funcionario and toc.id_periodo = pla.id_periodo
                                  inner join orga.tuo_funcionario uofun on ht.id_uo_funcionario = uofun.id_uo_funcionario
                                  inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                  inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                                  where fp.id_planilla = p_id_planilla
                                  group by fp.id_funcionario,
                                           fp.id_planilla,
                                           fp.id_funcionario_planilla,
                                           ofi.id_oficina,
                                           ofi.id_lugar,
                                           ht.tipo_contrato) loop



                    select c.valor into v_valor_total
                    from plani.tcolumna_valor c
                    where id_funcionario_planilla = v_registros.id_funcionario_planilla
                    and c.codigo_columna = 'SUELDOBA' and c.estado_reg = 'activo';

                    ---------------------
                    --prorratear horas
                    --------------------

                    IF v_registros.total_normal > 0 THEN

                        --para cada presupeusto en el array de presupuestos

                        FOR v_registros_det in (
                                                select
                                                  fp.id_funcionario,
                                                  fp.id_planilla,
                                                  toc.id_centro_costo,
                                                  toc.total_normal,
                                                  toc.total_nocturna,
                                                  toc.total_extra,
                                                  toc.extra_autorizada,
                                                  case
                                                  when v_registros.total_normal > 0
                                                  then (100*(toc.total_normal/v_registros.total_normal) )
                                                  else 0
                                                  end as porcentaje_normal,
                                                  case
                                                  when v_registros.total_nocturna > 0
                                                  then (100*(toc.total_nocturna/v_registros.total_nocturna) )
                                                  else 0
                                                  end as porcentaje_nocturna,
                                                  case
                                                  when v_registros.total_extra_autorizada > 0
                                                  then (100*(toc.extra_autorizada/v_registros.total_extra_autorizada) )
                                                  else 0
                                                  end as porcentaje_extra
                                                from plani.tfuncionario_planilla fp
                                                inner join plani.tplanilla pla on pla.id_planilla = fp.id_planilla
                                                inner join asis.vtotales_horas_centro_costo  toc ON toc.id_funcionario = fp.id_funcionario and toc.id_periodo = pla.id_periodo
                                                where fp.id_planilla = p_id_planilla and fp.id_funcionario = v_registros.id_funcionario ) LOOP

                               --horas normales
                              IF v_registros_det.total_normal > 0    THEN
                                  INSERT INTO
                                      plani.tprorrateo
                                    (
                                      id_usuario_reg,
                                      fecha_reg,
                                      estado_reg,
                                      id_funcionario_planilla,
                                      id_horas_trabajadas,
                                      id_presupuesto,
                                      id_cc,
                                      tipo_prorrateo,
                                      porcentaje,
                                      porcentaje_dias,
                                      id_oficina,
                                      id_lugar,
                                      tipo_contrato,
                                      tipo_horario
                                    )
                                    VALUES (
                                      p_id_usuario,
                                      now(),
                                      'activo',
                                      v_registros.id_funcionario_planilla,
                                      NULL,--v_registros.id_horas_trabajadas,
                                      v_registros_det.id_centro_costo,
                                      NULL,
                                      'presupuestos',
                                      v_registros_det.porcentaje_normal,
                                      v_registros_det.porcentaje_normal,
                                      v_registros.id_oficina,
                                      v_registros.id_lugar,
                                      v_registros.tipo_contrato,
                                      'normal'
                                    );
                               END IF;

                              IF v_registros_det.total_nocturna > 0   THEN
                                   INSERT INTO
                                      plani.tprorrateo
                                    (
                                      id_usuario_reg,
                                      fecha_reg,
                                      estado_reg,
                                      id_funcionario_planilla,
                                      id_horas_trabajadas,
                                      id_presupuesto,
                                      id_cc,
                                      tipo_prorrateo,
                                      porcentaje,
                                      porcentaje_dias,
                                      id_oficina,
                                      id_lugar,
                                      tipo_contrato,
                                      tipo_horario
                                    )
                                    VALUES (
                                      p_id_usuario,
                                      now(),
                                      'activo',
                                      v_registros.id_funcionario_planilla,
                                      NULL,--v_registros.id_horas_trabajadas,
                                      v_registros_det.id_centro_costo,
                                      NULL,
                                      'presupuestos',
                                      v_registros_det.porcentaje_nocturna,
                                      v_registros_det.porcentaje_nocturna,
                                      v_registros.id_oficina,
                                      v_registros.id_lugar,
                                      v_registros.tipo_contrato,
                                      'nocturna'
                                    );

                              END IF;

                              IF v_registros_det.extra_autorizada > 0   THEN
                                INSERT INTO
                                      plani.tprorrateo
                                    (
                                      id_usuario_reg,
                                      fecha_reg,
                                      estado_reg,
                                      id_funcionario_planilla,
                                      id_horas_trabajadas,
                                      id_presupuesto,
                                      id_cc,
                                      tipo_prorrateo,
                                      porcentaje,
                                      porcentaje_dias,
                                      id_oficina,
                                      id_lugar,
                                      tipo_contrato,
                                      tipo_horario
                                    )
                                    VALUES (
                                      p_id_usuario,
                                      now(),
                                      'activo',
                                      v_registros.id_funcionario_planilla,
                                      NULL,--v_registros.id_horas_trabajadas,
                                      v_registros_det.id_centro_costo,
                                      NULL,
                                      'presupuestos',
                                      v_registros_det.porcentaje_extra,
                                      v_registros_det.porcentaje_extra,
                                      v_registros.id_oficina,
                                      v_registros.id_lugar,
                                      v_registros.tipo_contrato,
                                      'extra'
                                    );
                              END IF;

                              v_count = v_count + 1;
                        end loop;
                    END IF;


            end loop;

    -----------------------------------------------------------------
    --llenar tprorrateo con los datos del ultimo centro de costo
    --------------------------------------------------------------
    elsif (v_planilla.tipo_presu_cc = 'prorrateo_aguinaldo' and v_planilla.calculo_horas = 'si' ) then

            for v_registros in (select fp.id_funcionario,fp.id_funcionario_planilla, fun.desc_funcionario1, p.id_gestion
                                        from plani.tfuncionario_planilla fp
                                        inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                                        inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                                        where fp.id_planilla = p_id_planilla) loop

                v_presupuesto = NULL;
                if (p_tipo_generacion = 'presupuestos') then
                    v_consulta =  ' select ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,fp.id_funcionario,pro.id_presupuesto,NULL::integer as id_cc, sum((cv.valor*pro.porcentaje)/100)/8 as dias_presupuesto,max(uofun.fecha_asignacion) as fecha_asignacion ';
                else
                    v_consulta =  ' select ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,fp.id_funcionario,pro.id_cc,NULL::integer as id_presupuesto, sum((cv.valor*pro.porcentaje)/100)/8 as dias_presupuesto,max(uofun.fecha_asignacion) as fecha_asignacion ';
                end if;
                v_consulta =  v_consulta || '
                              from plani.tfuncionario_planilla fp
                              inner join plani.thoras_trabajadas ht  on ht.id_funcionario_planilla = fp.id_funcionario_planilla
                              inner join orga.tuo_funcionario uofun on ht.id_uo_funcionario = uofun.id_uo_funcionario
                              inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                              inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                              inner join plani.tprorrateo pro  on pro.id_horas_trabajadas = ht.id_horas_trabajadas
                              inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                              inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                              inner join plani.tcolumna_valor cv on fp.id_funcionario_planilla = cv.id_funcionario_planilla
                              where cv.codigo_columna = ''HORNORM'' and tp.codigo = ''PLASUE''
                                and p.id_gestion = ' || v_registros.id_gestion || ' and fp.id_funcionario = ' || v_registros.id_funcionario || ' and
                              p.estado_reg=''activo''';

                if (p_tipo_generacion = 'presupuestos') then
                    v_consulta = v_consulta || ' group by ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,fp.id_funcionario,pro.id_presupuesto ';
                else
                    v_consulta = v_consulta || ' group by ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,fp.id_funcionario,pro.id_cc ';
                end if;

                v_consulta = v_consulta || ' order by fecha_asignacion asc';
                select cv.valor::integer into v_dias_aguinaldo
                from  plani.tcolumna_valor cv
                where cv.id_funcionario_planilla = v_registros.id_funcionario_planilla and
                cv.codigo_columna = 'DIASAGUI';

               v_suma = 0;

               for v_presupuesto in execute(v_consulta) loop
                        --se obtiene el porcentaje de los dias con el presupuesto de los dias del aguinaldo
                        if (v_presupuesto.dias_presupuesto > v_dias_aguinaldo) then
                            v_porcentaje = 100;
                        else
                            v_porcentaje = round(v_presupuesto.dias_presupuesto/v_dias_aguinaldo*100,2);
                        end if;
                        v_suma = v_suma + v_porcentaje;
                        --si se excede por redondeo restamos la diferencia del ultimo prorrateo
                        if (v_suma > 100 and v_suma < 101) then
                            v_porcentaje = v_porcentaje + (100 - v_suma);
                            v_suma = v_suma + (100 - v_suma);
                        end if;
                        --insertamos un prorrateo
                        INSERT INTO
                          plani.tprorrateo
                        (
                          id_usuario_reg,
                          fecha_reg,
                          estado_reg,
                          id_funcionario_planilla,
                          id_horas_trabajadas,
                          id_presupuesto,
                          id_cc,
                          tipo_prorrateo,
                          porcentaje,
                          tipo_contrato,
                          id_oficina,
                          id_lugar
                        )
                        VALUES (
                          p_id_usuario,
                          now(),
                          'activo',
                          v_registros.id_funcionario_planilla,
                          NULL,
                          case when p_tipo_generacion = 'presupuestos' then
                            v_presupuesto.id_presupuesto
                          else
                            NULL
                          END,
                          case when p_tipo_generacion = 'costos' then
                            v_presupuesto.id_cc
                          else
                            NULL
                          END,
                          p_tipo_generacion,
                          v_porcentaje,
                          v_presupuesto.tipo_contrato,
                          v_presupuesto.id_oficina,
                          v_presupuesto.id_lugar
                        );

                   end loop;

                   if (v_suma = 0) then
                        raise exception 'La suma de presupuestos para el empleado %, suma 0',v_registros.desc_funcionario1;
                   elsif (v_suma < 100) then
                        INSERT INTO
                          plani.tprorrateo
                        (
                          id_usuario_reg,
                          fecha_reg,
                          estado_reg,
                          id_funcionario_planilla,
                          id_horas_trabajadas,
                          id_presupuesto,
                          id_cc,
                          tipo_prorrateo,
                          porcentaje,
                          tipo_contrato,
                          id_oficina,
                          id_lugar
                        )
                        VALUES (
                          p_id_usuario,
                          now(),
                          'activo',
                          v_registros.id_funcionario_planilla,
                          NULL,
                          case when p_tipo_generacion = 'presupuestos' then
                            v_presupuesto.id_presupuesto
                          else
                            NULL
                          END,
                          case when p_tipo_generacion = 'costos' then
                            v_presupuesto.id_cc
                          else
                            NULL
                          END,
                          p_tipo_generacion,
                          100 - v_suma,
                          v_presupuesto.tipo_contrato,
                          v_presupuesto.id_oficina,
                          v_presupuesto.id_lugar
                        );
                   elsif (v_suma > 100) then
                        raise exception 'La suma de presupuestos para el empleado %, suma mas del 100 porciento,%',v_registros.desc_funcionario1,v_suma;
                   end if;


            end loop;
    ---------------------------------------------------------------
    --llenar tprorrateo con los datos del ultimo centro de costo
    ---------------------------------------------------------------
    elsif (v_planilla.tipo_presu_cc = 'retroactivo_sueldo') then

            for v_registros in (select fp.id_funcionario,fp.id_funcionario_planilla, fun.desc_funcionario1, p.id_gestion
                                        from plani.tfuncionario_planilla fp
                                        inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                                        inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                                        where fp.id_planilla = p_id_planilla) loop

                    v_presupuesto = NULL;
                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta =  ' select ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,cp.id_centro_costo,NULL::integer as id_cc, sum(cd.valor) as valor_presupuesto ';
                    else
                        v_consulta =  ' select ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,cp.id_centro_costo,NULL::integer as id_presupuesto, sum(cd.valor) as valor_presupuesto ';
                    end if;
                    v_consulta =  v_consulta || '
                                  from plani.tfuncionario_planilla fp
                                  inner join plani.tplanilla p
                                    on p.id_planilla = fp.id_planilla
                                  inner join plani.tcolumna_valor cv  on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join plani.tcolumna_detalle cd  on cd.id_columna_valor = cv.id_columna_valor
                                  inner join plani.thoras_trabajadas ht on ht.id_horas_trabajadas = cd.id_horas_trabajadas
                                  inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = ht.id_uo_funcionario
                                  inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                  inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina';

                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta = v_consulta || ' inner join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.estado_reg = ''activo'' and
                                                                            cp.fecha_ini =     (select max(fecha_ini)
                                                                                            from orga.tcargo_presupuesto
                                                                                            where id_cargo = car.id_cargo and
                                                                                                fecha_ini <= ht.fecha_ini and id_gestion = p.id_gestion)  ';
                    else
                        v_consulta = v_consulta || ' inner join orga.tcargo_centro_costo cp on cp.id_cargo = car.id_cargo and cp.estado_reg = ''activo'' and
                                                                            cp.fecha_ini =     (select max(fecha_ini)
                                                                                            from orga.tcargo_presupuesto
                                                                                            where id_cargo = car.id_cargo and
                                                                                                fecha_ini <= ht.fecha_ini and id_gestion = p.id_gestion) ';
                    end if;

                    v_consulta = v_consulta || '   where cv.codigo_columna = ''COTIZABLE''  and cp.id_gestion = p.id_gestion
                                    and fp.id_funcionario_planilla = ' || v_registros.id_funcionario_planilla|| ' and cp.fecha_ini<= ht.fecha_ini ';

                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta = v_consulta || ' group by ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,cp.id_centro_costo ';
                    else
                        v_consulta = v_consulta || ' group by ofi.id_oficina,ofi.id_lugar,ht.tipo_contrato,cp.id_centro_costo ';
                    end if;

                   --raise exception '%',v_consulta;
                    select cv.valor into v_valor_total
                    from  plani.tcolumna_valor cv
                    where cv.id_funcionario_planilla = v_registros.id_funcionario_planilla and
                    cv.codigo_columna = 'COTIZABLE';

                   v_suma = 0;

                   for v_presupuesto in execute(v_consulta) loop
                            --se obtiene el porcentaje de los dias con el presupuesto de los dias del aguinaldo
                            v_porcentaje = round(v_presupuesto.valor_presupuesto/v_valor_total,2)*100;
                            /*if (v_registros.id_funcionario_planilla = 217792) then
                                raise exception '%,%',v_valor_total,v_presupuesto.valor_presupuesto;
                            end if;*/
                            v_suma = v_suma + v_porcentaje;
                            --si se excede por redondeo restamos la diferencia del ultimo prorrateo
                            if (v_suma > 100 and v_suma <= 101) then
                                v_porcentaje = v_porcentaje + (100 - v_suma);
                                v_suma = v_suma + (100 - v_suma);
                            end if;
                            --insertamos un prorrateo
                            INSERT INTO
                              plani.tprorrateo
                            (
                              id_usuario_reg,
                              fecha_reg,
                              estado_reg,
                              id_funcionario_planilla,
                              id_horas_trabajadas,
                              id_presupuesto,
                              id_cc,
                              tipo_prorrateo,
                              porcentaje,
                              tipo_contrato,
                              id_oficina,
                              id_lugar
                            )
                            VALUES (
                              p_id_usuario,
                              now(),
                              'activo',
                              v_registros.id_funcionario_planilla,
                              NULL,
                              case when p_tipo_generacion = 'presupuestos' then
                                v_presupuesto.id_centro_costo
                              else
                                NULL
                              END,
                              case when p_tipo_generacion = 'costos' then
                                v_presupuesto.id_centro_costo
                              else
                                NULL
                              END,
                              p_tipo_generacion,
                              v_porcentaje,
                              v_presupuesto.tipo_contrato,
                              v_presupuesto.id_oficina,
                              v_presupuesto.id_lugar
                            );

                   end loop;

                   if (v_suma < 100) then
                        raise exception 'La suma de presupuestos para el empleado %, no suma el 100 porciento,%',v_registros.desc_funcionario1,v_suma;
                   elsif (v_suma > 100) then
                        raise exception 'La suma de presupuestos para el empleado %, suma mas del 100 porciento,%',v_registros.desc_funcionario1,v_suma;
                   end if;


            end loop;
    --------------------------------------------------------------
    --llenar tprorrateo con los datos del ultimo
    -- retroactivo_asignaciones
    --------------------------------------------------------------

    elsif (v_planilla.tipo_presu_cc = 'retroactivo_asignaciones') then

            v_subsidio_actual = plani.f_get_valor_parametro_valor('MONTOSUB',v_planilla.fecha_planilla);

            for v_registros in (select fp.id_funcionario,fp.id_funcionario_planilla, fun.desc_funcionario1, p.id_gestion
                                        from plani.tfuncionario_planilla fp
                                        inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                                        inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                                        where fp.id_planilla = p_id_planilla) loop

                    v_presupuesto = NULL;
                    if (p_tipo_generacion = 'presupuestos') then

                        v_consulta =  ' select ofi.id_oficina,ofi.id_lugar,tc.codigo as tipo_contrato,cp.id_presupuesto,NULL::integer as id_cc,
                        ((cv.valor/plani.f_get_valor_parametro_valor(''MONTOSUB'',p.fecha_fin)) * (' || v_subsidio_actual || ' - plani.f_get_valor_parametro_valor(''MONTOSUB'',p.fecha_fin))) as valor_presupuesto ';

                    else

                        v_consulta =  ' select ofi.id_oficina,ofi.id_lugar,tc.codigo as tipo_contrato,cp.id_cc,NULL::integer as id_presupuesto,
                        ((cv.valor/plani.f_get_valor_parametro_valor(''MONTOSUB'',p.fecha_fin)) * (' || v_subsidio_actual || ' - plani.f_get_valor_parametro_valor(''MONTOSUB'',p.fecha_fin))) as valor_presupuesto ';

                    end if;

                    v_consulta =  v_consulta || '
                                  from plani.tfuncionario_planilla fp
                                  inner join plani.tplanilla p on fp.id_planilla = p.id_planilla
                                  inner join param.tperiodo per on per.id_periodo = p.id_periodo
                                  inner join plani.tcolumna_valor cv  on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = ht.id_uo_funcionario
                                  inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                  inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                                  inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato';

                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta = v_consulta || ' inner join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo and cp.estado_reg = ''activo''  ';
                    else
                        v_consulta = v_consulta || ' inner join orga.tcargo_centro_costo cp on cp.id_cargo = car.id_cargo and cp.estado_reg = ''activo'' ';
                    end if;

                    v_consulta = v_consulta || '   where cv.codigo_columna = ''TOTSUB''
                                    and fp.id_funcionario = ' || v_registros.id_funcionario_planilla || ' and cp.fecha_ini<= ht.fecha_ini ';

                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta = v_consulta || ' group by ofi.id_oficina,ofi.id_lugar,tc.codigo,cp.id_presupuesto ';
                    else
                        v_consulta = v_consulta || ' group by ofi.id_oficina,ofi.id_lugar,tc.codigo,cp.id_cc ';
                    end if;


                    select cv.valor::integer into v_valor_total
                    from  plani.tcolumna_valor cv
                    where cv.id_funcionario_planilla = v_registros.id_funcionario_planilla and
                    cv.codigo_columna = 'TOTSUB';

                   v_suma = 0;

                   for v_presupuesto in execute(v_consulta) loop
                          --se obtiene el porcentaje de los dias con el presupuesto de los dias del aguinaldo
                          v_porcentaje = round(v_presupuesto.valor_presupuesto/v_valor_total,2);
                          v_suma = v_suma + v_porcentaje;
                          --si se excede por redondeo restamos la diferencia del ultimo prorrateo
                          if (v_suma > 100 and v_suma < 101) then
                              v_porcentaje = v_porcentaje + (100 - v_suma);
                              v_suma = v_suma + (100 - v_suma);
                          end if;
                          --insertamos un prorrateo
                          INSERT INTO
                            plani.tprorrateo
                          (
                            id_usuario_reg,
                            fecha_reg,
                            estado_reg,
                            id_funcionario_planilla,
                            id_horas_trabajadas,
                            id_presupuesto,
                            id_cc,
                            tipo_prorrateo,
                            porcentaje,
                            tipo_contrato,
                            id_oficina,
                            id_lugar
                          )
                          VALUES (
                            p_id_usuario,
                            now(),
                            'activo',
                            v_registros.id_funcionario_planilla,
                            NULL,
                            case when p_tipo_generacion = 'presupuestos' then
                              v_presupuesto.id_presupuesto
                            else
                              NULL
                            END,
                            case when p_tipo_generacion = 'costos' then
                              v_presupuesto.id_cc
                            else
                              NULL
                            END,
                            p_tipo_generacion,
                            v_porcentaje,
                            v_presupuesto.tipo_contrato,
                            v_presupuesto.id_oficina,
                            v_presupuesto.id_lugar
                          );

                   end loop;

                   if (v_suma < 100) then
                        raise exception 'La suma de presupuestos para el empleado %, no suma el 100 porciento',v_registros.desc_funcionario1;
                   elsif (v_suma > 100) then
                        raise exception 'La suma de presupuestos para el empleado %, suma mas del 100 porciento',v_registros.desc_funcionario1;
                   end if;


            end loop;

    --------------------------------------------------------------
    --llenar tprorrateo con los datos del ultimo
    -- ultimo_activo_periodo
    -------------------------------------------------------------
    elsif (v_planilla.tipo_presu_cc = 'ultimo_activo_periodo') then

            for v_registros in (select fp.id_funcionario_planilla, fun.desc_funcionario1
                                        from plani.tfuncionario_planilla fp
                                        inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                                        where fp.id_planilla = p_id_planilla) loop

                    v_presupuesto = NULL;
                    v_consulta = 'select ofi.id_oficina,ofi.id_lugar,tc.codigo as tipo_contrato,cp.fecha_ini, sum(cp.porcentaje) as suma, pxp.aggarray(cp.id_centro_costo) as ids_presupuesto, pxp.aggarray(cp.porcentaje) as porcentajes
                                  from plani.tfuncionario_planilla fp
                                  inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                                  inner join orga.tuo_funcionario uofun on fp.id_uo_funcionario = uofun.id_uo_funcionario
                                  inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                  inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                                  inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
                                  inner join param.tperiodo per on per.id_periodo = p.id_periodo ';
                    --hacer el join con cargo_presupeusto o cargo_centro_costo segun corresponda
                    if (p_tipo_generacion = 'presupuestos') then
                        v_consulta = v_consulta || ' inner join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo ';
                    else
                        v_consulta = v_consulta || ' inner join orga.tcargo_centro_costo cp on cp.id_cargo = car.id_cargo ';
                    end if;

                    --obtener los presupeustos por contrato
                    v_consulta = v_consulta || ' where     cp.id_gestion = p.id_gestion and p.id_gestion = cp.id_gestion and
                                          fp.id_funcionario_planilla = ' || v_registros.id_funcionario_planilla||  ' and cp.fecha_ini<= per.fecha_fin
                                  group by ofi.id_oficina,ofi.id_lugar,tc.codigo,cp.fecha_ini
                                  order by cp.fecha_ini desc
                                  limit 1 offset 0';


                    execute v_consulta
                    into v_presupuesto;

                    if (v_presupuesto is null) then

                        raise exception 'El cargo del funcionario % no tiene registrado un presupuesto',v_registros.desc_funcionario1;
                    end if;

                    if (v_presupuesto.suma != 100) then
                        raise exception 'El cargo del funcionario % no tiene registrado presupuesto al 100 porciento',v_registros.desc_funcionario1;
                    end if;
                    v_count = 1;

                    --para cada presupeusto en el array de presupuestos
                    foreach v_id_presupuesto in array v_presupuesto.ids_presupuesto loop

                            INSERT INTO
                              plani.tprorrateo
                            (
                              id_usuario_reg,
                              fecha_reg,
                              estado_reg,
                              id_funcionario_planilla,
                              id_horas_trabajadas,
                              id_presupuesto,
                              id_cc,
                              tipo_prorrateo,
                              porcentaje,
                              tipo_contrato,
                              id_oficina,
                              id_lugar
                            )
                            VALUES (
                              p_id_usuario,
                              now(),
                              'activo',
                              v_registros.id_funcionario_planilla,
                              NULL,
                              case when p_tipo_generacion = 'presupuestos' then
                                v_id_presupuesto
                              else
                                NULL
                              END,
                              case when p_tipo_generacion = 'costos' then
                                v_id_presupuesto
                              else
                                NULL
                              END,
                              p_tipo_generacion,
                              v_presupuesto.porcentajes[v_count],
                              v_presupuesto.tipo_contrato,
                              v_presupuesto.id_oficina,
                              v_presupuesto.id_lugar
                            );
                            v_count = v_count + 1;
                    end loop;

            end loop;

       -----------------------------------------------------------------
       --llenar tprorrateo con los datos del
       -- 'ultimo_activo_gestion','ultimo_activo_gestion_anterior'
       ---------------------------------------------------------

    elsif (v_planilla.tipo_presu_cc in ('ultimo_activo_gestion','ultimo_activo_gestion_anterior') ) then

            for v_registros in (select fp.id_funcionario_planilla, fun.desc_funcionario1
                                        from plani.tfuncionario_planilla fp
                                        inner join orga.vfuncionario fun on fun.id_funcionario = fp.id_funcionario
                                        where fp.id_planilla = p_id_planilla) loop

                v_presupuesto = NULL;
                v_consulta = 'select ofi.id_oficina,ofi.id_lugar,tc.codigo as tipo_contrato,cp.fecha_ini, sum(cp.porcentaje) as suma, pxp.aggarray(cp.id_centro_costo) as ids_presupuesto, pxp.aggarray(cp.porcentaje) as porcentajes
                              from plani.tfuncionario_planilla fp
                              inner join plani.tplanilla p on p.id_planilla = fp.id_planilla
                              inner join orga.tuo_funcionario uofun on fp.id_uo_funcionario = uofun.id_uo_funcionario
                              inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                              inner join orga.toficina ofi on ofi.id_oficina = car.id_oficina
                              inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
                              inner join param.tgestion ges on ges.id_gestion = p.id_gestion ';
                --hacer el join con cargo_presupeusto o cargo_centro_costo segun corresponda
                if (p_tipo_generacion = 'presupuestos') then
                    v_consulta = v_consulta || ' inner join orga.tcargo_presupuesto cp on cp.id_cargo = car.id_cargo ';
                else
                    v_consulta = v_consulta || ' inner join orga.tcargo_centro_costo cp on cp.id_cargo = car.id_cargo ';
                end if;

                --obtener los presupeustos por contrato
                v_consulta = v_consulta || ' where     cp.id_gestion = p.id_gestion and p.id_gestion = cp.id_gestion and
                                      fp.id_funcionario_planilla = ' || v_registros.id_funcionario_planilla||  ' and cp.fecha_ini<= (''31/12/'' || ges.gestion)::date
                              group by ofi.id_oficina,ofi.id_lugar,tc.codigo,cp.fecha_ini
                              order by cp.fecha_ini desc
                              limit 1 offset 0';

                --raise exception '%',v_consulta;
                execute v_consulta
                into v_presupuesto;

                if (v_presupuesto is null) then
                    raise exception 'El cargo del funcionario % no tiene registrado un presupuesto',v_registros.desc_funcionario1;
                end if;

                if (v_presupuesto.suma != 100) then
                    raise exception 'El cargo del funcionario % no tiene registrado presupuesto al 100 porciento',v_registros.desc_funcionario1;
                end if;
                v_count = 1;

                --para cada presupeusto en el array de presupuestos
                foreach v_id_presupuesto in array v_presupuesto.ids_presupuesto loop

                    INSERT INTO
                      plani.tprorrateo
                    (
                      id_usuario_reg,
                      fecha_reg,
                      estado_reg,
                      id_funcionario_planilla,
                      id_horas_trabajadas,
                      id_presupuesto,
                      id_cc,
                      tipo_prorrateo,
                      porcentaje,
                      tipo_contrato,
                      id_oficina,
                      id_lugar
                    )
                    VALUES (
                      p_id_usuario,
                      now(),
                      'activo',
                      v_registros.id_funcionario_planilla,
                      NULL,
                      case when p_tipo_generacion = 'presupuestos' then
                        v_id_presupuesto
                      else
                        NULL
                      END,
                      case when p_tipo_generacion = 'costos' then
                        v_id_presupuesto
                      else
                        NULL
                      END,
                      p_tipo_generacion,
                      v_presupuesto.porcentajes[v_count],
                      v_presupuesto.tipo_contrato,
                      v_presupuesto.id_oficina,
                      v_presupuesto.id_lugar
                    );
                    v_count = v_count + 1;
                end loop;

            end loop;

    end if;  --FIN IF configuracion


    --si la gestion de la planilla es distinta a la gestion de la fecha en la que se generara el prorrateo
    if (v_planilla.id_gestion != v_id_gestion_contable)then


        update plani.tprorrateo
           set id_presupuesto = (select pids.id_presupuesto_dos
                                   from pre.tpresupuesto_ids pids --#113 cambio de nombre de tabla
                                  where pids.id_presupuesto_uno = id_presupuesto
                                    and sw_cambio_gestion = 'gestion')
         from plani.tfuncionario_planilla fp
        where fp.id_funcionario_planilla = plani.tprorrateo.id_funcionario_planilla
          and fp.id_planilla = p_id_planilla;

    end if;

    --------------------------------------------------------
    --llenar tprorrateo_columna de acuerdo al prorrateo
    -------------------------------------------------------
    IF  v_planilla.tipo_presu_cc not in ('hoja_calculo') then

            if (v_planilla.tipo_presu_cc = 'parametrizacion' and v_planilla.calculo_horas = 'si') then

                  v_consulta = '    select
                                      pro.id_oficina,
                                      pro.id_lugar,
                                      pro.id_prorrateo,
                                      pro.porcentaje,
                                      pro.porcentaje_dias,
                                      cv.id_tipo_columna,
                                      cv.codigo_columna,
                                      tc.compromete
                                  from plani.tprorrateo pro
                                  inner join plani.thoras_trabajadas ht on pro.id_horas_trabajadas = ht.id_horas_trabajadas
                                  inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = ht.id_funcionario_planilla
                                  inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and
                                                                  tc.compromete = ''si''
                                  where fp.id_planilla = ' || p_id_planilla;

            elsif (v_planilla.tipo_presu_cc in ('ultimo_activo_gestion_anterior','ultimo_activo_gestion','ultimo_activo_periodo', 'prorrateo_aguinaldo', 'retroactivo_sueldo' ,'retroactivo_asignaciones')) then

                  v_consulta = '    select
                                       pro.id_oficina,
                                       pro.id_lugar,
                                       pro.id_prorrateo,
                                       pro.porcentaje,
                                       pro.porcentaje_dias,
                                       cv.id_tipo_columna,
                                       cv.codigo_columna,
                                       tc.compromete
                                  from plani.tprorrateo pro
                                  inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = pro.id_funcionario_planilla
                                  inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = pro.id_funcionario_planilla
                                  inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and
                                                                  tc.compromete = ''si''
                                  where fp.id_planilla = ' || p_id_planilla;



            end if;

            for v_registros in execute (v_consulta) loop

                INSERT INTO
                  plani.tprorrateo_columna
                (
                  id_usuario_reg,
                  fecha_reg,
                  estado_reg,
                  id_prorrateo,
                  id_tipo_columna,
                  codigo_columna,
                  porcentaje,
                  compromete,
                  id_oficina,
                  id_lugar
                )
                VALUES (
                  p_id_usuario,
                  now(),
                  'activo',
                  v_registros.id_prorrateo,
                  v_registros.id_tipo_columna,
                  v_registros.codigo_columna,
                  (case when (v_registros.codigo_columna = 'BONANT' and v_planilla.tipo_planilla = 'PLASUE') then
                    v_registros.porcentaje_dias
                  else
                    v_registros.porcentaje
                  end),
                  v_registros.compromete,
                  v_registros.id_oficina,
                  v_registros.id_lugar
                );
            end loop;

    ELSE
         -----------------------------------------------------------------------------------------------------------
         -- #1 prorateo para la mayoria de la columans con presupesuto se hace sobre las horas normales d etrabajo
         -----------------------------------------------------------------------------------------------------------

         FOR v_registros in (
                                 select
                                      pro.id_oficina,
                                      pro.id_lugar,
                                      pro.id_prorrateo,
                                      pro.porcentaje,
                                      pro.porcentaje_dias,
                                      cv.id_tipo_columna,
                                      cv.codigo_columna,
                                      tc.compromete
                                  from plani.tprorrateo pro
                                --  inner join plani.thoras_trabajadas ht on pro.id_horas_trabajadas = ht.id_horas_trabajadas
                                  inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = pro.id_funcionario_planilla
                                  inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and tc.compromete = 'si'
                                  where fp.id_planilla = p_id_planilla
                                       and tc.codigo not in ('EXTRA','NOCTURNO')
                                       and pro.tipo_horario = 'normal' -- #1 veiene del codigo de aplicacion
                               ) LOOP

               INSERT INTO
                  plani.tprorrateo_columna
                (
                  id_usuario_reg,
                  fecha_reg,
                  estado_reg,
                  id_prorrateo,
                  id_tipo_columna,
                  codigo_columna,
                  porcentaje,
                  compromete,
                  id_oficina,
                  id_lugar
                )
                VALUES (
                  p_id_usuario,
                  now(),
                  'activo',
                  v_registros.id_prorrateo,
                  v_registros.id_tipo_columna,
                  v_registros.codigo_columna,
                   v_registros.porcentaje_dias,
                  v_registros.compromete,
                  v_registros.id_oficina,
                  v_registros.id_lugar
                );


         END LOOP;
        -----------------------------
        --prorrateo de horas EXTRA
        -----------------------------
        FOR v_registros in (
                             select
                                  pro.id_oficina,
                                  pro.id_lugar,
                                  pro.id_prorrateo,
                                  pro.porcentaje,
                                  pro.porcentaje_dias,
                                  cv.id_tipo_columna,
                                  cv.codigo_columna,
                                  tc.compromete,
                                  pro.calculado_resta
                              from plani.tprorrateo pro
                              --inner join plani.thoras_trabajadas ht on pro.id_horas_trabajadas = ht.id_horas_trabajadas
                              inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = pro.id_funcionario_planilla
                              inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                              inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and tc.compromete = 'si'
                              where fp.id_planilla = p_id_planilla
                                   and tc.codigo  in ('EXTRA')
                                   and pro.tipo_horario = 'extra'
                           ) LOOP

               INSERT INTO
                  plani.tprorrateo_columna
                (
                  id_usuario_reg,
                  fecha_reg,
                  estado_reg,
                  id_prorrateo,
                  id_tipo_columna,
                  codigo_columna,
                  porcentaje,
                  compromete,
                  id_oficina,
                  id_lugar
                )
                VALUES (
                  p_id_usuario,
                  now(),
                  'activo',
                  v_registros.id_prorrateo,
                  v_registros.id_tipo_columna,
                  v_registros.codigo_columna,
                   v_registros.porcentaje_dias,
                  v_registros.compromete,
                  v_registros.id_oficina,
                  v_registros.id_lugar
                );


         END LOOP;

        -----------------------------
        --prorrateo de horas NOCTURNO
        -----------------------------
        FOR v_registros in (
                                 select
                                      pro.id_oficina,
                                      pro.id_lugar,
                                      pro.id_prorrateo,
                                      pro.porcentaje,
                                      pro.porcentaje_dias,
                                      cv.id_tipo_columna,
                                      cv.codigo_columna,
                                      tc.compromete
                                  from plani.tprorrateo pro
                                 -- inner join plani.thoras_trabajadas ht on pro.id_horas_trabajadas = ht.id_horas_trabajadas
                                  inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = pro.id_funcionario_planilla
                                  inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and tc.compromete = 'si'
                                  where fp.id_planilla = p_id_planilla
                                       and tc.codigo  in ('NOCTURNO')
                                       and pro.tipo_horario = 'nocturno'
                               ) LOOP

               INSERT INTO
                  plani.tprorrateo_columna
                (
                  id_usuario_reg,
                  fecha_reg,
                  estado_reg,
                  id_prorrateo,
                  id_tipo_columna,
                  codigo_columna,
                  porcentaje,
                  compromete,
                  id_oficina,
                  id_lugar
                )
                VALUES (
                  p_id_usuario,
                  now(),
                  'activo',
                  v_registros.id_prorrateo,
                  v_registros.id_tipo_columna,
                  v_registros.codigo_columna,
                   v_registros.porcentaje_dias,
                  v_registros.compromete,
                  v_registros.id_oficina,
                  v_registros.id_lugar
                );

         END LOOP;

    END IF;



    /*****************************************************************/
    --llenar prorrateo para columnas de tipo si_contable
    --solo para las planillas que tienen columnas si_contables

    if (exists(    select 1
                from plani.ttipo_columna tc
                where tc.id_tipo_planilla = v_planilla.id_tipo_planilla and tc.estado_reg = 'activo'
                    and tc.compromete = 'si_contable')) THEN


            --obtener el centro de costos administrativo para este depto de organigrama
            SELECT ps_id_centro_costo into v_id_pres_adm
            FROM conta.f_get_config_relacion_contable('CCDEPCON'::character
                 varying, v_id_gestion_contable, v_planilla.id_depto,NULL,'No existe presupuesto administrativo relacionado al departamento de RRHH');

            --si tiene horas trabajadas todo con horas trabajadas
            if (v_planilla.tipo_presu_cc = 'parametrizacion' and v_planilla.calculo_horas = 'si') then
                --se inserta el prorrrateo para todos los funcionarios

                  for v_registros in (select distinct on (fp.id_funcionario_planilla) fp.id_funcionario_planilla,
                                      ht.id_horas_trabajadas,car.id_oficina,car.id_lugar,tc.codigo as tipo_contrato
                                      from plani.tfuncionario_planilla fp
                                      inner join plani.thoras_trabajadas ht on ht.id_funcionario_planilla = fp.id_funcionario_planilla
                                      inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                                      inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                      inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
                                      where id_planilla = p_id_planilla
                                      order by fp.id_funcionario_planilla,ht.fecha_fin desc)loop

                           INSERT INTO
                            plani.tprorrateo
                          (
                            id_usuario_reg,
                            fecha_reg,
                            estado_reg,
                            id_funcionario_planilla,
                            id_horas_trabajadas,
                            id_presupuesto,
                            id_cc,
                            tipo_prorrateo,
                            porcentaje,
                            tipo_contrato,
                            id_oficina,
                            id_lugar
                          )
                          VALUES (
                            p_id_usuario,
                            now(),
                            'activo',
                            v_registros.id_funcionario_planilla,
                            v_registros.id_horas_trabajadas,
                            case when p_tipo_generacion = 'presupuestos' then
                              v_id_pres_adm
                            else
                              NULL
                            END,
                            case when p_tipo_generacion = 'costos' then
                              v_id_pres_adm
                            else
                              NULL
                            END,
                            p_tipo_generacion,
                            100,
                            v_registros.tipo_contrato,
                            v_registros.id_oficina,
                            v_registros.id_lugar
                          )returning id_prorrateo into v_id_prorrateo;

                          --por cada funcionario se inserta prorrateo columna
                          v_consulta = '    select fp.id_funcionario_planilla,cv.id_tipo_columna,cv.codigo_columna,tc.compromete
                                  from plani.thoras_trabajadas ht
                                  inner join plani.tfuncionario_planilla fp on fp.id_funcionario_planilla = ht.id_funcionario_planilla
                                  inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                  inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and
                                                                  tc.compromete = ''si_contable''
                                  where fp.id_funcionario_planilla = ' || v_registros.id_funcionario_planilla ||'
                                  group by fp.id_funcionario_planilla,cv.id_tipo_columna,cv.codigo_columna,tc.compromete';

                          for v_columnas in execute (v_consulta) loop

                                INSERT INTO
                                  plani.tprorrateo_columna
                                (
                                  id_usuario_reg,
                                  fecha_reg,
                                  estado_reg,
                                  id_prorrateo,
                                  id_tipo_columna,
                                  codigo_columna,
                                  porcentaje,
                                  compromete,
                                  id_oficina,
                                  id_lugar
                                )
                                VALUES (
                                  p_id_usuario,
                                  now(),
                                  'activo',
                                  v_id_prorrateo,
                                  v_columnas.id_tipo_columna,
                                  v_columnas.codigo_columna,
                                  100,
                                  v_columnas.compromete,
                                  v_registros.id_oficina,
                                  v_registros.id_lugar
                                );

                          end loop;

                  end loop;
            --#7 se agrega hoja_calculo para procesar columnas si_contable
            elsif (v_planilla.tipo_presu_cc in ('hoja_calculo','ultimo_activo_gestion','ultimo_activo_periodo', 'prorrateo_aguinaldo', 'retroactivo_sueldo' ,'retroactivo_asignaciones')) then
                --se inserta el prorrrateo para todos los funcionarios
                for v_registros in (select fp.id_funcionario_planilla,
                                    car.id_oficina,car.id_lugar,tc.codigo as tipo_contrato
                                    from plani.tfuncionario_planilla fp
                                    inner join orga.tuo_funcionario uofun on uofun.id_uo_funcionario = fp.id_uo_funcionario
                                    inner join orga.tcargo car on car.id_cargo = uofun.id_cargo
                                    inner join orga.ttipo_contrato tc on tc.id_tipo_contrato = car.id_tipo_contrato
                                    where id_planilla = p_id_planilla)loop


                         v_consulta = '    select cv.id_tipo_columna,cv.codigo_columna,tc.compromete
                                          from plani.tfuncionario_planilla fp
                                          inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                          inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna and
                                                                          tc.compromete = ''si_contable''
                                          where fp.id_funcionario_planilla = ' || v_registros.id_funcionario_planilla;

                         for v_columnas in execute (v_consulta) loop

                              --#7 recuperar el centro de costo de las columnas si_contable, des una relacion contable especifica  ,...CCCLMCTA
                              --  si no tiene se usa el cnetro de costo adminsitrativo

                              --obtener el centro de costos administrativo para este depto de organigrama
                              SELECT ps_id_centro_costo into v_id_cc_aux
                              FROM conta.f_get_config_relacion_contable('CCCLMCTA'::character
                                   varying, v_id_gestion_contable, v_columnas.id_tipo_columna,NULL,'No existe centro de costo relacionado a la columna');

                              INSERT INTO
                                    plani.tprorrateo
                                  (
                                    id_usuario_reg,
                                    fecha_reg,
                                    estado_reg,
                                    id_funcionario_planilla,
                                    id_horas_trabajadas,
                                    id_presupuesto,
                                    id_cc,
                                    tipo_prorrateo,
                                    porcentaje,
                                    id_oficina,
                                    tipo_contrato, --#7 se corrige el orden de las columnas
                                    id_lugar
                                  )
                                  VALUES (
                                    p_id_usuario,
                                    now(),
                                    'activo',
                                    v_registros.id_funcionario_planilla,
                                    NULL,
                                    case when p_tipo_generacion = 'presupuestos' then
                                      v_id_cc_aux
                                    else
                                      v_id_pres_adm
                                    END,
                                    case when p_tipo_generacion = 'costos' then
                                      v_id_cc_aux
                                    else
                                      v_id_pres_adm
                                    END,
                                    p_tipo_generacion,
                                    100,
                                    v_registros.id_oficina,
                                    v_registros.tipo_contrato,
                                    v_registros.id_lugar
                                  )returning id_prorrateo into v_id_prorrateo;




                            INSERT INTO
                              plani.tprorrateo_columna
                            (
                              id_usuario_reg,
                              fecha_reg,
                              estado_reg,
                              id_prorrateo,
                              id_tipo_columna,
                              codigo_columna,
                              porcentaje,
                              compromete,
                              id_oficina,
                              id_lugar
                            )
                            VALUES (
                              p_id_usuario,
                              now(),
                              'activo',
                              v_id_prorrateo,
                              v_columnas.id_tipo_columna,
                              v_columnas.codigo_columna,
                              100,
                              v_columnas.compromete,
                              v_registros.id_oficina,
                              v_registros.id_lugar
                            );
                        end loop;

                end loop;


            end if;

    end if;


    return 'exito';

EXCEPTION

    WHEN OTHERS THEN
        v_resp='';
        v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);-- || v_registros.desc_funcionario1);
        v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
        raise exception '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
PARALLEL UNSAFE
COST 100;