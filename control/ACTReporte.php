<?php
/**
 *@package pXP
 *@file gen-ACTReporte.php
 *@author  (admin)
 *@date 17-01-2014 22:07:28
 *@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
 */
//header('Content-Type: text/html; charset=UTF-8');
require_once(dirname(__FILE__).'/../reportes/RPlanillaGenerica.php');
require_once(dirname(__FILE__).'/../reportes/RPlanillaGenericaXls.php');
require_once(dirname(__FILE__).'/../reportes/RPrevisionesPDF.php');
require_once(dirname(__FILE__).'/../reportes/RPrevisionesXLS.php');
require_once(dirname(__FILE__).'/../reportes/RBoletaGenerica.php');
require_once(dirname(__FILE__).'/../reportes/RPlanillaActualizadaItemXLS.php');
require_once(dirname(__FILE__).'/../reportes/RGeneralPlanillaXLS.php');
require_once(dirname(__FILE__).'/../reportes/RPresupuestoRetroactivoXls.php');
require_once(dirname(__FILE__).'/../reportes/RAguinaldoXLSv2.php');
require_once(dirname(__FILE__).'/../reportes/RPlanillaRCIVAXLS.php');
require_once(dirname(__FILE__).'/../reportes/RPlanillaPrimaXLS.php');
require_once(dirname(__FILE__).'/../reportes/RDetalleOtrosIngresosXLS.php');

class ACTReporte extends ACTbase{

    function listarReporte(){
        $this->objParam->defecto('ordenacion','id_reporte');

        $this->objParam->defecto('dir_ordenacion','asc');
        if ($this->objParam->getParametro('id_tipo_planilla') != '') {
            $this->objParam->addFiltro("repo.id_tipo_planilla = ". $this->objParam->getParametro('id_tipo_planilla'));
        }
        if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODReporte','listarReporte');
        } else{
            $this->objFunc=$this->create('MODReporte');

            $this->res=$this->objFunc->listarReporte($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function insertarReporte(){
        $this->objFunc=$this->create('MODReporte');
        if($this->objParam->insertar('id_reporte')){
            $this->res=$this->objFunc->insertarReporte($this->objParam);
        } else{
            $this->res=$this->objFunc->modificarReporte($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarReporte(){
        $this->objFunc=$this->create('MODReporte');
        $this->res=$this->objFunc->eliminarReporte($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function reportePlanilla($id_reporte,$tipo_reporte)	{

        if ($this->objParam->getParametro('id_proceso_wf') != '') {
            $this->objParam->addFiltro("plani.id_proceso_wf = ". $this->objParam->getParametro('id_proceso_wf'));
        }

        if($id_reporte != 3 && ($tipo_reporte == 'pdf' || $tipo_reporte == 'excel')) {

            $this->objParam->addFiltro("repo.id_reporte = ". $id_reporte);

            $this->objFunc = $this->create('MODReporte');
            $this->res = $this->objFunc->listarReporteMaestro($this->objParam);

            $this->objFunc = $this->create('MODReporte');
            $this->res2 = $this->objFunc->listarReporteDetalle($this->objParam);
            //obtener titulo del reporte
            $titulo = $this->res->datos[0]['titulo_reporte'];
            //Genera el nombre del archivo (aleatorio + titulo)
            $nombreArchivo = uniqid(md5(session_id()) . $titulo);


            //obtener tamaño y orientacion
            if ($this->res->datos[0]['hoja_posicion'] == 'carta_vertical') {
                $tamano = 'LETTER';
                $orientacion = 'P';
            } else if ($this->res->datos[0]['hoja_posicion'] == 'carta_horizontal') {
                $tamano = 'LETTER';
                $orientacion = 'L';
            } else if ($this->res->datos[0]['hoja_posicion'] == 'oficio_vertical') {
                $tamano = 'LEGAL';
                $orientacion = 'P';
            } else {
                $tamano = 'LEGAL';
                $orientacion = 'L';
            }

            $this->objParam->addParametro('orientacion', $orientacion);
            $this->objParam->addParametro('tamano', $tamano);
            $this->objParam->addParametro('titulo_archivo', $titulo);


            if ($tipo_reporte == 'pdf') {
                $nombreArchivo .= '.pdf';
                $this->objParam->addParametro('nombre_archivo', $nombreArchivo);
                //Instancia la clase de pdf
                $this->objReporteFormato = new RPlanillaGenerica($this->objParam);
                $this->objReporteFormato->datosHeader($this->res->datos[0], $this->res2->datos);
                //$this->objReporteFormato->renderDatos($this->res2->datos);
                $this->objReporteFormato->gerencia = $this->res2->datos[0]['gerencia'];
                $this->objReporteFormato->generarReporte();
                $this->objReporteFormato->output($this->objReporteFormato->url_archivo, 'F');
            } else {

                $nombreArchivo .= '.xls';
                $this->objParam->addParametro('nombre_archivo', $nombreArchivo);
                $this->objParam->addParametro('config', $this->res->datos[0]);
                $this->objParam->addParametro('datos', $this->res2->datos);
                if ($id_reporte == 7 || $id_reporte == 8) {
                    //Instancia la clase de excel para aguinaldo v2018
                    $this->objReporteFormato = new RAguinaldoXLSv2($this->objParam);
                    $this->objReporteFormato->generarReporte();
                } else {
                    //Instancia la clase de excel
                    //$this->objReporteFormato = new RPlanillaGenericaXls($this->objParam);
                    if($id_reporte == 10){
                        $this->objReporteFormato = new RPlanillaPrimaXLS($this->objParam);
                        $this->objReporteFormato->imprimeDatos();
                        $this->objReporteFormato->generarReporte();
                    }else{
                        $this->objReporteFormato = new RPlanillaGenericaXls($this->objParam);
                        $this->objReporteFormato->imprimeDatos();
                        $this->objReporteFormato->generarReporte();
                    }
                }
            }
        }else{
            $this->objFunc = $this->create('MODReporte');
            $this->res=$this->objFunc->reporteRCIVA($this->objParam);
            $titulo_archivo = 'Planilla Impositiva';
            $this->datos=$this->res->getDatos();

            $nombreArchivo = uniqid(md5(session_id()).$titulo_archivo).'.xls';
            $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
            $this->objParam->addParametro('titulo_archivo',$titulo_archivo);
            $this->objParam->addParametro('datos',$this->datos);
            $this->objParam->addParametro('tipo','planilla');

            $this->objReporte = new RPlanillaRCIVAXLS($this->objParam);
            $this->objReporte->generarReporte();
        }

        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado',
            'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    function reporteBoleta()	{


        if ($this->objParam->getParametro('id_tipo_planilla') != '') {
            $this->objParam->addFiltro("plani.id_tipo_planilla = ". $this->objParam->getParametro('id_tipo_planilla'));
        }

        if ($this->objParam->getParametro('id_funcionario') != '') {
            $this->objParam->addFiltro("planifun.id_funcionario = ". $this->objParam->getParametro('id_funcionario'));
        }

        if ($this->objParam->getParametro('id_gestion') != '') {
            $this->objParam->addFiltro("plani.id_gestion = ". $this->objParam->getParametro('id_gestion'));
        }

        if ($this->objParam->getParametro('id_periodo') != '') {
            $this->objParam->addFiltro("plani.id_periodo = ". $this->objParam->getParametro('id_periodo'));
        }

        $this->objFunc=$this->create('MODReporte');

        $this->res=$this->objFunc->listarReporteMaestroBoleta($this->objParam);

        //obtener titulo del reporte
        $titulo = $this->res->datos[0]['titulo_reporte'];
        //Genera el nombre del archivo (aleatorio + titulo)
        $nombreArchivo=uniqid(md5(session_id()).$titulo);

        $this->objParam->addParametro('titulo_archivo',$titulo);
        $nombreArchivo.='.pdf';
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
        //Instancia la clase de pdf
        $this->objReporteFormato=new RBoletaGenerica($this->objParam);

        for ($i = 0; $i < count($this->res->datos); $i++){
            $this->objParam->addParametro('id_funcionario',$this->res->datos[$i]['id_funcionario']);
            $this->objFunc=$this->create('MODReporte');
            $this->res2=$this->objFunc->listarReporteDetalleBoleta($this->objParam);
            $this->objReporteFormato->datosHeader($this->res->datos[$i], $this->res2->datos);
            $this->objReporteFormato->generarReporte();
        }

        $this->objReporteFormato->output($this->objReporteFormato->url_archivo,'F');

        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado',
            'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

    }
    function generarReporteDesdeForm(){
        if ($this->objParam->getParametro('id_depto') != '') {
            $this->objParam->addFiltro("plani.id_depto = ". $this->objParam->getParametro('id_depto'));
        }



        $this->objParam->addFiltro("plani.estado not in (''registro_funcionarios'', ''registro_horas'')"); //plani.estado = ''planilla_finalizada''

        if ($this->objParam->getParametro('tipo_reporte') == 'planilla') {
            if ($this->objParam->getParametro('id_tipo_planilla') != '') {
                $this->objParam->addFiltro("plani.id_tipo_planilla = ". $this->objParam->getParametro('id_tipo_planilla'));
            }

            if ($this->objParam->getParametro('id_gestion') != '') {
                $this->objParam->addFiltro("plani.id_gestion = ". $this->objParam->getParametro('id_gestion'));
            }

            if ($this->objParam->getParametro('id_periodo') != '') {
                $this->objParam->addFiltro("plani.id_periodo = ". $this->objParam->getParametro('id_periodo'));
            }
            $this->reportePlanilla($this->objParam->getParametro('id_reporte'), $this->objParam->getParametro('formato_reporte'));
        } else {
            $this->reporteBoleta();
        }
    }

    function listarReportePrevisiones()	{
        if ($this->objParam->getParametro('id_uo') == '') {
            $this->objParam->addParametro('id_uo','-1');
            $this->objParam->addParametro('uo','TODOS');
        }

        if ($this->objParam->getParametro('id_tipo_contrato') == '') {
            $this->objParam->addParametro('id_tipo_contrato','-1');
            $this->objParam->addParametro('tipo_contrato','TODOS');
        }
        $this->objFunc=$this->create('MODReporte');
        $this->res=$this->objFunc->listarReportePrevisiones($this->objParam);


        //obtener titulo del reporte
        $titulo = 'Previsiones';
        //Genera el nombre del archivo (aleatorio + titulo)
        $nombreArchivo=uniqid(md5(session_id()).$titulo);




        if ($this->objParam->getParametro('tipo_reporte') == 'pdf') {
            $nombreArchivo.='.pdf';
            $this->objParam->addParametro('orientacion','L');
            $this->objParam->addParametro('tamano','LETTER	');
            $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
            //Instancia la clase de pdf
            $this->objReporteFormato=new RPrevisionesPDF($this->objParam);
            $this->objReporteFormato->setDatos($this->res->datos);
            $this->objReporteFormato->generarReporte();
            $this->objReporteFormato->output($this->objReporteFormato->url_archivo,'F');

        } else {

            $nombreArchivo.='.xls';
            $this->objParam->addParametro('nombre_archivo',$nombreArchivo);

            $this->objParam->addParametro('datos',$this->res->datos);

            //Instancia la clase de excel
            $this->objReporteFormato=new RPrevisionesXLS($this->objParam);
            $this->objReporteFormato->imprimeDatos();
            $this->objReporteFormato->generarReporte();
        }

        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado',
            'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

    }

    function ListarReportePlanillaActualizadaItem (){

        if ($this->objParam->getParametro('id_tipo_contrato') == '') {
            $this->objParam->addParametro('id_tipo_contrato','-1');
            $this->objParam->addParametro('tipo_contrato','TODOS');
        }
        if($this->objParam->getParametro ('id_uo') == ''){
            $this->objParam->getParametro ('id_uo','-1');
            $this->objParam->getParametro ('uo','TODOS');
        }

        $this->objFunc=$this->create('MODReporte');
        $this->res=$this->objFunc->ListarReportePlanillaActualizadaItem ($this->objParam);
        //obtener titulo de reporte
        $titulo ='Planilla actualizada Item';
        //Genera el nombre del archivo (aleatorio + titulo)
        $nombreArchivo=uniqid(md5(session_id()).$titulo);

        if ($this->objParam->getParametro('agrupar_por') == 'Organigrama'){
            $nombreArchivo.='.xls';
            $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
            $this->objParam->addParametro('datos',$this->res->datos);
            //Instancia la clase de excel
            $this->objReporteFormato=new RPlanillaActualizadaItemXLS($this->objParam);
            $this->objReporteFormato->generarDatos('Organigrama');
            $this->objReporteFormato->generarReporte();

        }elseif ($this->objParam->getParametro('agrupar_por') == 'Regional'){
            $nombreArchivo.='.xls';
            $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
            $this->objParam->addParametro('datos',$this->res->datos);
            //Instancia la clase de excel
            $this->objReporteFormato=new RPlanillaActualizadaItemXLS($this->objParam);
            $this->objReporteFormato->generarDatos('Regional');
            $this->objReporteFormato->generarReporte();

        }elseif($this->objParam->getParametro('agrupar_por') == 'Regional oficina'){
            $nombreArchivo.='.xls';
            $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
            $this->objParam->addParametro('datos',$this->res->datos);
            //Instancia la clase de excel
            $this->objReporteFormato=new RPlanillaActualizadaItemXLS($this->objParam);
            $this->objReporteFormato->generarDatos('Regional oficina');
            $this->objReporteFormato->generarReporte();
        }


        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado',
            'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

    }

    function reporteGeneralPlanilla(){

        $this->objFunc=$this->create('MODReporte');
        if($this->objParam->getParametro('configuracion_reporte') == 'contacto'){
            $this->res=$this->objFunc->reporteGeneralPlanilla($this->objParam);
            $titulo_archivo = 'Empleados con Datos de Contato';
        }else if($this->objParam->getParametro('configuracion_reporte') == 'programatica'){
            $this->res=$this->objFunc->reportePresupuestoCatProg($this->objParam);
            $titulo_archivo = 'Prespuesto Retroactivo';
        }else if($this->objParam->getParametro('configuracion_reporte') == 'aguinaldo'){
            $this->res=$this->objFunc->reporteAguinaldo($this->objParam);
            $titulo_archivo = 'Planilla Aguinaldo';
        }else if($this->objParam->getParametro('configuracion_reporte') == 'rc_iva'){
            $this->res=$this->objFunc->reporteRCIVA($this->objParam);
            $titulo_archivo = 'Planilla RC-IVA';
        }else if($this->objParam->getParametro('configuracion_reporte') == 'otros_ing'){
            $this->res=$this->objFunc->reporteOtrosIngresosRCIVA($this->objParam);
            $titulo_archivo = 'Planilla Otros Ingresos RC-IVA';
        }


        $this->datos=$this->res->getDatos();

        $nombreArchivo = uniqid(md5(session_id()).$titulo_archivo).'.xls';
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
        $this->objParam->addParametro('titulo_archivo',$titulo_archivo);
        $this->objParam->addParametro('datos',$this->datos);

        if($this->objParam->getParametro('configuracion_reporte') == 'contacto'){
            $this->objReporte = new RGeneralPlanillaXls($this->objParam);
        }else if($this->objParam->getParametro('configuracion_reporte') == 'programatica'){
            $this->objReporte = new RPresupuestoRetroactivoXls($this->objParam);
        }else if($this->objParam->getParametro('configuracion_reporte') == 'aguinaldo'){
            $this->objReporte = new RAguinaldoXLSv2($this->objParam);
        }else if($this->objParam->getParametro('configuracion_reporte') == 'rc_iva'){
            $this->objReporte = new RPlanillaRCIVAXLS($this->objParam);
        }else if($this->objParam->getParametro('configuracion_reporte') == 'otros_ing'){
            $this->objParam->addParametro('tipo','formulario');
            $this->objReporte = new RDetalleOtrosIngresosXLS($this->objParam);
        }

        $this->objReporte->generarReporte();


        $mensajeExito = new Mensaje();
        $mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
        $mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->res = $mensajeExito;
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function uploadCsvCodigosRCIVA(){
        //validar extnsion del archivo
        $arregloFiles = $this->objParam->getArregloFiles();
        $ext = pathinfo($arregloFiles['archivo']['name']);
        $extension = $ext['extension'];
        $error = 'no';
        $mensaje_completo = '';
        if(isset($arregloFiles['archivo']) && is_uploaded_file($arregloFiles['archivo']['tmp_name'])){
            if ($extension != 'csv' && $extension != 'CSV') {
                $mensaje_completo = "La extensión del archivo debe ser CSV";
                $error = 'error_fatal';
            }
            //upload directory
            $upload_dir = "/var/www/html/kerp/sis_organigrama/archivos_rc_iva/";//"/home/archivos/";
            //create file name
            $file_path = $upload_dir . $arregloFiles['archivo']['name'];

            //move uploaded file to upload dir
            if (!move_uploaded_file($arregloFiles['archivo']['tmp_name'], $file_path)) {
                //error moving upload file
                $mensaje_completo = "Error al guardar el archivo csv en disco";
                $error = 'error_fatal';
            }

        } else {
            $mensaje_completo = "No se subio el archivo";
            $error = 'error_fatal';
        }

        exec('iconv -f ISO-8859-1 -t UTF-8 /var/www/html/kerp/sis_organigrama/archivos_rc_iva/'.$ext['filename'].'.csv > /var/www/html/kerp/sis_organigrama/archivos_rc_iva/'.$ext['filename'].'_utf8.csv');

        $registros = array();

        if (($fichero = fopen("/var/www/html/kerp/sis_organigrama/archivos_rc_iva/".$ext['filename']."_utf8.csv", "r")) !== FALSE) {

            // Lee los registros
            while (($datos = fgetcsv($fichero, 0, ";", "\"", "\"")) !== FALSE) {
                // Crea un array asociativo con los nombres y valores de los campos

                $reg = new stdClass();
                $reg->codigo  = $datos[0];
                $reg->nombre  = (string)$datos[1];
                $reg->primer_apellido = (string)$datos[2];
                $reg->segundo_apellido  = (string)$datos[3];
                $reg->numero_doc  = (string)$datos[4];
                $reg->tipo_doc  = (string)$datos[5];
                // Añade el registro leido al array de registros
                $registros[] = $reg;
                /*json_decode(json_encode(array(
                                        "codigo" => $datos[0],
                                        "nombre" => $datos[1],
                                        "primer_apellido" => $datos[2],
                                        "segundo_apellido" => $datos[3],
                                        "numero_doc" => $datos[4],
                                        "tipo_doc" => $datos[5]
                                );*/
            }

            fclose($fichero);
        }

        $records = str_replace('\\','',json_encode($registros));

        $this->objParam->addParametro('registros', $records);
        $this->objFunc=$this->create('MODReporte');
        $this->res=$this->objFunc->uploadCsvCodigosRCIVA($this->objParam);

        //armar respuesta en caso de exito o error en algunas tuplas
        if ($error == 'error') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTReporte.php','Ocurrieron los siguientes errores : ' . $mensaje_completo,
                $mensaje_completo,'control');
        } else if ($error == 'no') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('EXITO','ACTReporte.php','El archivo fue ejecutado con éxito',
                'El archivo fue ejecutado con éxito','control');
        }
        //devolver respuesta
        $this->mensajeRes->imprimirRespuesta($this->mensajeRes->generarJson());
    }

    //franklin.espinoza 23/9/2019
    function reporteOtrosIngresos(){

        if ($this->objParam->getParametro('id_proceso_wf') != '') {
            $this->objParam->addFiltro("tp.id_proceso_wf = ". $this->objParam->getParametro('id_proceso_wf'));
        }

        $this->objFunc = $this->create('MODReporte');
        $this->res=$this->objFunc->reporteOtrosIngresos($this->objParam);
        $titulo_archivo = 'Planilla Global Otros ingresos';
        $this->datos=$this->res->getDatos();

        $nombreArchivo = uniqid(md5(session_id()).$titulo_archivo).'.xls';
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
        $this->objParam->addParametro('titulo_archivo',$titulo_archivo);
        $this->objParam->addParametro('datos',$this->datos);

        $this->objReporte = new RDetalleOtrosIngresosXLS($this->objParam);
        $this->objReporte->generarReporte();

        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->res = $this->mensajeExito;
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

}

?>