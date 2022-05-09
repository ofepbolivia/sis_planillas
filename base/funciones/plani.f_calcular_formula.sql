CREATE OR REPLACE FUNCTION plani.f_calcular_formula (
  p_id_funcionario_planilla integer,
  p_formula varchar,
  p_fecha_ini date,
  p_id_columna_valor integer,
  p_recalcular varchar = 'no'::character varying
)
RETURNS numeric AS
$body$
/**************************************************************************
 PLANI
***************************************************************************
 SCRIPT:
 COMENTARIOS:
 AUTOR: Jaim Rivera (Kplian)
 DESCRIP: Calcula la fórmula que recibe como parametro
 PRECONDICION: todos los valores de las variables en la formula ya fueron calculados
 Fecha: 27/01/2014

*/
DECLARE
	v_resp	            varchar;
  	v_nombre_funcion      text;
  	v_mensaje_error       text;
	v_respuesta varchar;
	v_registros record;
	v_resultado numeric;
	v_existen_variables boolean;
	v_cantidad_variables integer;
	v_formula varchar;
	v_cod_columna varchar;
	v_cod_columna_limpio varchar;
    v_valor_columna numeric;
    v_tipo_columna	record;
    v_resultado_detalle	numeric;
    v_detalle			record;

    --franklin.espinoza 23/9/2019
    v_codigo_pla		varchar;
    v_fecha_fin			date;
    v_id_funcionario		integer;
    v_tipo_jubilado			varchar;
BEGIN
	v_nombre_funcion = 'plani.f_calcular_formula';
    -- iniciamos llave while
    v_existen_variables = true;
    v_cantidad_variables = 0;
    v_formula = p_formula;

    select tc.*, cv.codigo_columna
    into v_tipo_columna
    from plani.tcolumna_valor cv
    inner join plani.ttipo_columna tc
    	on tc.id_tipo_columna = cv.id_tipo_columna
    where cv.id_columna_valor = p_id_columna_valor;

    if (v_tipo_columna.tiene_detalle = 'si') then
    	v_resultado = 0;
    	FOR v_detalle in (	select ht.id_horas_trabajadas,cd.id_columna_detalle, cd.valor,cd.valor_generado
        					from plani.tcolumna_detalle cd
                            inner join plani.tcolumna_valor cv
                            	on cv.id_columna_valor = cd.id_columna_valor
                            inner join plani.thoras_trabajadas ht
                                	on ht.id_horas_trabajadas = cd.id_horas_trabajadas
                            where cv.id_columna_valor = p_id_columna_valor
                            order by ht.fecha_ini asc
                            ) loop

        	if (round(v_detalle.valor,2) = round(v_detalle.valor_generado,2)) then

                v_existen_variables = true;
            	v_formula = p_formula;
                while (v_existen_variables  = true) LOOP
                      v_cod_columna = NULL;
                      v_cod_columna_limpio = NULL;
                      --Obtenemos una variable dentro de la formula
                      v_cod_columna  =  substring(v_formula from '%#"#{%#}#"%' for '#');

                      --Si se encontró alguna variable
                      IF  v_cod_columna IS NOT NULL THEN
                          v_cantidad_variables = v_cantidad_variables+1;
                          --quitar las llaves de la variable
                          v_cod_columna_limpio= split_part(v_cod_columna,'{',2);
                          v_cod_columna_limpio= split_part( v_cod_columna_limpio,'}',1);
                          --validar que la columna esta en columna_valor

                          v_valor_columna = (plani.f_get_valor_parametro_valor(v_cod_columna_limpio, p_fecha_ini));
                          if (v_valor_columna is null) then
                              v_valor_columna = plani.f_get_valor_columna_detalle(v_cod_columna_limpio,v_detalle.id_horas_trabajadas);
                               --v_valor_columna = 1000;

                          end if;
                          -- v_valor_columna = 0;

                          if (v_valor_columna is null) then
                              raise exception 'No se encontro la columna %, definida en la formula : %',
                                              v_cod_columna_limpio,p_formula;
                          end if;


                          v_formula = replace( v_formula, v_cod_columna, COALESCE(v_valor_columna,0.00)::varchar);

                      ELSE
                          v_existen_variables := false;
                      END IF;
                  END LOOP;
                   -- evaluar formula si la cantidad de variables es > 0
                  IF v_cantidad_variables > 0 THEN

                      FOR v_registros in EXECUTE('SELECT ('|| v_formula||') as res') LOOP
                          v_resultado_detalle = coalesce(v_registros.res,0);
                      END LOOP;

                  ELSE
                      RAISE EXCEPTION  'La formula % no contiene variables',v_formula;
                  END IF;
                  update plani.tcolumna_detalle
                  set valor = v_resultado_detalle,
                  valor_generado = v_resultado_detalle
                  where id_columna_detalle = v_detalle.id_columna_detalle ;

                  --v_resultado = v_resultado + v_resultado_detalle;
                  --begin retroactivo 2019 (franklin.espinoza)
                  if v_tipo_columna.codigo_columna = 'AFP_SSO' then
                    select  case when afp.tipo_jubilado in ('jubilado_55','jubilado_65') then 'jubilado' else afp.tipo_jubilado end
                    into v_tipo_jubilado
                    from plani.tfuncionario_planilla tfp
                    inner join plani.tfuncionario_afp afp on afp.id_funcionario = tfp.id_funcionario
                    where  tfp.id_funcionario_planilla = p_id_funcionario_planilla and afp.fecha_ini < '01/12/2019'::date
                    order by afp.tipo_jubilado asc
                    limit 1;
                    if v_tipo_jubilado = 'jubilado' then
                    	v_resultado = 0;
                    else
                    	v_resultado = v_resultado + v_resultado_detalle;
                    end if;
                  else --end retroactivo 2019
                  	v_resultado = v_resultado + v_resultado_detalle;
                  end if;
              else

                  v_resultado = v_resultado + v_detalle.valor;
              end if;

        end loop;
    else

        while (v_existen_variables  =true) LOOP

            v_cod_columna = NULL;
            v_cod_columna_limpio = NULL;
            --Obtenemos una variable dentro de la formula
            v_cod_columna  =  substring(v_formula from '%#"#{%#}#"%' for '#');

            --Si se encontró alguna variable
            IF  v_cod_columna IS NOT NULL THEN
                v_cantidad_variables = v_cantidad_variables+1;
                --quitar las llaves de la variable
                v_cod_columna_limpio= split_part(v_cod_columna,'{',2);
                v_cod_columna_limpio= split_part( v_cod_columna_limpio,'}',1);
                --validar que la columna esta en columna_valor

                v_valor_columna = (plani.f_get_valor_parametro_valor(v_cod_columna_limpio, p_fecha_ini));
                if (v_valor_columna is null) then
                    v_valor_columna = plani.f_get_valor_columna_valor(v_cod_columna_limpio, p_id_funcionario_planilla);
                     --v_valor_columna = 1000;

                end if;
                -- v_valor_columna = 0;

                if (v_valor_columna is null) then
                    raise exception 'No se encontro la columna %, definida en la formula : %',
                                    v_cod_columna_limpio,p_formula;
                end if;


                v_formula = replace( v_formula, v_cod_columna, COALESCE(v_valor_columna,0.00)::varchar);

            ELSE
                v_existen_variables := false;
            END IF;
        END LOOP;

        -- evaluar formula si la cantidad de variables es > 0
        IF v_cantidad_variables > 0 and (v_tipo_columna.recalcular = 'no' or (v_tipo_columna.recalcular = 'si' and p_recalcular = 'si')) THEN

            FOR v_registros in EXECUTE('SELECT ('|| v_formula||') as res') LOOP
                --franklin.espinoza 23/9/2019
                if v_tipo_columna.codigo = 'IMPDET' then

                	  select ttp.codigo, tfp.id_funcionario
                    into v_codigo_pla, v_id_funcionario
                    from  plani.tcolumna_valor tcv
                    inner join plani.tfuncionario_planilla tfp on tfp.id_funcionario_planilla = tcv.id_funcionario_planilla
                    inner join plani.tplanilla tp on tp.id_planilla = tfp.id_planilla
                    inner join plani.ttipo_planilla ttp on ttp.id_tipo_planilla = tp.id_tipo_planilla
                    where tcv.id_columna_valor = p_id_columna_valor;

                    select coalesce(tuo.fecha_finalizacion,'31/12/9999'::date)
                    into v_fecha_fin
                    from orga.tuo_funcionario tuo
                    where tuo.id_uo_funcionario = orga.f_get_ultima_asignacion(v_id_funcionario);

                    if v_codigo_pla = 'PLAPRI' and  v_fecha_fin > '13/09/2019'::date then
                    	v_resultado = 0;
                    else
                    	v_resultado = coalesce(v_registros.res,0);
                    end if;

                else
                	v_resultado = coalesce(v_registros.res,0);
                end if;
                --v_resultado = coalesce(v_registros.res,0);
            END LOOP;

        ELSIF (v_tipo_columna.recalcular = 'si' and p_recalcular = 'no') then
        	v_resultado = 0;
        ELSE
            RAISE EXCEPTION  'La formula % no contiene variables',v_formula;
        END IF;
    END IF;
    --sueldos abril y mayo no contemplas otros ingresos - franklin.espinoza 29/04/2020
    /*if v_tipo_columna.codigo_columna = 'OTROSING_RCIVA' and date_part('month',p_fecha_ini)::integer in (4,5) then
    	v_resultado = 0;
    end if;*/
  	return v_resultado;
EXCEPTION

	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje','formula: '|| p_formula || '------' || v_formula || '-------' || SQLERRM);
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

ALTER FUNCTION plani.f_calcular_formula (p_id_funcionario_planilla integer, p_formula varchar, p_fecha_ini date, p_id_columna_valor integer, p_recalcular varchar)
  OWNER TO postgres;