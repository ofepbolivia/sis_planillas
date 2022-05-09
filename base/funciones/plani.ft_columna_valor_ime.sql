CREATE OR REPLACE FUNCTION plani.ft_columna_valor_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Planillas
 FUNCION: 		plani.ft_columna_valor_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'plani.tcolumna_valor'
 AUTOR: 		 (admin)
 FECHA:	        27-01-2014 04:53:54
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_columna_valor	integer;
	v_estado_planilla		varchar;
    v_id_funcionario_planilla	integer;
    v_tipo_columna			record;

    /****************************** CALCULO COLUMNAS VALOR ******************************/
    v_funcionarios		    record;
    v_valor_generado		numeric;
    v_valor				    numeric;
    v_recalcular			varchar;
    v_planilla              record;
    /****************************** CALCULO COLUMNAS VALOR ******************************/

BEGIN

    v_nombre_funcion = 'plani.ft_columna_valor_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'PLA_COLVAL_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		27-01-2014 04:53:54
	***********************************/

	if(p_transaccion='PLA_COLVAL_INS')then

        begin
        	--Sentencia de la insercion
        	insert into plani.tcolumna_valor(
			id_tipo_columna,
			id_funcionario_planilla,
			codigo_columna,
			estado_reg,
			valor,
			valor_generado,
			formula,
			fecha_reg,
			id_usuario_reg,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.id_tipo_columna,
			v_parametros.id_funcionario_planilla,
			v_parametros.codigo_columna,
			'activo',
			v_parametros.valor,
			v_parametros.valor_generado,
			v_parametros.formula,
			now(),
			p_id_usuario,
			null,
			null

			)RETURNING id_columna_valor into v_id_columna_valor;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Columna Valor almacenado(a) con exito (id_columna_valor'||v_id_columna_valor||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_columna_valor',v_id_columna_valor::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'PLA_COLVAL_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		27-01-2014 04:53:54
	***********************************/

	elsif(p_transaccion='PLA_COLVAL_MOD')then

		begin
			select pla.estado
			into v_estado_planilla
			from plani.tfuncionario_planilla funplan
			inner join plani.tplanilla  pla on pla.id_planilla = funplan.id_planilla
			where  funplan.id_funcionario_planilla = v_parametros.id_funcionario_planilla;

            select tc.* into v_tipo_columna
            from plani.ttipo_columna tc
            where id_tipo_columna = v_parametros.id_tipo_columna;

            if (v_tipo_columna.tiene_detalle = 'si') then
            	raise exception 'La columna tiene detalle, no es posible modificar el valor de la columna directamente. Modifique el detalle';
            end if;

			/*if (v_estado_planilla != 'calculo_columnas')then
				raise exception 'No es posible modificar un valor para una planilla que no se encuentra en estado "calculo_columnas"';
			end if;*/

			--Sentencia de la modificacion
			update plani.tcolumna_valor set
			id_tipo_columna = v_parametros.id_tipo_columna,
			id_funcionario_planilla = v_parametros.id_funcionario_planilla,
			codigo_columna = v_parametros.codigo_columna,
			valor = v_parametros.valor,
			valor_generado = v_parametros.valor_generado,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario
			where id_columna_valor=v_parametros.id_columna_valor;

            /**************************************** CALCULO COLUMNAS VALOR ****************************************/

			/*select pla.*, per.fecha_ini, per.fecha_fin
			into v_planilla
			from plani.tfuncionario_planilla funplan
			inner join plani.tplanilla  pla on pla.id_planilla = funplan.id_planilla
			inner join param.tperiodo per on per.id_periodo = pla.id_periodo
			where  funplan.id_funcionario_planilla = v_parametros.id_funcionario_planilla;*/
            select pla.*, per.fecha_ini, per.fecha_fin, tpla.codigo
			into v_planilla
			from plani.tfuncionario_planilla funplan
			inner join plani.tplanilla  pla on pla.id_planilla = funplan.id_planilla
            inner join plani.ttipo_planilla tpla on tpla.id_tipo_planilla = pla.id_tipo_planilla
			left join param.tperiodo per on per.id_periodo = pla.id_periodo
			where  funplan.id_funcionario_planilla = v_parametros.id_funcionario_planilla;

          	v_recalcular = 'no';
			if v_planilla.codigo != 'PLAGUIN' then
              for v_funcionarios in (	select fp.*,cv.*,tc.tipo_descuento_bono, tc.orden, tc.finiquito,
                                      tc.decimales_redondeo,tc.tipo_dato
                              from plani.tfuncionario_planilla fp
                              inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                              inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                              where fp.id_planilla = v_planilla.id_planilla and tc.orden >= v_tipo_columna.orden and fp.id_funcionario_planilla = v_parametros.id_funcionario_planilla
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

                      --(franklin.espinoza)[13/07/2021]redondeo para el 13 % de facturas
                      if v_funcionarios.codigo_columna = 'IMPOFAC13' then
                          if (v_valor-trunc(v_valor)) >= 0.46 and (v_valor_generado-trunc(v_valor_generado)) >= 0.46 then
                              v_valor = ceiling(v_valor);
                              v_valor_generado = ceiling(v_valor_generado);
                          end if;
                      end if;
                      --(franklin.espinoza)[13/07/2021]redondeo para el 13 % de facturas

                      update plani.tcolumna_valor set
                          valor = round (v_valor, v_funcionarios.decimales_redondeo),
                          valor_generado = round (v_valor_generado, v_funcionarios.decimales_redondeo)
                      where id_columna_valor = v_funcionarios.id_columna_valor;
              end loop;
            else
            	for v_funcionarios in (	select fp.*,cv.*,tc.tipo_descuento_bono, tc.orden, tc.finiquito,
                                                tc.decimales_redondeo,tc.tipo_dato
                                        from plani.tfuncionario_planilla fp
                                        inner join plani.tcolumna_valor cv on cv.id_funcionario_planilla = fp.id_funcionario_planilla
                                        inner join plani.ttipo_columna tc on tc.id_tipo_columna = cv.id_tipo_columna
                                        where fp.id_planilla = v_planilla.id_planilla and tc.orden >= 0 and fp.id_funcionario_planilla = v_parametros.id_funcionario_planilla
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
            end if;
          /**************************************** CALCULO COLUMNAS VALOR ****************************************/

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Columna Valor modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_columna_valor',v_parametros.id_columna_valor::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

    /*********************************
 	#TRANSACCION:  'PLA_COLVALCSV_MOD'
 	#DESCRIPCION:	Modificacion columna valor csv
 	#AUTOR:		admin
 	#FECHA:		27-01-2014 04:53:54
	***********************************/

	elsif(p_transaccion='PLA_COLVALCSV_MOD')then

		begin
			select tc.* into v_tipo_columna
            from plani.ttipo_columna tc
            where id_tipo_columna = v_parametros.id_tipo_columna;

            if (v_tipo_columna.tiene_detalle = 'si') then
            	raise exception 'La columna tiene detalle, no es posible modificar el valor de la columna directamente. Modifique el detalle';
            end if;

             /*obtener id_empleado_planilla*/
            select fp.id_funcionario_planilla
            into v_id_funcionario_planilla
            from orga.vfuncionario f
            inner join plani.tfuncionario_planilla fp
            on fp.id_funcionario = f.id_funcionario and fp.id_planilla =  v_parametros.id_planilla
            where f.ci = v_parametros.ci;

            if (v_id_funcionario_planilla is null) then
            	raise exception 'No se encontro un empleado con documento nro: %, en la planilla', v_parametros.ci;
            end if;

            select pla.estado
			into v_estado_planilla
			from plani.tfuncionario_planilla funplan
			inner join plani.tplanilla  pla on pla.id_planilla = funplan.id_planilla
			where  funplan.id_funcionario_planilla = v_id_funcionario_planilla;

			if (v_estado_planilla != 'calculo_columnas')then
				raise exception 'No es posible modificar un valor para una planilla que no se encuentra en estado "calculo_columnas"';
			end if;

			--Sentencia de la modificacion
			update plani.tcolumna_valor set
			valor = v_parametros.valor
			where id_tipo_columna=v_parametros.id_tipo_columna and id_funcionario_planilla = v_id_funcionario_planilla;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Columna Valor modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_columna',v_parametros.id_tipo_columna::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'id_funcionario_planilla',v_id_funcionario_planilla::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'PLA_COLVAL_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		27-01-2014 04:53:54
	***********************************/

	elsif(p_transaccion='PLA_COLVAL_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from plani.tcolumna_valor
            where id_columna_valor=v_parametros.id_columna_valor;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Columna Valor eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_columna_valor',v_parametros.id_columna_valor::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	else

    	raise exception 'Transaccion inexistente: %',p_transaccion;

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

ALTER FUNCTION plani.ft_columna_valor_ime (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
  OWNER TO postgres;