CREATE OR REPLACE FUNCTION plani.f_planilla_calcular (
  p_id_planilla integer,
  p_id_usuario integer,
  p_recalcular_desde integer = 0
)
RETURNS varchar AS
$body$
DECLARE
  v_planilla			record;
  v_resp	            varchar;
  v_nombre_funcion      text;
  v_mensaje_error       text;
  v_funcionarios		record;
  v_columnas			record;
  v_valor_generado		numeric;
  v_valor				numeric;
  v_res_text			varchar;
  v_recalcular			varchar;
BEGIN
	v_nombre_funcion = 'plani.f_planilla_calcular';
  	select pla.*,pe.fecha_ini, pe.fecha_fin,tp.recalcular_desde
    into v_planilla
    from plani.tplanilla pla
    left join param.tperiodo pe on pe.id_periodo = pla.id_periodo
    inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = pla.id_tipo_planilla
    where id_planilla = p_id_planilla;

    if (p_recalcular_desde = 0) then
    	v_recalcular = 'no';
    else
    	v_recalcular = 'si';
    end if;
    --raise exception '%',p_id_planilla;
    for v_funcionarios in (	select fp.*,cv.*,tc.tipo_descuento_bono, tc.orden, tc.finiquito,
        							tc.decimales_redondeo,tc.tipo_dato
    						from plani.tfuncionario_planilla fp
    						inner join plani.tcolumna_valor cv
                            	on cv.id_funcionario_planilla = fp.id_funcionario_planilla
        					inner join plani.ttipo_columna tc
                            	on tc.id_tipo_columna = cv.id_tipo_columna
                            where fp.id_planilla = p_id_planilla and tc.orden >= p_recalcular_desde
                            order by fp.id_funcionario,tc.orden asc
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

                ELSE

                	v_valor_generado = v_funcionarios.valor_generado;
                    v_valor = v_funcionarios.valor;
                end if;
            elsif (v_funcionarios.tipo_dato = 'formula') then
               	if (v_funcionarios.valor_generado = v_funcionarios.valor) then

                    v_valor_generado = plani.f_calcular_formula(v_funcionarios.id_funcionario_planilla,
                                                v_funcionarios.formula, v_planilla.fecha_ini, v_funcionarios.id_columna_valor,v_recalcular);
                    v_valor = v_valor_generado;

                ELSE
                	v_valor_generado = v_funcionarios.valor_generado;
                    v_valor = v_funcionarios.valor;
                end if;

            ELSE

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

    if (v_planilla.recalcular_desde is not null and p_recalcular_desde = 0) then

    	v_res_text = plani.f_planilla_calcular(p_id_planilla,p_id_usuario,v_planilla.recalcular_desde);
    end if;
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

ALTER FUNCTION plani.f_planilla_calcular (p_id_planilla integer, p_id_usuario integer, p_recalcular_desde integer)
  OWNER TO postgres;