CREATE OR REPLACE FUNCTION plani.f_regularizar_caja_tmp (
)
RETURNS boolean AS
$body$
DECLARE

	v_nombre_funcion	text;
    v_resp				varchar;
   	v_resultado 		record;
   	v_consulta  		varchar;
	v_fisico			numeric;
    v_detalle			record;
BEGIN

	 v_nombre_funcion = 'plani.f_regularizar_caja_tmp';




     for v_resultado in select tp.id_usuario_reg, tcv.id_funcionario_planilla, tfp.id_funcionario, tp.id_gestion, tcv.id_columna_valor
                        from plani.tplanilla tp
                        inner join plani.tfuncionario_planilla tfp on tfp.id_planilla = tp.id_planilla
                        inner join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfp.id_funcionario_planilla and tcv.codigo_columna = 'CAJSAL'
                        where tp.id_planilla = 528 loop



         raise notice 'v_resultado: %', v_resultado;
         for v_detalle in (
                            select ht.id_horas_trabajadas
                            from plani.tplanilla p
                            inner join plani.ttipo_planilla tp on tp.id_tipo_planilla = p.id_tipo_planilla
                            inner join plani.tfuncionario_planilla fp on fp.id_planilla = p.id_planilla
                            inner join plani.thoras_trabajadas ht on ht.id_funcionario_planilla = fp.id_funcionario_planilla
                            inner join param.tperiodo tper on tper.id_periodo = p.id_periodo
                            where fp.id_funcionario = v_resultado.id_funcionario and  tp.codigo = 'PLASUE' and
                            ht.estado_reg = 'activo' and p.id_gestion = v_resultado.id_gestion and tper.periodo <= 7) loop

            INSERT INTO
                plani.tcolumna_detalle
              (
                id_usuario_reg,
                id_horas_trabajadas,
                id_columna_valor,
                valor,
                valor_generado
              )
              VALUES (
                v_resultado.id_usuario_reg,
                v_detalle.id_horas_trabajadas,
                v_resultado.id_columna_valor,
                0,
                0
              );

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