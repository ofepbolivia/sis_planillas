CREATE OR REPLACE FUNCTION plani.ft_horas_trabajadas_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Planillas
 FUNCION: 		plani.ft_horas_trabajadas_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'plani.thoras_trabajadas'
 AUTOR: 		 (admin)
 FECHA:	        26-01-2014 21:35:44
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

    v_fecha_inicio		date;
    v_fecha_final		date;

BEGIN

	v_nombre_funcion = 'plani.ft_horas_trabajadas_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'PLA_HORTRA_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin
 	#FECHA:		26-01-2014 21:35:44
	***********************************/

	if(p_transaccion='PLA_HORTRA_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						hortra.id_horas_trabajadas,
						hortra.id_funcionario_planilla,
						hortra.id_uo_funcionario,
						hortra.fecha_fin,
						hortra.horas_extras,
						hortra.horas_disponibilidad,
						hortra.horas_nocturnas,
						hortra.fecha_ini,
						hortra.tipo_contrato,
						hortra.estado_reg,
						hortra.horas_normales,
						hortra.sueldo,
						hortra.fecha_reg,
						hortra.id_usuario_reg,
						hortra.id_usuario_mod,
						hortra.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						fun.desc_funcionario1,
                        fun.ci
						from plani.thoras_trabajadas hortra
						inner join segu.tusuario usu1 on usu1.id_usuario = hortra.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = hortra.id_usuario_mod
						inner join plani.tfuncionario_planilla funplan on
							funplan.id_funcionario_planilla = hortra.id_funcionario_planilla
						inner join orga.vfuncionario fun on fun.id_funcionario = funplan.id_funcionario
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'PLA_HORTRA_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		26-01-2014 21:35:44
	***********************************/

	elsif(p_transaccion='PLA_HORTRA_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_horas_trabajadas)
					    from plani.thoras_trabajadas hortra
					    inner join segu.tusuario usu1 on usu1.id_usuario = hortra.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = hortra.id_usuario_mod
						inner join plani.tfuncionario_planilla funplan on
							funplan.id_funcionario_planilla = hortra.id_funcionario_planilla
						inner join orga.vfuncionario fun on fun.id_funcionario = funplan.id_funcionario
					    where ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
    /*********************************
        #TRANSACCION:  'PLA_BENEF_SUB_SEL'
        #DESCRIPCION:	Listado de pagos de Subsidios
        #AUTOR:		franklin.espinoza
        #FECHA:		20-11-2020 16:11:04
        ***********************************/
    elsif(p_transaccion='PLA_HORTRA_LIC')then

      begin


        v_fecha_inicio = ('01/01/'||v_parametros.gestion)::date;
        v_fecha_final  = ('31/12/'||v_parametros.gestion)::date;

        v_consulta = '
        	SELECT
            funcio.id_funcionario,
            funcio.id_persona,

            person.nombre_completo2 AS desc_person,
            tli.motivo::text nombre,
            tli.desde fecha_ini,
            tli.hasta fecha_fin
            FROM plani.tlicencia tli
            inner join orga.tfuncionario funcio on funcio.id_funcionario = tli.id_funcionario
            INNER JOIN segu.vpersona person ON person.id_persona=funcio.id_persona

            WHERE tli.estado_reg != ''Eliminado'' and tli.id_funcionario = '||v_parametros.id_funcionario||' and  ((tli.desde between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date) or (tli.hasta between '''||v_fecha_inicio||'''::date and '''||v_fecha_final||'''::date))';
		    --v_consulta = v_consulta || ' group by funcio.id_funcionario, desc_person';

        v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' OFFSET ' || v_parametros.puntero;
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

ALTER FUNCTION plani.ft_horas_trabajadas_sel (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
  OWNER TO postgres;