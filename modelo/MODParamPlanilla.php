<?php
/**
*@package pXP
*@file gen-MODParamPlanilla.php
*@author  (franklin.espinoza)
*@date 26-08-2019 20:06:59
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODParamPlanilla extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarParamPlanilla(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='plani.ft_param_planilla_sel';
		$this->transaccion='PLA_PARAMPLA_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_param_planilla','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_tipo_planilla','int4');
		$this->captura('porcentaje_calculo','numeric');
		$this->captura('valor_promedio','numeric');
		$this->captura('porcentaje_menor_promedio','numeric');
		$this->captura('porcentaje_mayor_promedio','numeric');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('fecha_incremento','date');
		$this->captura('porcentaje_antiguedad','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarParamPlanilla(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_param_planilla_ime';
		$this->transaccion='PLA_PARAMPLA_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_tipo_planilla','id_tipo_planilla','int4');
		$this->setParametro('porcentaje_calculo','porcentaje_calculo','numeric');
		$this->setParametro('valor_promedio','valor_promedio','numeric');
		$this->setParametro('porcentaje_menor_promedio','porcentaje_menor_promedio','numeric');
		$this->setParametro('porcentaje_mayor_promedio','porcentaje_mayor_promedio','numeric');
		$this->setParametro('porcentaje_antiguedad','porcentaje_antiguedad','numeric');
		$this->setParametro('fecha_incremento','fecha_incremento','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarParamPlanilla(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_param_planilla_ime';
		$this->transaccion='PLA_PARAMPLA_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_param_planilla','id_param_planilla','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_tipo_planilla','id_tipo_planilla','int4');
		$this->setParametro('porcentaje_calculo','porcentaje_calculo','numeric');
		$this->setParametro('valor_promedio','valor_promedio','numeric');
		$this->setParametro('porcentaje_menor_promedio','porcentaje_menor_promedio','numeric');
		$this->setParametro('porcentaje_mayor_promedio','porcentaje_mayor_promedio','numeric');
		$this->setParametro('porcentaje_antiguedad','porcentaje_antiguedad','numeric');
        $this->setParametro('fecha_incremento','fecha_incremento','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarParamPlanilla(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='plani.ft_param_planilla_ime';
		$this->transaccion='PLA_PARAMPLA_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_param_planilla','id_param_planilla','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>