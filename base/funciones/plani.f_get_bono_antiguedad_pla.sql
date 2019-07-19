CREATE OR REPLACE FUNCTION plani.f_get_bono_antiguedad_pla (
  p_id_funcionario integer,
  p_fecha date
)
RETURNS integer AS
$body$
/**************************************************************************
 SISTEMA:		Sistema Planillas
 FUNCION: 		plani.f_get_bono_antiguedad_pla
 DESCRIPCION:   Funcion que retorna el bono antiguedad de un funcionario.
 AUTOR: 		(franklin.espinoza)
 FECHA:	        09-01-2019 15:15:26
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/

DECLARE

	v_resp		            varchar='';
	v_nombre_funcion        text;
	v_bono_antiguedad		integer;
    v_id_gestion			integer;
	v_id_periodo			integer;
    v_fecha					date;
    v_anteguedad			integer=0;
BEGIN
	v_nombre_funcion = 'plani.f_get_bono_antiguedad_pla';

	v_fecha = p_fecha - interval '1 month';

    if p_id_funcionario is not null or p_id_funcionario != 0 then
      select tg.id_gestion
      into v_id_gestion
      from param.tgestion tg
      where tg.gestion = date_part('year',v_fecha);

      select tp.id_periodo
      into v_id_periodo
      from param.tperiodo tp
      where tp.periodo = date_part('month',v_fecha) and tp.id_gestion = v_id_gestion;


      select tcv.valor
      into v_bono_antiguedad
      from plani.tplanilla tpl
      left join plani.tfuncionario_planilla tfpl on tfpl.id_funcionario = p_id_funcionario and tfpl.id_planilla = tpl.id_planilla
      left join plani.tcolumna_valor tcv on tcv.id_funcionario_planilla = tfpl.id_funcionario_planilla and tcv.codigo_columna = 'BONANT'
      where tpl.id_gestion = v_id_gestion and tpl.id_periodo = v_id_periodo and tpl.nro_planilla like '%PLASUE%';

      if v_bono_antiguedad is not null then
	  	v_anteguedad = v_bono_antiguedad;
      else
      	v_anteguedad = 0;
      end if;
    else
    	v_anteguedad = 0;
    end if;

return v_anteguedad;

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