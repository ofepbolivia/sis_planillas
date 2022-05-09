<?php
/**
*@package pXP
*@file gen-MODReporte.php
*@author  (admin)
*@date 17-01-2014 22:07:28
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODReporte extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarReporte(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REPO_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_reporte','int4');
		$this->captura('id_tipo_planilla','int4');
		$this->captura('numerar','varchar');
		$this->captura('hoja_posicion','varchar');
		$this->captura('mostrar_nombre','varchar');
		$this->captura('mostrar_codigo_empleado','varchar');
		$this->captura('mostrar_doc_id','varchar');
		$this->captura('mostrar_codigo_cargo','varchar');
		$this->captura('agrupar_por','varchar');
		$this->captura('ordenar_por','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('ancho_utilizado','int4');
		$this->captura('ancho_total','int4');
		$this->captura('titulo_reporte','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('control_reporte','varchar');
		$this->captura('tipo_reporte','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarReporte(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_reporte_ime';
		$this->transaccion='PLA_REPO_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_tipo_planilla','id_tipo_planilla','int4');
		$this->setParametro('numerar','numerar','varchar');
		$this->setParametro('hoja_posicion','hoja_posicion','varchar');
		$this->setParametro('mostrar_nombre','mostrar_nombre','varchar');
		$this->setParametro('mostrar_codigo_empleado','mostrar_codigo_empleado','varchar');
		$this->setParametro('mostrar_doc_id','mostrar_doc_id','varchar');
		$this->setParametro('mostrar_codigo_cargo','mostrar_codigo_cargo','varchar');
		$this->setParametro('agrupar_por','agrupar_por','varchar');
		$this->setParametro('ordenar_por','ordenar_por','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('ancho_utilizado','ancho_utilizado','int4');
		$this->setParametro('ancho_total','ancho_total','int4');
		$this->setParametro('titulo_reporte','titulo_reporte','varchar');
		$this->setParametro('control_reporte','control_reporte','varchar');
		$this->setParametro('tipo_reporte','tipo_reporte','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarReporte(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_reporte_ime';
		$this->transaccion='PLA_REPO_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_reporte','id_reporte','int4');
		$this->setParametro('id_tipo_planilla','id_tipo_planilla','int4');
		$this->setParametro('numerar','numerar','varchar');
		$this->setParametro('hoja_posicion','hoja_posicion','varchar');
		$this->setParametro('mostrar_nombre','mostrar_nombre','varchar');
		$this->setParametro('mostrar_codigo_empleado','mostrar_codigo_empleado','varchar');
		$this->setParametro('mostrar_doc_id','mostrar_doc_id','varchar');
		$this->setParametro('mostrar_codigo_cargo','mostrar_codigo_cargo','varchar');
		$this->setParametro('agrupar_por','agrupar_por','varchar');
		$this->setParametro('ordenar_por','ordenar_por','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('ancho_utilizado','ancho_utilizado','int4');
		$this->setParametro('ancho_total','ancho_total','int4');
		$this->setParametro('titulo_reporte','titulo_reporte','varchar');
		$this->setParametro('control_reporte','control_reporte','varchar');
		$this->setParametro('tipo_reporte','tipo_reporte','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarReporte(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_reporte_ime';
		$this->transaccion='PLA_REPO_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_reporte','id_reporte','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReporteMaestro(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REPOMAES_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
				
		//Datos del tipo de reporte
		$this->captura('numerar','varchar');
		$this->captura('hoja_posicion','varchar');
		$this->captura('mostrar_nombre','varchar');
		$this->captura('mostrar_codigo_empleado','varchar');
		$this->captura('mostrar_doc_id','varchar');
		$this->captura('mostrar_codigo_cargo','varchar');
		$this->captura('agrupar_por','varchar');
		$this->captura('ordenar_por','varchar');
		$this->captura('titulo_reporte','varchar');
		
		//Datos de la planilla
		$this->captura('nro_planilla','varchar');
		$this->captura('periodo','integer');
		$this->captura('gestion','integer');
		$this->captura('uo','varchar');
		$this->captura('depto','varchar');
		$this->captura('cantidad_columnas','integer');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReportePrevisiones(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REPOPREV_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);	
		
		$this->setParametro('id_tipo_contrato','id_tipo_contrato','varchar');
		$this->setParametro('id_uo','id_uo','int4');
		$this->setParametro('fecha','fecha','date');	
						
		//Datos del tipo de reporte
		$this->captura('gerencia','varchar');
		$this->captura('cargo','varchar');
		$this->captura('nombre','text');
		$this->captura('basico','numeric');
		$this->captura('fecha_ingreso','varchar');
		$this->captura('dias_trabajados','integer');
		$this->captura('indem_dia','numeric');
		$this->captura('indem','numeric');
        $this->captura('presupuesto','varchar');
		
		
		//Ejecuta la instruccion
		$this->armarConsulta();// echo $this->consulta;exit;
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReporteMaestroBoleta(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REPOMAESBOL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
		
		$this->setParametro('id_tipo_planilla','id_tipo_planilla','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');	
		$this->setParametro('id_uo','id_uo','int4');
		$this->setParametro('tipo_contrato','tipo_contrato','varchar');		
		//Datos del tipo de reporte
		
		$this->captura('titulo_reporte','varchar');
		
		//Datos de la planilla
		$this->captura('nro_planilla','varchar');
		$this->captura('periodo','varchar');
		$this->captura('gestion','integer');
		$this->captura('nit','varchar');
		$this->captura('nro_patronal','varchar');
		$this->captura('nombre','varchar');
		$this->captura('cargo','varchar');
		$this->captura('item','varchar');
		$this->captura('codigo_empleado','varchar');
		$this->captura('horas_trabajadas','integer');
		$this->captura('ci','varchar');
		$this->captura('id_funcionario','integer');
		
		
		//Ejecuta la instruccion
		$this->armarConsulta();		
	
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
	
	function listarReporteDetalle(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REPODET_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
		
		$this->setParametro('tipo_contrato','tipo_contrato','varchar');	
		$this->setParametro('id_uo','id_uo','integer');	
		//Datos del empleado
		$this->captura('id_funcionario','integer');
		$this->captura('nombre_empleado','text');
		$this->captura('codigo_empleado','varchar');
		$this->captura('codigo_cargo','varchar');
		$this->captura('doc_id','varchar');
		//$this->captura('id_presupuesto','integer');
		$this->captura('id_gerencia','integer');
		$this->captura('gerencia','varchar');
				
		//Datos del tipo_reporte_columna
		$this->captura('sumar_total','varchar');
		$this->captura('ancho_columna','integer');
		$this->captura('titulo_reporte_superior','varchar');	
		$this->captura('titulo_reporte_inferior','varchar');		
		
		//Datos de la columna
		$this->captura('codigo_columna','varchar');	
		$this->captura('valor_columna','numeric');			
		$this->captura('nombre','varchar');
		$this->captura('categoria_prog','varchar');
		//$this->captura('motivo_retiro','varchar');
		$this->captura('cargo','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();//echo $this->consulta; exit;
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReporteDetalleBoleta(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REPODETBOL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
		
		$this->setParametro('id_funcionario','id_funcionario','int4');	
		
		$this->captura('titulo_reporte_superior','varchar');	
		$this->captura('titulo_reporte_inferior','varchar');	
		$this->captura('tipo_columna','varchar');	
		
		//Datos de la columna
		$this->captura('codigo_columna','varchar');	
		$this->captura('valor_columna','numeric');			
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
	function ListarReportePlanillaActualizadaItem(){

        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='plani.ft_reporte_sel';
        $this->transaccion='PLA_REPOACIT_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion
        $this->setCount(false);
        //Datos de la planilla

        $this->setParametro('id_tipo_contrato','id_tipo_contrato','integer');
        $this->setParametro('id_uo','id_uo','integer');
        $this->setParametro('fecha','fecha','date');
        $this->setParametro('agrupar_por','agrupar_por','varchar');
        $this->setParametro('licencia','licencia','varchar');



        $this->captura('escala','varchar');
        $this->captura('cargo','varchar');
        $this->captura('nro_item','varchar');
        $this->captura('nombre_funcionario','text');
        $this->captura('genero','varchar');
        $this->captura('haber_basico','numeric');
        $this->captura('bono_antiguedad','numeric');
        $this->captura('bono_frontera','numeric');
        $this->captura('sumatoria','numeric');
        $this->captura('fecha_inicio','text');
        $this->captura('ci','varchar');
        $this->captura('expedicion','varchar');
        $this->captura('codigo','varchar');
        $this->captura('nombre','varchar');
        $this->captura('codigo_nombre_gerencia','varchar');
        $this->captura('nombre_unidad','varchar');
        $this->captura('id_tipo_contrato','integer');
        $this->captura('prioridad_gerencia','varchar');
        $this->captura('gerencia','varchar');
        $this->captura('prioridad_depto','varchar');
        $this->captura('departamento','varchar');
        $this->captura('categoria_programatica','varchar');
        $this->captura('fecha_finalizacion','varchar');
        $this->captura('tiempo_empresa','interval');
        //$this->captura('centro_costo','varchar');
        //$this->captura('categoria_codigo','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();
        

        //Devuelve la respuesta
        return $this->respuesta;


    }

    function reporteGeneralPlanilla(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='plani.ft_reporte_sel';
        $this->transaccion='PLA_REP_CONTACT_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        $this->setCount(false);
        $this->setParametro('oficina','oficina','varchar');


        //Definicion de la lista del resultado del query
        $this->captura('gerencia','varchar');
        $this->captura('contrato','varchar');
        $this->captura('desc_funcionario','varchar');
        $this->captura('cargo','varchar');
        $this->captura('lugar','varchar');
        $this->captura('codigo','varchar');
        $this->captura('email_empresa','varchar');
        $this->captura('correo','varchar');
        $this->captura('telefonos','varchar');
        $this->captura('celulares','varchar');
        $this->captura('documento','varchar');
        $this->captura('lugar_trabajo','varchar');
		$this->captura('nombre_oficina','varchar');


        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function reportePresupuestoCatProg(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='plani.ft_reporte_sel';
        $this->transaccion='PLA_REP_PRE_CP_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        $this->setCount(false);
        $this->setParametro('oficina','oficina','varchar');
        $this->setParametro('id_gestion','id_gestion','integer');
        $this->setParametro('estado','estado','varchar');

        //Definicion de la lista del resultado del query
        /*$this->captura('desc_fun','varchar');
        $this->captura('nombre_cargo','varchar');
        $this->captura('tipo_contrato','varchar');
        $this->captura('categoria_prog','varchar');
        $this->captura('codigo_pres','varchar');
        $this->captura('presupuesto','varchar');*/

        $this->captura('tipo_contrato','varchar');
        $this->captura('categoria_prog','varchar');
        $this->captura('codigo_pres','varchar');
        $this->captura('presupuesto','varchar');
        $this->captura('desc_func','varchar');
        $this->captura('ci','varchar');
        $this->captura('nombre_cargo','varchar');
        $this->captura('fecha_ini','date');
        $this->captura('fecha_fin','date');

        $this->captura('periodo','varchar');
        $this->captura('codigo_columna','varchar');
        $this->captura('valor','numeric');
		$this->captura('modalidad','varchar');



        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }
    //Reporte Aguinaldo v2018 (franklin espinoza)
    function reporteAguinaldo(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='plani.ft_reporte_sel';
        $this->transaccion='PLA_REP_AGUI_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        $this->setCount(false);
		$this->setParametro('modalidad','modalidad','varchar');
		$this->setParametro('id_gestion','id_gestion','integer');

        //Definicion de la lista del resultado del query
		$this->captura('id_funcionario','integer');
		$this->captura('codigo_empleado','varchar');
		$this->captura('nombre_empleado','varchar');

		$this->captura('descripcion','varchar');
		$this->captura('codigo_cargo','varchar');
		$this->captura('doc_id','varchar');
		$this->captura('id_uo','integer');
		$this->captura('gerencia','varchar');
		$this->captura('categoria_prog','varchar');

		//Datos del tipo_reporte_columna
		$this->captura('sumar_total','varchar');
		$this->captura('ancho_columna','integer');
		$this->captura('titulo_reporte_superior','varchar');
		$this->captura('titulo_reporte_inferior','varchar');

		//Datos de la columna
		$this->captura('codigo_columna','varchar');
		$this->captura('valor_columna','numeric');
		//$this->captura('afp','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    //subir archivo con codigo RC-IVA
	function uploadCsvCodigosRCIVA(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_ime';
		$this->transaccion='PLA_REP_RCIVA_IME';
		$this->tipo_procedimiento='IME';//tipo de transaccion
		//var_dump($this->aParam->getParametro('registros'));exit;
		$this->setParametro('registros','registros','jsonb');
		//Ejecuta la instruccion
		$this->armarConsulta();//var_dump($this->consulta);exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//Reporte RC-IVA (franklin espinoza)
	function reporteRCIVA(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REP_RCIVA_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setCount(false);
		$this->setParametro('id_gestion','id_gestion','integer');
		$this->setParametro('id_periodo','id_periodo','integer');
		//Definicion de la lista del resultado del query
		$this->captura('gestion','integer');
		$this->captura('periodo','integer');
		$this->captura('codigo_rc_iva','varchar');
		$this->captura('nombre','varchar');
		$this->captura('apellido_paterno','varchar');
		$this->captura('apellido_materno','varchar');
		$this->captura('numero_documento','varchar');
		$this->captura('tipo_documento','varchar');
		$this->captura('ingreso_neto','numeric');
		$this->captura('dos_salario_minimo','numeric');
		$this->captura('base_imponible','numeric');
		$this->captura('impuesto_rc_iva','numeric');
		$this->captura('trece_dos_salario_minimo','numeric');
		$this->captura('trece_facturas','numeric');
		$this->captura('saldo_per_anterior','numeric');
		$this->captura('mantenimiento_valor','numeric');
		$this->captura('novedades','char');
		$this->captura('cotizable','numeric');
		$this->captura('refrigerio','numeric');
		$this->captura('viatico','numeric');
		$this->captura('prima','numeric');
		$this->captura('es_frontera','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo($this->consulta);exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//franklin.espinoza Otros Ingresos Planilla
	function reporteOtrosIngresos(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_R_OTROS_ING_SEL';
		$this->tipo_procedimiento='SEL';

		$this->setParametro('id_proceso_wf','id_proceso_wf','integer');
		//Define los parametros para la funcion
		$this->setCount(false);
		//Definicion de la lista del resultado del query
		$this->captura('nombre_empleado','varchar');
		$this->captura('ci','varchar');
		$this->captura('monto','numeric');
		$this->captura('gerencia','varchar');
		$this->captura('categoria_prog','varchar');
		$this->captura('refrigerio','numeric');//monto2
		$this->captura('viatico','numeric');//monto3
		$this->captura('refri_sep','numeric');//monto3
		$this->captura('fecha_ini','date');//monto3
		$this->captura('fecha_fin','date');//monto3

		/*$this->captura('monto4','numeric');
		$this->captura('monto5','numeric');
		$this->captura('monto6','numeric');
		$this->captura('monto7','numeric');

		$this->captura('periodo','integer');
		$this->captura('sueldo_abril','numeric');
		$this->captura('refrigerio_abril','numeric');
		$this->captura('viatico_abril','numeric');
		$this->captura('sueldo_mayo','numeric');
		$this->captura('refrigerio_mayo','numeric');
		$this->captura('viatico_mayo','numeric');
		$this->captura('refrigerio_junio','numeric');
		$this->captura('viatico_junio','numeric');*/

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo($this->consulta);exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//franklin.espinoza Otros Ingresos Formulario
	function reporteOtrosIngresosRCIVA(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_R_OTING_FORM_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setCount(false);
		$this->setParametro('id_gestion','id_gestion','integer');
		$this->setParametro('id_periodo','id_periodo','integer');
		$this->setParametro('modalidad','modalidad','varchar');
		//Definicion de la lista del resultado del query
		$this->captura('nombre_empleado','varchar');
		$this->captura('ci','varchar');
		$this->captura('gerencia','varchar');
		$this->captura('categoria_prog','varchar');
		$this->captura('otros_ingresos','varchar');


		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo($this->consulta);exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//{'desarrollador':'franklin.espinoza', 'fecha':'29/02/2020'}
	function reportePlanillaPresupuestariaItems(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_PRESUPUESTO_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setCount(false);

		$this->setParametro('fecha','fecha','date');

		//Definicion de la lista del resultado del query
		$this->captura('programa','varchar');
		$this->captura('entidad','varchar');
		$this->captura('dir_admin','varchar');
		$this->captura('objeto_gasto','varchar');
		$this->captura('actividad','varchar');
		$this->captura('fuente','varchar');
		$this->captura('organismo','varchar');
		$this->captura('ue','varchar');
		$this->captura('item','varchar');
		$this->captura('cargo','varchar');
		$this->captura('haber_basico','numeric');
		$this->captura('costo_anual','numeric');
		$this->captura('gestion','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo($this->consulta);exit;
		$this->ejecutarConsulta();
		//Devuelve la respuesta
		return $this->respuesta;
	}

	//(franklin.espinoza)01/05/2020 listar Otros Ingresos Funcionario Categoria
	function listarOtrosIngresosCategoria(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_reporte_sel';// nombre procedimiento almacenado
		$this->transaccion='PLA_OTROING_CAT_SEL';//nombre de la transaccion
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//$this->setCount(true);

		$this->capturaCount('tot_refrigerio','numeric');
		$this->capturaCount('tot_viatico_adm','numeric');
		$this->capturaCount('tot_viatico_amp','numeric');
		$this->capturaCount('tot_viatico_ope','numeric');
		$this->capturaCount('tot_total_viatico','numeric');
		$this->capturaCount('tot_prima','numeric');
		$this->capturaCount('tot_retroactivo','numeric');

		$this->setParametro('gestion','gestion','varchar');
		$this->setParametro('periodo','periodo','varchar');
		$this->setParametro('categoria','categoria','varchar');
		//$this->setParametro('tipo','tipo','varchar');

		//defino varialbes que se capturan como retorno de la funcion

		$this->captura('id_persona','integer');
		$this->captura('id_funcionario','integer');
		$this->captura('desc_person','text');

		$this->captura('refrigerio','numeric');
		$this->captura('viatico_adm','numeric');
		$this->captura('viatico_amp','numeric');
		$this->captura('viatico_ope','numeric');
		$this->captura('total_viatico','numeric');
		$this->captura('c31','varchar');
		$this->captura('ci','varchar');
		$this->captura('cargo','varchar');
		$this->captura('contrato','varchar');
		$this->captura('estado','varchar');
		$this->captura('prima','numeric');
		$this->captura('retroactivo','numeric');
		//$this->captura('ref_sep','numeric');


		//Ejecuta la funcion
		$this->armarConsulta();

		//var_dump($this->getConsulta()); exit;
		$this->ejecutarConsulta();
		return $this->respuesta;
	}

	/**(franklin.espinoza)24/04/2021 Listar Planilla Actualizada de Items**/
	function listarPlanillaItems(){

		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_reporte_sel';
		$this->transaccion='PLA_REP_UOITEMS_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
		//Datos de la planilla

		$this->setParametro('id_tipo_contrato','id_tipo_contrato','integer');
		$this->setParametro('id_uo','id_uo','integer');
		$this->setParametro('fecha','fecha','date');
		$this->setParametro('agrupar_por','agrupar_por','varchar');
		$this->setParametro('licencia','licencia','varchar');

		$this->captura('escala','varchar');
		$this->captura('cargo','varchar');
		$this->captura('nro_item','varchar');
		$this->captura('nombre_funcionario','varchar');
		$this->captura('genero','varchar');
		$this->captura('haber_basico','numeric');
		$this->captura('bono_antiguedad','numeric');
		$this->captura('bono_frontera','numeric');
		$this->captura('sumatoria','numeric');
		$this->captura('fecha_inicio','varchar');
		$this->captura('ci','varchar');
		$this->captura('expedicion','varchar');
		$this->captura('codigo','varchar');
		$this->captura('nombre','varchar');
		$this->captura('codigo_nombre_gerencia','varchar');
		$this->captura('nombre_unidad','varchar');
		$this->captura('id_tipo_contrato','integer');
		$this->captura('gerencia','varchar');
		$this->captura('departamento','varchar');
		$this->captura('categoria_programatica','varchar');
		$this->captura('fecha_finalizacion','varchar');
		$this->captura('correlativo','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();
		//Devuelve la respuesta
		return $this->respuesta;
	}
	/**(franklin.espinoza)24/04/2021 Listar Planilla Actualizada de Items**/
}
?>
