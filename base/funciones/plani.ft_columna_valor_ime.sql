-- FUNCTION: plani.ft_columna_valor_ime(integer, integer, character varying, character varying)

-- DROP FUNCTION plani.ft_columna_valor_ime(integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION plani.ft_columna_valor_ime(
	p_administrador integer,
	p_id_usuario integer,
	p_tabla character varying,
	p_transaccion character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
/**************************************************************************
 SISTEMA:        Sistema de Planillas
 FUNCION:         plani.ft_columna_valor_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'plani.tcolumna_valor'
 AUTOR:          (admin)
 FECHA:            27-01-2014 04:53:54
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
       
 ISSUE            FECHA:              AUTOR                 DESCRIPCION
   
 #0               17-01-2014        JRR KPLIAN       creacion
 #10              04/06/2019        RAC KPLIAN       valida si la coluna es editable o no previamente a la edicion
 #19              04/07/2019        RAC KPLIAN       Cambiar  importación de CSV para columnas variable según  código de empleado en vez de Carnet de identidad 
 #21              17/07/2019        RAC              Reomver prefijo de codigo de  empleado al importar CSV  de manera configurable
 #31              02/09/2019        RAC              coregir bug con nombre de variable al procesar importancion por codigo v_plani_csv_imp_pref_codemp
 #132             01/06/2020        MZM KPLIAN       Adicion de procedimiento para reseteo de valores (columnas variables)
***************************************************************************/

DECLARE

    v_nro_requerimiento            integer;
    v_parametros                   record;
    v_id_requerimiento             integer;
    v_resp                         varchar;
    v_nombre_funcion               text;
    v_mensaje_error                text;
    v_id_columna_valor             integer;
    v_estado_planilla              varchar;
    v_id_funcionario_planilla      integer;
    v_tipo_columna                 record;
    v_plani_csv_imp_columna        varchar; --#19
    v_plani_csv_imp_pref_codemp    varchar; --#21

BEGIN

    v_nombre_funcion = 'plani.ft_columna_valor_ime';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'PLA_COLVAL_INS'
     #DESCRIPCION:    Insercion de registros
     #AUTOR:        admin
     #FECHA:        27-01-2014 04:53:54
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
     #DESCRIPCION:    Modificacion de registros
     #AUTOR:        admin
     #FECHA:        27-01-2014 04:53:54
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
            
            --#10 se descomenta este bloque, esta validacion me parece correcta, añade calculo horas            
            if (v_estado_planilla not in ('calculo_columnas','calculo_horas')) then
                raise exception 'No es posible modificar un valor para una planilla que no se encuentra en estado calculo_columnas';
            end if;
            
            -- #10 valida si la columna es editable
           IF v_tipo_columna.editable = 'no' THEN
              raise exception 'La columna % no es editable ',v_tipo_columna.nombre; 
           END IF;

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

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Columna Valor modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_columna_valor',v_parametros.id_columna_valor::varchar);

            --Devuelve la respuesta
            return v_resp;

        end;

    /*********************************
     #TRANSACCION:  'PLA_COLVALCSV_MOD'
     #DESCRIPCION:    Modificacion columna valor csv
     #AUTOR:        admin
     #FECHA:        27-01-2014 04:53:54
    ***********************************/

    elsif(p_transaccion='PLA_COLVALCSV_MOD')then

        begin
            select tc.* into v_tipo_columna
            from plani.ttipo_columna tc
            where id_tipo_columna = v_parametros.id_tipo_columna;

            if (v_tipo_columna.tiene_detalle = 'si') then
                raise exception 'La columna tiene detalle, no es posible modificar el valor de la columna directamente. Modifique el detalle';
            end if;
            
            
            -- #19 recuperar de variable global si archivos CSV importa segun CI o segun codigo de empleado
            v_plani_csv_imp_columna = pxp.f_get_variable_global('plani_csv_imp_columna');

             /*obtener id_empleado_planilla*/
            --#19 es configurable si los archivos excel vienen con el CI del funcionario o con su cdigo empleado
            IF v_plani_csv_imp_columna = 'CI' THEN
                select fp.id_funcionario_planilla
                into v_id_funcionario_planilla
                from orga.vfuncionario f
                inner join plani.tfuncionario_planilla fp
                on fp.id_funcionario = f.id_funcionario and fp.id_planilla =  v_parametros.id_planilla
                where f.ci = v_parametros.ci;
            
                          
            ELSE
                --#21 recupera configuracion de prefijos de codigo de empleado
                v_plani_csv_imp_pref_codemp = pxp.f_get_variable_global('plani_csv_imp_pref_codemp');
               
                select fp.id_funcionario_planilla
                into v_id_funcionario_planilla
                from orga.vfuncionario f
                inner join plani.tfuncionario_planilla fp
                on fp.id_funcionario = f.id_funcionario and fp.id_planilla =  v_parametros.id_planilla
                where v_parametros.ci =  trim(both  v_plani_csv_imp_pref_codemp from  f.codigo); -- busca por codigo empelado , #21 remueve al principio y final el patron configurado en  v_plani_csv_imp_columna, #31 corrige bug en nombre de variable
            
            END IF;

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
     #DESCRIPCION:    Eliminacion de registros
     #AUTOR:        admin
     #FECHA:        27-01-2014 04:53:54
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
    elsif(p_transaccion='PLA_COLVALRES_MOD')then --#132
       begin
          update plani.tcolumna_valor 
          set valor=0
          where id_tipo_columna=v_parametros.id_tipo_col
          and id_funcionario_planilla in (select id_funcionario_planilla from plani.tfuncionario_planilla
          where id_planilla=v_parametros.id_planilla);
          
          v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Columna Valor reseteado(a)');
          v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_columna',v_parametros.id_tipo_col::varchar);


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
$BODY$;

ALTER FUNCTION plani.ft_columna_valor_ime(integer, integer, character varying, character varying)
    OWNER TO postgres;