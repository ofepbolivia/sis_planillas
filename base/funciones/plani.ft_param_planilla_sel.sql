CREATE OR REPLACE FUNCTION plani.ft_param_planilla_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Planillas
 FUNCION: 		plani.ft_param_planilla_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'plani.tparam_planilla'
 AUTOR: 		 (franklin.espinoza)
 FECHA:	        26-08-2019 20:06:59
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
#ISSUE				FECHA				AUTOR				DESCRIPCION
 #0				26-08-2019 20:06:59								Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'plani.tparam_planilla'
 #
 ***************************************************************************/

DECLARE

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;

BEGIN

	v_nombre_funcion = 'plani.ft_param_planilla_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'PLA_PARAMPLA_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		franklin.espinoza
 	#FECHA:		26-08-2019 20:06:59
	***********************************/

	if(p_transaccion='PLA_PARAMPLA_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						parampla.id_param_planilla,
						parampla.estado_reg,
						parampla.id_tipo_planilla,
						parampla.porcentaje_calculo,
						parampla.valor_promedio,
						parampla.porcentaje_menor_promedio,
						parampla.porcentaje_mayor_promedio,
						parampla.id_usuario_reg,
						parampla.fecha_reg,
						parampla.id_usuario_ai,
						parampla.usuario_ai,
						parampla.id_usuario_mod,
						parampla.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
            parampla.fecha_incremento,
            parampla.porcentaje_antiguedad,
            parampla.haber_basico_inc
						from plani.tparam_planilla parampla
						inner join segu.tusuario usu1 on usu1.id_usuario = parampla.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = parampla.id_usuario_mod
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'PLA_PARAMPLA_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		franklin.espinoza
 	#FECHA:		26-08-2019 20:06:59
	***********************************/

	elsif(p_transaccion='PLA_PARAMPLA_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_param_planilla)
					    from plani.tparam_planilla parampla
					    inner join segu.tusuario usu1 on usu1.id_usuario = parampla.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = parampla.id_usuario_mod
					    where ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

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