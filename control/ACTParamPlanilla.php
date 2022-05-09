<?php
/**
*@package pXP
*@file gen-ACTParamPlanilla.php
*@author  (franklin.espinoza)
*@date 26-08-2019 20:06:59
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTParamPlanilla extends ACTbase{    
			
	function listarParamPlanilla(){
		$this->objParam->defecto('ordenacion','id_param_planilla');

        if($this->objParam->getParametro('id_tipo_planilla') != '' ) {
            $this->objParam->addFiltro(" parampla.id_tipo_planilla = " . $this->objParam->getParametro('id_tipo_planilla'));
        }
		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODParamPlanilla','listarParamPlanilla');
		} else{
			$this->objFunc=$this->create('MODParamPlanilla');
			
			$this->res=$this->objFunc->listarParamPlanilla($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarParamPlanilla(){
		$this->objFunc=$this->create('MODParamPlanilla');	
		if($this->objParam->insertar('id_param_planilla')){
			$this->res=$this->objFunc->insertarParamPlanilla($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarParamPlanilla($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarParamPlanilla(){
			$this->objFunc=$this->create('MODParamPlanilla');	
		$this->res=$this->objFunc->eliminarParamPlanilla($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>