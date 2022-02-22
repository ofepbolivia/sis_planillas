<?php
/**
 *@package pXP
 *@file gen-ACTPlanilla.php
 *@author  (admin)
 *@date 22-01-2014 16:11:04
 *@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
 */
require_once(dirname(__FILE__).'/../reportes/RMinisterioTrabajoXLS.php');
require_once(dirname(__FILE__).'/../reportes/RMinisterioTrabajoUpdateXLS.php');
require_once(dirname(__FILE__).'/../reportes/RPrimaXLS.php');
require_once(dirname(__FILE__).'/../reportes/RAguinaldoXLS.php');
require_once(dirname(__FILE__).'/../reportes/RSegAguinaldoXLS.php');
require_once(dirname(__FILE__).'/../reportes/RCertificacionPresupuestaria.php');
require_once(dirname(__FILE__).'/../reportes/RMinisterioTrabajoAguinaldoXLS.php');
require_once(dirname(__FILE__).'/../reportes/RMinisterioTrabajoSegAguinaldoXLS.php');
require_once(dirname(__FILE__).'/../reportes/RElaboracionFormC31PDF.php');
require_once(dirname(__FILE__).'/../reportes/RDetalleOtrosIngresosTableXLS.php');
require_once(dirname(__FILE__).'/../reportes/RElaboracionPlaniC31PDF.php');

class ACTPlanilla extends ACTbase{

    function listarPlanilla(){
        $this->objParam->defecto('ordenacion','id_planilla');

        $this->objParam->defecto('dir_ordenacion','asc');

        if ($this->objParam->getParametro('pes_estado') == 'otro') {
            $this->objParam->addFiltro("plani.estado in (''registro_funcionarios'', ''registro_horas'', ''calculo_columnas'')");
        } else if ($this->objParam->getParametro('pes_estado') == 'vbrh') {
            $this->objParam->addFiltro("plani.estado  in (''calculo_validado'')");
        } else if ($this->objParam->getParametro('pes_estado') == 'planilla_finalizada') {
            $this->objParam->addFiltro("plani.estado  in (''planilla_finalizada'')");
        } else if ($this->objParam->getParametro('pes_estado') == 'comprobante_generado') {
            $this->objParam->addFiltro("plani.estado  in (''comprobante_generado''/*,''suppresu'',''vbpresupuestos'', ''calculo_validado''*/)");
        } else if($this->objParam->getParametro('pes_estado') == 'vbpoa'){
            $this->objParam->addFiltro("plani.estado  in (''vbpoa'')");
        } else if($this->objParam->getParametro('pes_estado') == 'suppresu'){
            $this->objParam->addFiltro("plani.estado  in (''suppresu'')");
        } else if($this->objParam->getParametro('pes_estado') == 'vbpresupuestos'){
            $this->objParam->addFiltro("plani.estado  in (''vbpresupuestos'')");
        }else if($this->objParam->getParametro('pes_estado') == 'consultas'){
            $this->objParam->addFiltro("plani.estado  not in (''todos'')");
        }

        if ($this->objParam->getParametro('id_gestion') != '') {

            $this->objParam->addFiltro("plani.id_gestion = ". $this->objParam->getParametro('id_gestion'));

        }

        if ($this->objParam->getParametro('id_tipo_planilla') != '') {
            $this->objParam->addFiltro("plani.id_tipo_planilla = ". $this->objParam->getParametro('id_tipo_planilla'));
        }

        if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODPlanilla','listarPlanilla');
        } else{
            $this->objFunc=$this->create('MODPlanilla');

            $this->res=$this->objFunc->listarPlanilla($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function listarReportePlanillaMinisterio(){
        $this->objFunc=$this->create('MODPlanilla');

        if ($this->objParam->getParametro('id_tipo_planilla') == 1) {
            if($this->objParam->getParametro('formato')=='antiguo') {
                $this->res = $this->objFunc->listarReportePlanillaMinisterio($this->objParam);
            }else if($this->objParam->getParametro('formato')=='nuevo'){
                $this->res = $this->objFunc->listarReportePlanillaMinisterioNuevo($this->objParam);
            }

        } else if ($this->objParam->getParametro('id_tipo_planilla') == 7) {
            $this->res=$this->objFunc->listarReportePrimaMinisterio($this->objParam);
        } else if ($this->objParam->getParametro('id_tipo_planilla') == 4) {
            if($this->objParam->getParametro('formato')=='antiguo') {
                $this->res=$this->objFunc->listarReporteAguinaldoMinisterio($this->objParam);
            }else if($this->objParam->getParametro('formato')=='nuevo'){
                $this->res = $this->objFunc->listarReporteAguinaldoMinisterioNuevo($this->objParam);
            }
        } else if ($this->objParam->getParametro('id_tipo_planilla') == 5) {
            if($this->objParam->getParametro('formato')=='antiguo') {
                $this->res=$this->objFunc->listarReporteSegAguinaldoMinisterio($this->objParam);
            }else if($this->objParam->getParametro('formato')=='nuevo'){
                $this->res = $this->objFunc->listarReporteSegAguinaldoMinisterioNuevo($this->objParam);
            }
        }
        //obtener titulo del reporte
        $titulo = 'RepMinisterioTrabajo';

        //Genera el nombre del archivo (aleatorio + titulo)
        $nombreArchivo=uniqid(md5(session_id()).$titulo);
        $nombreArchivo.='.xls';
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
        $this->objParam->addParametro('datos',$this->res->datos);
        $this->objParam->addParametro('modalidad',$this->objParam->getParametro('modalidad'));

        $this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->listarReporteMinisterioCabecera($this->objParam);
        $this->objParam->addParametro('datos_cabecera',$this->res->datos);

        if ($this->objParam->getParametro('id_tipo_planilla') == 1) {
            //Instancia la clase de excel
            if($this->objParam->getParametro('formato')=='antiguo'){
                $this->objReporteFormato = new RMinisterioTrabajoXLS($this->objParam);
                $this->objReporteFormato->imprimeDatosSueldo();
                $this->objReporteFormato->imprimeDatosSueldoReducido();
                $this->objReporteFormato->imprimeResumen();
                $this->objReporteFormato->imprimeResumenRegional();
            }else if($this->objParam->getParametro('formato')=='nuevo'){
                $this->objReporteFormato = new RMinisterioTrabajoUpdateXLS($this->objParam);
                $this->objReporteFormato->imprimeDatosSueldo();
                $this->objReporteFormato->imprimeResumen();
                $this->objReporteFormato->imprimeResumenRegional();
            }

        } else if ($this->objParam->getParametro('id_tipo_planilla') == 7 ) {

            $this->objReporteFormato=new RPrimaXLS($this->objParam);
            $this->objReporteFormato->imprimeDatosSueldo();
            $this->objReporteFormato->imprimeResumen();
        } else if ($this->objParam->getParametro('id_tipo_planilla') == 4) {

            if($this->objParam->getParametro('formato')=='antiguo'){
                $this->objReporteFormato=new RAguinaldoXLS($this->objParam);
                $this->objReporteFormato->imprimeDatosSueldo();
                $this->objReporteFormato->imprimeResumen();
            }else if($this->objParam->getParametro('formato')=='nuevo'){
                $this->objReporteFormato = new RMinisterioTrabajoAguinaldoXLS($this->objParam);
                $this->objReporteFormato->imprimeDatosSueldo();
                $this->objReporteFormato->imprimeResumen();
                //$this->objReporteFormato->imprimeResumenRegional();
            }
        } else if ($this->objParam->getParametro('id_tipo_planilla') == 5) {

            if($this->objParam->getParametro('formato')=='antiguo'){
                $this->objReporteFormato=new RSegAguinaldoXLS($this->objParam);
                $this->objReporteFormato->imprimeDatosSueldo();
                $this->objReporteFormato->imprimeResumen();
            }else if($this->objParam->getParametro('formato')=='nuevo'){
                $this->objReporteFormato = new RMinisterioTrabajoSegAguinaldoXLS($this->objParam);
                $this->objReporteFormato->imprimeDatosSueldo();
                $this->objReporteFormato->imprimeResumen();
                //$this->objReporteFormato->imprimeResumenRegional();
            }
        }

        $this->objReporteFormato->generarReporte();
        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado',
            'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    function insertarPlanilla(){
        $this->objFunc=$this->create('MODPlanilla');
        if($this->objParam->insertar('id_planilla')){
            $this->res=$this->objFunc->insertarPlanilla($this->objParam);
        } else{
            $this->res=$this->objFunc->modificarPlanilla($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarPlanilla(){
        $this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->eliminarPlanilla($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function generarDescuentoCheque(){
        $this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->generarDescuentoCheque($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function ejecutarProcesoPlanilla(){
        $this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->ejecutarProcesoPlanilla($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function siguienteEstadoPlanilla(){
        $this->objFunc=$this->create('MODPlanilla');

        $this->objParam->addParametro('id_funcionario_usu',$_SESSION["ss_id_funcionario"]);

        $this->res=$this->objFunc->siguienteEstadoPlanilla($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function anteriorEstadoPlanilla(){
        $this->objFunc=$this->create('MODPlanilla');
        $this->objParam->addParametro('id_funcionario_usu',$_SESSION["ss_id_funcionario"]);
        $this->res=$this->objFunc->anteriorEstadoPlanilla($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    //Reporte Certificación Presupuestaria Planilla(F.E.A) 28/02/2018
    function reporteCertificacionP (){
        $this->objFunc=$this->create('MODPlanilla');
        $dataSource=$this->objFunc->reporteCertificacionP();
        $this->dataSource=$dataSource->getDatos();

        $nombreArchivo = uniqid(md5(session_id()).'[Planilla - Certificación Presupuestaria]').'.pdf';
        $this->objParam->addParametro('orientacion','P');
        $this->objParam->addParametro('tamano','LETTER');
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);

        $this->objReporte = new RCertificacionPresupuestaria($this->objParam);
        $this->objReporte->setDatos($this->dataSource);
        $this->objReporte->generarReporte();
        $this->objReporte->output($this->objReporte->url_archivo,'F');


        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado', 'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    //(f.e.a)13/3/2017 modificar datos poa de planilla
    function modificarObsPoa(){
        $this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->modificarObsPoa($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }
    //(f.e.a)13/3/2017
    function listarPartidaObjetivo(){

        /*$this->objParam->defecto('ordenacion','id_objetivo');
        $this->objParam->defecto('dir_ordenacion','asc');*/

        /////////////////
        //	FILTROS
        ////////////////
        /*if($this->objParam->getParametro('id_gestion')!='') {
            $this->objParam->addFiltro("obj.id_gestion = ".$this->objParam->getParametro('id_gestion'));
        }
        if($this->objParam->getParametro('sw_transaccional')!='') {
            $this->objParam->addFiltro("obj.sw_transaccional = ''".$this->objParam->getParametro('sw_transaccional')."''");
        }*/
        /////////////////////
        //Llamada al Modelo
        /////////////////////
        $this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->listarPartidaObjetivo($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    //Reporte Elaboracion Formulario C31 sigma(F.E.A) 30/01/2019
    function reporteElaboracionFormC31 (){
        $this->objFunc=$this->create('MODPlanilla');
        $dataSource=$this->objFunc->reporteElaboracionFormC31();
        $this->dataSource=$dataSource->getDatos();

        //Retenciones
        $this->objFunc = $this->create('MODPlanilla');
        $dataSourceRetencion = $this->objFunc->reporteRetencionFormC31($this->objParam);
        $this->dataRetencion = $dataSourceRetencion->getDatos();

        $nombreArchivo = uniqid(md5(session_id()).'[Planilla - Elaboración C31]').'.pdf';
        $this->objParam->addParametro('orientacion','P');
        $this->objParam->addParametro('tamano','LETTER');
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);

        $this->objReporte = new RElaboracionFormC31PDF($this->objParam);
        $this->objReporte->setDatos($this->dataSource, $this->dataRetencion);
        $this->objReporte->generarReporte();
        $this->objReporte->output($this->objReporte->url_archivo,'F');


        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado', 'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    //(f.e.a)13/10/2019 listar Otros Ingresos Funcionario
    function listarOtrosIngresos(){

        $this->objParam->defecto('ordenacion','toi.nombre_sys_ingreso');
        $this->objParam->defecto('dir_ordenacion','asc');

        if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODPlanilla','listarOtrosIngresos');
        } else{
            $this->objFunc=$this->create('MODPlanilla');

            $this->res=$this->objFunc->listarOtrosIngresos($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());

        /*$this->objFunc=$this->create('MODPlanilla');
        $this->res=$this->objFunc->listarOtrosIngresos($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());*/
    }

    //(f.e.a) 06/02/2020 reporte excel de otros ingresos por periodo finanzas
    function reporteOtrosIngresos(){

        $periodo = $this->objParam->getParametro('periodo');
        $gestion = $this->objParam->getParametro('gestion');

        $this->objFunc = $this->create('MODPlanilla');
        $this->res=$this->objFunc->reporteOtrosIngresos($this->objParam);
        $titulo_archivo = 'Planilla Otros ingresos';
        $this->datos=$this->res->getDatos();

        $nombreArchivo = uniqid(md5(session_id()).$titulo_archivo).'.xls';
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
        $this->objParam->addParametro('titulo_archivo',$titulo_archivo);
        $this->objParam->addParametro('datos',$this->datos);
        $this->objParam->addParametro('gestion',$this->objParam->getParametro('gestion'));
        $this->objParam->addParametro('periodo',$this->objParam->getParametro('periodo'));

        /**************************************************** BACKGROUND ****************************************************/
        /*$NEW_LINE = "\r\n";
        ignore_user_abort(true);
        header('Connection: close' . $NEW_LINE);
        header('Content-Encoding: none' . $NEW_LINE);
        ob_start();
        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado '.$nombreArchivo,'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
        $size = ob_get_length();
        header('Content-Length: ' . $size, TRUE);
        ob_end_flush();
        ob_flush();
        flush();
        session_write_close();*/
        /**************************************************** BACKGROUND ****************************************************/

        $this->objReporte = new RDetalleOtrosIngresosTableXLS($this->objParam);
        $this->objReporte->generarReporte();

        /**************************************************** RESPONSE ****************************************************/
//        /** Convertir a megas **/
//        $file_size = filesize($url_file_xls);
//        $units = array('B', 'KB', 'MB', 'GB', 'TB');
//
//        $bytes = max($file_size, 0);
//        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
//        $pow = min($pow, count($units) - 1);
//
//        $equivalencia = 1;
//        if ($units[$pow] == 'KB') {
//            $equivalencia = 1024;
//        }else if ($units[$pow] == 'MB'){
//            $equivalencia = 1048576;
//        }else if ($units[$pow] == 'GB'){
//            $equivalencia = 1073741824;
//        }
//        $file_size = round($bytes/$equivalencia, 2) . ' ' . $units[$pow];
//        /** Convertir a megas **/
//
//        //$url_absolute = './../../../reportes_generados/'.$nombreArchivo;
//        $url_absolute = $url_file_xls;
//
//        $cone = new conexion();
//        $link = $cone->conectarpdo();
//
//        $sql = "UPDATE  plani.tdocumento_generado SET
//                      estado_reg = 'OLD'
//                    WHERE format = 'xls' and estado_reg != 'inactivo'";
//
//        $stmt = $link->prepare($sql);
//        $stmt->execute();
//
//        $sql = "INSERT INTO plani.tdocumento_generado(id_usuario_reg, url, size, fecha_generacion, file_name, format, estado_reg, periodo, gestion) VALUES (" . $_SESSION["ss_id_usuario"] . "::integer, '" . $url_absolute . "', '" . $file_size . "', now(), '" . $nombreArchivo . "', 'xls', 'NEW', $periodo, $gestion) ";
//
//        $stmt = $link->prepare($sql);
//        $stmt->execute();
//
//        /**enviar alert al usuario para indicar que el reporte ha sido generado**/
//        $evento = "enviarMensajeUsuario";
//
//        //mandamos datos al websocket
//        $data = array(
//            "mensaje" => 'Estimado Funcionario, su Reporte ya ha sido generado: ' . $nombreArchivo,
//            "tipo_mensaje" => 'alert',
//            "titulo" => 'Alerta Reporte',
//            "id_usuario" => $_SESSION["ss_id_usuario"],
//            "destino" => 'Unico',
//            "evento" => $evento,
//            "url" => 'url_prueba'
//        );
//
//        $send = array(
//            "tipo" => "enviarMensajeUsuario",
//            "data" => $data
//        );
//
//        $usuarios_socket = $this->dispararEventoWS($send);
//
//        $usuarios_socket = json_decode($usuarios_socket, true);
        /**enviar alert al usuario para indicar que el reporte ha sido generado**/
        /**************************************************** RESPONSE ****************************************************/

        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->res = $this->mensajeExito;
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    //Reporte Elaboracion Formulario C31 Planilla de Funcionarios(F.E.A) 17/02/2020
    function reporteElaboracionPlanillaC31 (){

        $this->objFunc=$this->create('MODPlanilla');
        $dataSource=$this->objFunc->reporteElaboracionPlanillaC31();
        $this->dataSource=$dataSource->getDatos();

        $nombreArchivo = uniqid(md5(session_id()).'[Planilla - Funcionarios C31]').'.pdf';
        $this->objParam->addParametro('orientacion','L');
        $this->objParam->addParametro('tamano','LETTER');
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);

        $this->objReporte = new RElaboracionPlaniC31PDF($this->objParam);
        $this->objReporte->setDatos($this->dataSource);
        $this->objReporte->generarReporte();
        $this->objReporte->output($this->objReporte->url_archivo,'F');


        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado', 'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    //{develop:franklin.espinoza, date:30/7/2020, description: Validar Otros Ingresos por su responsable correspondiente}
    function validarResponsableOtrosIngresos(){ //var_dump($_SESSION["ss_id_funcionario"]);exit;
        $this->objFunc=$this->create('MODPlanilla');

        if(($_SESSION["ss_id_funcionario"] == 43 || $_SESSION["ss_id_funcionario"] == 2145) && $this->objParam->getParametro('sistema') == 'refrigerio') {
            $this->res=$this->objFunc->validarResponsableOtrosIngresos($this->objParam);
            $this->res->imprimirRespuesta($this->res->generarJson());
        }else if ($_SESSION["ss_id_funcionario"] == 28 && ($this->objParam->getParametro('sistema') == 'viatico' || $this->objParam->getParametro('sistema') == 'viatico_operativo')) {
            $this->res = $this->objFunc->validarResponsableOtrosIngresos($this->objParam);
            $this->res->imprimirRespuesta($this->res->generarJson());
        }else{
            $this->mensajeFail=new Mensaje();
            $this->mensajeFail->setMensaje('EXITO','Planilla.php','Validación Planilla', 'Usted no esta Autorizado para realizar esta Acción ','control');
            $this->mensajeFail->setDatos(array('error' => true, 'mensaje'=>'Usted no esta Autorizado para realizar esta Acción.'));
            $this->mensajeFail->imprimirRespuesta($this->mensajeFail->generarJson());
        }



    }
}
?>