<?php
/**
*@package pXP
*@file gen-MODFuncionarioPlanilla.php
*@author  (admin)
*@date 22-01-2014 16:11:08
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODFuncionarioPlanilla extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarFuncionarioPlanilla(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_funcionario_planilla_sel';
		$this->transaccion='PLA_FUNPLAN_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_funcionario_planilla','int4');
		$this->captura('finiquito','varchar');
		$this->captura('forzar_cheque','varchar');
		$this->captura('id_funcionario','int4');
		$this->captura('id_planilla','int4');
		$this->captura('id_lugar','int4');
		$this->captura('id_uo_funcionario','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('desc_funcionario2','text');
		$this->captura('lugar','varchar');
		$this->captura('afp','varchar');
		$this->captura('nro_afp','varchar');
		$this->captura('banco','varchar');
		$this->captura('nro_cuenta','varchar');
		$this->captura('ci','varchar');
		$this->captura('desc_cargo','varchar');
		$this->captura('tipo_contrato','varchar');

		$this->captura('centro_costo','varchar');
		$this->captura('categoria','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarFuncionarioPlanilla(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_funcionario_planilla_ime';
		$this->transaccion='PLA_FUNPLAN_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('finiquito','finiquito','varchar');
		$this->setParametro('forzar_cheque','forzar_cheque','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_planilla','id_planilla','int4');
		$this->setParametro('id_lugar','id_lugar','int4');
		$this->setParametro('id_uo_funcionario','id_uo_funcionario','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
        $this->setParametro('tipo_contrato','tipo_contrato','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarFuncionarioPlanilla(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_funcionario_planilla_ime';
		$this->transaccion='PLA_FUNPLAN_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_funcionario_planilla','id_funcionario_planilla','int4');
		$this->setParametro('finiquito','finiquito','varchar');
		$this->setParametro('forzar_cheque','forzar_cheque','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_planilla','id_planilla','int4');
		$this->setParametro('id_lugar','id_lugar','int4');
		$this->setParametro('id_uo_funcionario','id_uo_funcionario','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarFuncionarioPlanilla(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_funcionario_planilla_ime';
		$this->transaccion='PLA_FUNPLAN_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_funcionario_planilla','id_funcionario_planilla','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReporteAltasPeriodo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_funcionario_planilla_sel';
		$this->transaccion='PLA_ALTPER_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		$this->setParametro('id_periodo','id_periodo','int4');
		$this->setParametro('id_gestion','id_gestion','int4');
				
		//Definicion de la lista del resultado del query
		$this->captura('nombre_unidad','varchar');
		$this->captura('cargo','varchar');
		$this->captura('haber_basico','numeric');
		$this->captura('tipo_contrato','varchar');
		$this->captura('codigo_cc','text');
		$this->captura('funcionario','text');
		$this->captura('fecha_inicio','date');
		$this->captura('item','varchar');
		$this->captura('certificacion','varchar');
				
		//Ejecuta la instruccion
		$this->armarConsulta();
		
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReporteBajasPeriodo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_funcionario_planilla_sel';
		$this->transaccion='PLA_BAJPER_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		$this->setParametro('id_periodo','id_periodo','int4');
		$this->setParametro('id_gestion','id_gestion','int4');
				
		//Definicion de la lista del resultado del query
		$this->captura('nombre_unidad','varchar');
		$this->captura('cargo','varchar');
		$this->captura('haber_basico','numeric');
		$this->captura('tipo_contrato','varchar');
		$this->captura('codigo_cc','text');
		$this->captura('funcionario','text');
		$this->captura('fecha_fin','date');
		$this->captura('item','varchar');
		
				
		//Ejecuta la instruccion
		$this->armarConsulta();
		
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
	
	function listarReporteMovimientosPeriodo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_funcionario_planilla_sel';
		$this->transaccion='PLA_MOVPER_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		$this->setParametro('id_periodo','id_periodo','int4');
		$this->setParametro('id_gestion','id_gestion','int4');
				
		//Definicion de la lista del resultado del query
		$this->captura('funcionario','text');
		$this->captura('fecha_movimiento','date');
		$this->captura('gerencia_anterior','varchar');
		$this->captura('cargo_anterior','varchar');
		$this->captura('tipo_contrato_anterior','varchar');
		$this->captura('presupuesto_anterior','text');
		$this->captura('haber_basico_anterior','numeric');
		$this->captura('gerencia_actual','varchar');
		$this->captura('cargo_actual','varchar');
		$this->captura('tipo_contrato_actual','varchar');
		$this->captura('presupuesto_actual','text');
		$this->captura('haber_basico_actual','numeric');
		$this->captura('item','varchar');
		$this->captura('certificacion','varchar');
		
		
		
				
		//Ejecuta la instruccion
		$this->armarConsulta();
		
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
	function listarReporteAntiguedadPeriodo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_funcionario_planilla_sel';
		$this->transaccion='PLA_ANTIPER_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		$this->setParametro('id_periodo','id_periodo','int4');
		$this->setParametro('id_gestion','id_gestion','int4');
				
		//Definicion de la lista del resultado del query
		$this->captura('antiguedad','varchar');
		$this->captura('nombre_unidad','varchar');
		$this->captura('cargo','varchar');
		$this->captura('tipo_contrato','varchar');
		$this->captura('codigo_cc','text');			
		$this->captura('funcionario','text');
		$this->captura('fecha_inicio','date');
		$this->captura('fecha_antiguedad','date');
		
				
		//Ejecuta la instruccion
		$this->armarConsulta();
		
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

    //(franklin.espinoza)20/11/2020 listar Beneficiario Subsidio
    function listarBeneficiariosSubsidio(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='plani.ft_funcionario_planilla_sel';// nombre procedimiento almacenado
        $this->transaccion='PLA_BENEF_SUB_SEL';//nombre de la transaccion
        $this->tipo_procedimiento='SEL';//tipo de transaccion
        $this->setCount(true);

        $this->setParametro('gestion','gestion','int4');
        $this->setParametro('periodo','periodo','int4');

        //defino varialbes que se capturan como retorno de la funcion

        $this->captura('id_funcionario','integer');
        $this->captura('id_persona','integer');
        
        $this->captura('desc_person','text');
        $this->captura('nombre','text');
        $this->captura('valor_por_cuota','text');
        $this->captura('fecha_ini','text');
        $this->captura('fecha_fin','text');


        //Ejecuta la funcion
        $this->armarConsulta();
        //echo $this->getConsulta(); exit;
        $this->ejecutarConsulta();
        return $this->respuesta;
    }
			
}
?>