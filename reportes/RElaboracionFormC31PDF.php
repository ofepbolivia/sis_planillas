<?php
// Extend the TCPDF class to create custom MultiRow
class RElaboracionFormC31PDF extends  ReportePDF {
    var $datos_titulo;
    var $datos_detalle;
    var $ancho_hoja;
    var $gerencia;
    var $numeracion;
    var $ancho_sin_totales;
    var $cantidad_columnas_estaticas;

    function setDatos($datos, $retencion) {
        $this->datos = $datos;
        $this->retencion = $retencion;
        //var_dump($this->retencion);exit;
    }

    function Header() {
        $this->Image(dirname(__FILE__).'/../../lib/imagenes/logos/logo.jpg', 16,5,30,10);
        $this->ln(5);
        $this->SetFont('','B',12);
        $this->Cell(0,5,"Elaboración Formulario C-31 (".$this->datos[0]['tipo_planilla'].')',0,1,'C');
        $this->Cell(0,5,$this->datos[0]['observaciones'],0,1,'C');

        $this->Ln(2);
    }

    function generarReporte() {
        /*$this->setFontSubsetting(false);
        $this->AddPage();*/

        $antiguedad = 0;
        $frontera = 0;
        $sueldos = 0;
        $corto_plazo = 0;
        $largo_plazo = 0;
        $eventual = 0;



        $categoria = '';
        $partida = '';
        $tbl = '';
        $tbl_det = '';

        $programa = '';
        $proyecto = '';
        $actividad = '';
        $objeto_gasto = '';
        $entidad_transf = '';
        $descripcion = '';

        $sumatoria = 0;

        $total_sum = 0;

        $total_planilla = 0;

        $total_retencion = 0;
        foreach ($this->datos as $value) {
            if($categoria != $value['categoria_prog'] || $categoria == ''){
                if($categoria != $value['categoria_prog'] && $categoria != ''){
                    $total_sum = $total_sum + $sumatoria;
                    $tbl_det .= '
                            <tr><td>' . $programa . '</td><td>' . $proyecto . '</td><td>' . $actividad . '</td><td>' . $objeto_gasto . '</td><td>' . $entidad_transf . '</td><td>' . $descripcion . '</td><td style="text-align: right;">' .  number_format($sumatoria, 2, ',', '.') . '</td></tr>
                            <tr><td colspan="6" style="text-align: center">Total Categoria</td><td style="text-align: right;">'.number_format($total_sum, 2, ',', '.').'</td></tr>
                            ';
                    $total_planilla = $total_planilla + $total_sum;

                    $tbl_det = '&nbsp;&nbsp;<span style="font-size: 7pt;"><b>IMPUTACION</b></span> <br>
                                <table border="1" style="font-size: 7pt;"> 
                                <tr style="font-weight: bold; text-align: center;"><th width="6%">PROG</th><th width="5%">PROY</th><th width="7%">ACTIV</th><th width="10%">OBJ. GASTO</th><th width="9%">ENT. TRF.</th><th width="53%">DESCRIPCION</th><th width="10%">IMPORTE</th></tr>
                                
                                '.$tbl_det.'</table>';
                    $this->writeHTML ($tbl_det);
                    $tbl_det = '';
                    $sumatoria = 0;
                    $total_sum = 0;
                    $partida = '';

                    //retenciones
                    $tbl_reten = '<br>&nbsp;&nbsp;<span style="font-size: 7pt;"><b>RETENCIONES</b></span> <br>
                    <table border="1" style="font-size: 7pt;">
                    <tr style="font-weight: bold; text-align: center;"><th width="10%">CONCEPTO</th><th width="15%">ACREEDOR</th><th width="30%">DESCRIPCION</th><th width="10%">MONTO</th></tr>
                    ';
                    foreach($this->retencion as $reten){
                        if($categoria == $reten['categoria_prog']){
                            $tbl_reten .='<tr style="text-align: center;"><td style="text-align: left;" width="10%">'.$reten['categoria_prog'].'</td><td style="text-align: left;" width="15%">'.$reten['retencion'].'</td><td style="text-align: left;" width="30%">'.ucwords(strtolower($reten['desc_retencion'])).'</td><td style="text-align: right;" width="10%">'.number_format($reten['monto'], 2, ',', '.').'</td></tr>';
                            $total_retencion += $reten['monto'];
                        }
                    }
                    $tbl_reten .='<tr><td colspan="3" style="text-align: center">Total Retenciones</td><td style="text-align: right; font-weight: bold;">'.number_format($total_retencion, 2, ',', '.').'</td></tr>
                                  </table>';
                    $this->writeHTML ($tbl_reten);
                    $total_retencion = 0;
                    //retenciones
                }
                $this->setFontSubsetting(false);
                $this->AddPage();

                $tbl = '<table border="0" style="font-size: 7pt;"> 
                <tr><td width="28%"><b>Gestion: </b></td><td width="23%"> '.$value['gestion'].'</td><td width="23%"><b>Proceso: </b></td><td width="28%">'.$value['periodo'].'</td></tr>
                <tr><td><b>Entidad: </b></td><td> '.$value['entidad'].'</td><td><b>Modalidad: </b></td><td>'.$value['categoria_prog']./*'('.$value['desc_programa'].*/'</td></tr>
                <tr><td><b>D. Administrativa: </b></td><td> '.$value['direccion_admin'].'</td><td><b>Proceso Tipo: </b></td><td>'.$value['tipo_proceso'].' </td></tr>
                <tr><td><b>Unidad Ejecutora: </b></td><td>'.$value['unidad_ejecutora'].'</td><td><b>Estado de la Planilla: </b></td><td> VERIFICADO </td></tr>
                <tr><td><b>Fte. Finaciamiento: </b></td><td>'.$value['fuente_fin'].'</td><td><b>Clase de Gasto: </b></td><td>'.$value['clase_gasto'].'</td></tr>
                <tr><td colspan="4"><b>Org. Finaciador: </b></td><td>'.$value['origen_fin'].'</td></tr>
                ';

                $this->writeHTML ($tbl);

                $categoria = $value['categoria_prog'];


                $programa = $value['programa'];
                $proyecto = $value['proyecto'];
                $actividad = $value['actividad'];
                $objeto_gasto = $value['cod_partida'];
                $entidad_transf = $value['codigo_transf'];
                $descripcion = $value['nombre_partida'];
                $partida = $value['nombre_partida'];

                //$partida = '';
                $sumatoria = $sumatoria + $value['precio_total'];

            }else{
                if($partida != '' && $partida != $value['nombre_partida'] || $programa != '' && $programa != $value['programa']){

                    $total_sum = $total_sum + $sumatoria;
                    $tbl_det .= '
                            <tr><td>' . $programa . '</td><td>' . $proyecto . '</td><td>' . $actividad . '</td><td>' . $objeto_gasto . '</td><td>' . $entidad_transf . '</td><td>' . $descripcion . '</td><td style="text-align: right;">' .  number_format($sumatoria, 2, ',', '.') . '</td></tr>
                            ';
                    $sumatoria = 0;

                }
                $sumatoria = $sumatoria + $value['precio_total'];

                $programa = $value['programa'];
                $proyecto = $value['proyecto'];
                $actividad = $value['actividad'];
                $objeto_gasto = $value['cod_partida'];
                $entidad_transf = $value['codigo_transf'];
                $descripcion = $value['nombre_partida'];
                $partida = $value['nombre_partida'];
            }


        }

        $total_sum = $total_sum + $sumatoria;
        $total_planilla = $total_planilla + $total_sum;
        $tbl_det .= '
                    <tr><td>' . $programa . '</td><td>' . $proyecto . '</td><td>' . $actividad . '</td><td>' . $objeto_gasto . '</td><td>' . $entidad_transf . '</td><td>' . $descripcion . '</td><td style="text-align: right;">' .  number_format($sumatoria, 2, ',', '.') . '</td></tr>
                    <tr><td colspan="6" style="text-align: center">Total Categoria</td><td style="text-align: right;">'.number_format($total_sum, 2, ',', '.').'</td></tr>
                    <tr><td colspan="6" style="text-align: center">Total Planilla </td><td style="text-align: right;">'.number_format($total_planilla, 2, ',', '.').'</td></tr>
                    ';
        $tbl_det = '&nbsp;&nbsp;<span style="font-size: 7pt;"><b>IMPUTACION</b></span> <br>
                                <table border="1" style="font-size: 7pt;"> 
                                <tr style="font-weight: bold;"><th width="6%">PROG</th><th width="5%">PROY</th><th width="7%">ACTIV</th><th width="10%">OBJ. GASTO</th><th width="9%">ENT. TRF.</th><th width="53%">DESCRIPCION</th><th width="10%">IMPORTE</th></tr>
                                
                                '.$tbl_det.'</table>';
        $this->writeHTML ($tbl_det);

        //retenciones
        $tbl_reten = '<br>&nbsp;&nbsp;<span style="font-size: 7pt;"><b>RETENCIONES</b></span> <br>
                    <table border="1" style="font-size: 7pt;">
                    <tr style="font-weight: bold; text-align: center;"><th width="10%">CONCEPTO</th><th width="15%">ACREEDOR</th><th width="30%">DESCRIPCION</th><th width="10%">MONTO</th></tr>
                    ';
        foreach($this->retencion as $reten){
            if($categoria == $reten['categoria_prog']){
                $tbl_reten .='<tr><td style="text-align: left;" width="10%">'.$reten['categoria_prog'].'</td><td style="text-align: left;" width="15%">'.$reten['retencion'].'</td><td style="text-align: left;" width="30%">'.ucwords(strtolower($reten['desc_retencion'])).'</td><td style="text-align: right;" width="10%">'.number_format($reten['monto'], 2, ',', '.').'</td></tr>';
                $total_retencion += $reten['monto'];
            }
        }
        $tbl_reten .='<tr><td colspan="3" style="text-align: center">Total Retenciones</td><td style="text-align: right; font-weight: bold;">'.number_format($total_retencion, 2, ',', '.').'</td></tr>
                      </table>';
        $this->writeHTML ($tbl_reten);
        //retenciones
    }
}
?>