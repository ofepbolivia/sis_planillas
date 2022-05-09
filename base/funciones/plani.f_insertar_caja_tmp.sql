CREATE OR REPLACE FUNCTION plani.f_insertar_caja_tmp (
)
RETURNS boolean AS
$body$
DECLARE

	v_nombre_funcion		text;
    v_resp					varchar;
   	v_resultado 			numeric;
   	v_consulta  			varchar;
	v_fisico				numeric;
    v_detalle				record;
    v_existen_variables		boolean;
    v_formula				varchar;
    v_cod_columna 			varchar;
	v_cod_columna_limpio 	varchar;
    v_cantidad_variables 	integer;
    v_valor_columna 		numeric;

    v_resultado_detalle		numeric;
    v_registros				record;
    v_retroactivo			record;
BEGIN

	 v_nombre_funcion = 'plani.f_insertar_caja_tmp';
     v_existen_variables = true;
     v_cantidad_variables = 0;



     	v_resultado = 0;
        for v_retroactivo in 	select tp.id_usuario_reg, tcv.id_funcionario_planilla, tfp.id_funcionario, tp.id_gestion, tcv.id_columna_valor
                        		from plani.tplanilla tp
                        		inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla
                        		inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = 'CAJSAL'
                        		where tp.id_planilla = 528 loop

          raise notice  'v_retroactivo: %', v_retroactivo;
          FOR v_detalle in 	select ht.id_horas_trabajadas,cd.id_columna_detalle, cd.valor,cd.valor_generado
                              from plani.tcolumna_detalle cd
                              inner join plani.tcolumna_valor cv on cv.id_columna_valor = cd.id_columna_valor
                              inner join plani.thoras_trabajadas ht on ht.id_horas_trabajadas = cd.id_horas_trabajadas
                              where cv.id_columna_valor = v_retroactivo.id_columna_valor loop
                    raise notice  'v_detalle: %', v_detalle;
          	--raise exception 'llega';
              if (round(v_detalle.valor,2) = round(v_detalle.valor_generado,2)) then

                  v_existen_variables = true;
                  v_formula = '{COTIZABLE}*0.1';
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

                            v_valor_columna = (plani.f_get_valor_parametro_valor(v_cod_columna_limpio, null));
                            if (v_valor_columna is null) then
                                v_valor_columna = plani.f_get_valor_columna_detalle(v_cod_columna_limpio,v_detalle.id_horas_trabajadas);
                                 --v_valor_columna = 1000;

                            end if;
                            -- v_valor_columna = 0;

                            if (v_valor_columna is null) then
                                raise exception 'No se encontro la columna %, definida en la formula : %',
                                                v_cod_columna_limpio,v_formula;
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
                    update plani.tcolumna_detalle set
                    	valor = v_resultado_detalle,
                    	valor_generado = v_resultado_detalle
                    where id_columna_detalle = v_detalle.id_columna_detalle ;
                    v_resultado = v_resultado + v_resultado_detalle;
                else

                    v_resultado = v_resultado + v_detalle.valor;
                end if;

          end loop;
		end loop;

	return true;

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