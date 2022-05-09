<?php
// Extend the TCPDF class to create custom MultiRow
class RElaboracionPlaniC31PDF extends  ReportePDF {
    var $datos_titulo;
    var $datos_detalle;
    var $ancho_hoja;
    var $gerencia;
    var $numeracion;
    var $ancho_sin_totales;
    var $cantidad_columnas_estaticas;

    var $categoria;
    var $modalidad;
    var $lugar;

    var $bandera_header;

    function setDatos($datos) {
        $this->datos = $datos; //var_dump($datos);exit;
        $this->categoria = $this->datos[0]['categoria_prog'];
        $this->modalidad = substr($this->datos[0]['desc_programa'],0,40);
        $this->lugar = $this->datos[0]['lugar'];

        $this->bandera_header = 1;
    }

    function Header() {
        if ($this->bandera_header == 2) {
            $this->Image(dirname(__FILE__) . '/../../lib/imagenes/logos/logo.jpg', 16, 5, 30, 10);
            $this->ln(5);
            $this->SetFont('', 'B', 12);
            $this->Cell(0, 5, "Planilla Mensual de Sueldos y Salarios", 0, 1, 'C');


            $tbl_head = '<table border="0" style="font-size: 9pt;">
                        <tr><td style="text-align: center">Gestion ' . $this->datos[0]['gestion'] . '</td><td style="text-align: center">Proceso ' . $this->datos[0]['periodo'] . '</td><td style="text-align: center">' . $this->modalidad . '</td></tr>
                        </table>
                        ';

            $this->writeHTML($tbl_head);

            $this->tablewidths = array(10, 52, 15, 10, 13, 16, 16, 15, 16, 16, 15, 15, 15, 15, 16);
            $this->tablealigns = array('L', 'L', 'C', 'C', 'C', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R');
            $this->tablenumbers = array(0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2);

            $this->SetFont('', 'B', 6);

            $this->Cell(10, 3.5, 'Numero', 'LT', 0, 'C');
            $this->Cell(52, 3.5, 'Nombre Completo', 'T', 0, 'C');
            $this->Cell(15, 3.5, 'C.I.', 'T', 0, 'C');
            $this->Cell(10, 3.5, 'Item', 'T', 0, 'C');
            $this->Cell(13, 3.5, 'Dias', 'T', 0, 'C');
            $this->Cell(16, 3.5, 'Haber', 'T', 0, 'C');
            $this->Cell(16, 3.5, 'Bono', 'T', 0, 'C');
            $this->Cell(15, 3.5, 'Subsidios', 'T', 0, 'C');
            $this->Cell(16, 3.5, 'Otros', 'T', 0, 'C');
            $this->Cell(16, 3.5, 'Total', 'T', 0, 'C');
            $this->Cell(15, 3.5, 'RC - IVA', 'T', 0, 'C');
            $this->Cell(15, 3.5, 'AFP', 'T', 0, 'C');
            $this->Cell(15, 3.5, 'Otros', 'T', 0, 'C');
            $this->Cell(15, 3.5, 'Total', 'T', 0, 'C');
            $this->Cell(16, 3.5, 'Liquido', 'RT', 0, 'C');
            $this->ln();

            $this->Cell(10, 3.5, '', 'LB', 0, 'C');
            $this->Cell(52, 3.5, '', 'B', 0, 'C');
            $this->Cell(15, 3.5, '', 'B', 0, 'C');
            $this->Cell(10, 3.5, '', 'B', 0, 'C');
            $this->Cell(13, 3.5, 'Trabajados', 'B', 0, 'C');
            $this->Cell(16, 3.5, 'Basico', 'B', 0, 'C');
            $this->Cell(16, 3.5, 'Antiguedad', 'B', 0, 'C');
            $this->Cell(15, 3.5, '', 'B', 0, 'C');
            $this->Cell(16, 3.5, 'Ingresos', 'B', 0, 'C');
            $this->Cell(16, 3.5, 'Ingresos', 'B', 0, 'C');
            $this->Cell(15, 3.5, '', 'B', 0, 'C');
            $this->Cell(15, 3.5, '', 'B', 0, 'C');
            $this->Cell(15, 3.5, 'Descuentos', 'B', 0, 'C');
            $this->Cell(15, 3.5, 'Descuento', 'B', 0, 'C');
            $this->Cell(16, 3.5, 'Pagable', 'RB', 0, 'C');
            $columnas = 0;

            $this->Ln(5);

            $tbl_head = '<span style="font-size: 7pt">UE ' . $this->datos[0]['ue'] . ' Fuente ' . $this->datos[0]['fuente'] . ' Organismo ' . $this->datos[0]['organismo'] . ' Num Planilla </span>
                        <br><span style="font-size: 7pt">' . $this->lugar . '</span>
                        ';

            $this->writeHTML($tbl_head);

            $this->ancho_hoja = $this->getPageWidth() - PDF_MARGIN_LEFT - PDF_MARGIN_RIGHT - 10;
            $this->SetMargins(5, 40, 5);
        }else {
            $this->Image(dirname(__FILE__).'/../../lib/imagenes/logos/logo.jpg', 16,5,30,10);
            $this->ln(5);
            $this->SetFont('','B',12);
            $this->Cell(0,5,"Planilla Mensual de Sueldos y Salarios",0,1,'C');
            $this->ancho_hoja = $this->getPageWidth() - PDF_MARGIN_LEFT - PDF_MARGIN_RIGHT - 10;
            $this->SetMargins(5, 40, 5);
        }

    }

    function headerPage(){

        $this->bandera_header = 1;
        //$this->Header();
        $this->AddPage();
        $tbl_det = '<table border="0" style="font-size: 12pt;">
                    <tr><td style="text-align: right">Gestion</td><td style="text-align: left">'.$this->datos[0]['gestion'].'</td></tr>
                    <tr><td style="text-align: right">Entidad</td><td style="text-align: left">'.$this->datos[0]['entidad'].'</td></tr>
                    <tr><td style="text-align: right">Dirección Administrativa</td><td style="text-align: left">'.$this->datos[0]['dir_admin'].'</td></tr>
                    <tr><td style="text-align: right">Modalidad</td><td style="text-align: left">'.$this->modalidad.'</td></tr>
                    <tr><td style="text-align: right">Tipo Proceso</td><td style="text-align: left">'.$this->datos[0]['tipo_proceso'].'</td></tr>
                    <tr><td style="text-align: right">Proceso</td><td style="text-align: left">'.$this->datos[0]['periodo'].'</td></tr>
                    <tr><td style="text-align: right">Fecha Inicio Proceso</td><td style="text-align: left">'.date_format(date_create($this->datos[0]['fecha_ini']), 'd/m/y').'</td></tr>
                    <tr><td style="text-align: right">Fecha Fin Proceso</td><td style="text-align: left">'.date_format(date_create($this->datos[0]['fecha_fin']), 'd/m/y').'</td></tr>
                    <tr><td style="text-align: right">Minimo Nacional</td><td style="text-align: left">2122</td></tr>
                    <tr><td style="text-align: right">Minimo Institucional</td><td style="text-align: left">2122</td></tr>
                    <tr><td style="text-align: right">Minimos Nacionales para el calculo de las AFPs</td><td style="text-align: left">0</td></tr>
                    <tr><td style="text-align: right">Minimos Nacionales para el calculo del RC-IVA</td><td style="text-align: left">4</td></tr>
                    <tr><td style="text-align: right">Cambio del Dolar Anterior</td><td style="text-align: left">0</td></tr>
                    <tr><td style="text-align: right">Cambio del Dolar Actual</td><td style="text-align: left">0</td></tr>
                    <tr><td style="text-align: right">Cambio  UFV Anterior</td><td style="text-align: left">2.32586</td></tr>
                    <tr><td style="text-align: right">Cambio  UFV Actual</td><td style="text-align: left">2.33187</td></tr>
                    <tr><td style="text-align: right">Limite de descuento en %</td><td style="text-align: left">60</td></tr>
                    <tr><td style="text-align: right">Fecha Elaboracion</td><td style="text-align: left">'.date_format(date_create($this->datos[0]['fecha_planilla']), 'd/m/y').'</td></tr>
                    </table>';
        $this->writeHTML ($tbl_det);

    }

    function generarReporte(){

        $this->setFontSubsetting(false);
        //$this->AddPage();


        //iniciacion de datos

        $this->numeracion = 1;
        $empleados_gerencia = 0;
        $empleados_lugar = 0;
        $total_haber = 0;
        $total_bono = 0;
        $total_otros_ing = 0;
        $total_total_ing = 0;
        $total_rc_iva = 0;
        $total_afp_lab = 0;
        $total_descuento = 0;
        $total_tot_descuento = 0;
        $total_liquido = 0;
        $total_subsidio = 0;

        $total_haber_lugar = 0;
        $total_bono_lugar = 0;
        $total_otros_ing_lugar = 0;
        $total_total_ing_lugar = 0;
        $total_rc_iva_lugar = 0;
        $total_afp_lab_lugar = 0;
        $total_descuento_lugar = 0;
        $total_tot_descuento_lugar = 0;
        $total_liquido_lugar = 0;
        $total_subsidio_lugar = 0;

        //$this->lugar = '';

        $this->tablewidths=array(10,52,15,10,13,16,16,15,16,16,15,15,15,15,16);
        $this->headerPage();
        $this->bandera_header = 2;
        //$this->Header();
        $this->AddPage();
        foreach ($this->datos as $key => $value) {




            if ($this->lugar != $value['lugar']) {

                $this->SetFont('','B',7);
                $this->Cell(100,3,'Total '.$this->lugar,'',0,'R');
                $this->Cell(16,3,number_format($total_haber_lugar,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_bono_lugar,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_subsidio_lugar,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_otros_ing_lugar,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_total_ing_lugar,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_rc_iva_lugar,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_afp_lab_lugar,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_descuento_lugar,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_tot_descuento_lugar,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_liquido_lugar,2),'T',0,'R');




                $total_haber_lugar = 0;
                $total_bono_lugar = 0;
                $total_otros_ing_lugar = 0;
                $total_total_ing_lugar = 0;
                $total_rc_iva_lugar = 0;
                $total_afp_lab_lugar = 0;
                $total_descuento_lugar = 0;
                $total_tot_descuento_lugar = 0;
                $total_liquido_lugar = 0;
                $total_subsidio_lugar = 0;

                //crear nueva pagina y cambiar de gerencia
                //$empleados_gerencia = 0;
                $this->lugar = $value['lugar'];

                if ($value['categoria_prog'] == $this->datos[$key-1]['categoria_prog']){
                    $this->ln(5);
                    $this->Cell(77,3,'Total Funcionarios ' .$this->datos[$key-1]['lugar'].': '.$empleados_lugar,'',0,'R');
                    $empleados_lugar = 0;
                    $this->AddPage();
                }

            }

            //Si cambia la gerencia
            if ($this->categoria != $value['categoria_prog']) {
                $this->ln();
                //generar subtotales
                $this->SetFont('','B',7);
                $this->Cell(100,3,'Total Planilla : ','',0,'R');
                $this->Cell(16,3,number_format($total_haber,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_bono,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_subsidio,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_otros_ing,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_total_ing,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_rc_iva,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_afp_lab,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_descuento,2),'T',0,'R');
                $this->Cell(15,3,number_format($total_tot_descuento,2),'T',0,'R');
                $this->Cell(16,3,number_format($total_liquido,2),'T',0,'R');

                $this->ln(5);
                $this->Cell(77,3,'Total Funcionarios ' .$this->datos[$key-1]['lugar'].': '.$empleados_lugar,'',0,'R');

                $this->ln(10);
                $this->Cell(77,3,'Total Funcionarios '.$this->gerencia . ' : ' .$empleados_gerencia,'',0,'R');

                $this->categoria = $value['categoria_prog'];
                //$this->modalidad =  $value['categoria_prog'] == '5.CIJ' ? 'REGIONAL COBIJA' : $value['categoria_prog'] == '6.EVE' ? 'PERSONAL EVENTUAL' : substr($value['desc_programa'],0,40);
                if ($value['categoria_prog'] == '5.CIJ') {
                    $this->modalidad =  'REGIONAL COBIJA';
                }else if ($value['categoria_prog'] == '6.EVE') {
                    $this->modalidad = 'PERSONAL EVENTUAL';
                }else {
                    $this->modalidad = substr($value['desc_programa'],0,40);
                }
                $this->numeracion = 1;

                $total_haber = 0;
                $total_bono = 0;
                $total_otros_ing = 0;
                $total_total_ing = 0;
                $total_rc_iva = 0;
                $total_afp_lab = 0;
                $total_descuento = 0;
                $total_tot_descuento = 0;
                $total_liquido = 0;
                $total_subsidio = 0;

                //crear nueva pagina y cambiar de gerencia
                $empleados_lugar = 0;
                $empleados_gerencia = 0;
                $this->headerPage();
                $this->bandera_header = 2;

                $this->AddPage();
            }

            $this->SetFont('','',6);
            if (strlen($value['funcionario']) < 35){
                $this->UniRow(array(
                    $this->numeracion, $value['funcionario'], $value['ci'], $value['item'], $value['dias'], $value['haber'], $value['bono'], $value['subsidio'], $value['otros_ing'],
                    $value['total_ing'], $value['rc_iva'], $value['afp_lab'], $value['descuento'], $value['total_descuento'], $value['liquido']
                ),false,0);
            }else{
                $this->MultiRow(array(
                    $this->numeracion, $value['funcionario'], $value['ci'], $value['item'], $value['dias'], $value['haber'], $value['bono'], $value['subsidio'], $value['otros_ing'],
                    $value['total_ing'], $value['rc_iva'], $value['afp_lab'], $value['descuento'], $value['total_descuento'], $value['liquido']
                ),false,0);
            }
            //suma lugar
            $total_haber_lugar += $value['haber'];
            $total_bono_lugar += $value['bono'];
            $total_otros_ing_lugar += $value['otros_ing'];
            $total_total_ing_lugar += $value['total_ing'];
            $total_rc_iva_lugar += $value['rc_iva'];
            $total_afp_lab_lugar += $value['afp_lab'];
            $total_descuento_lugar += $value['descuento'];
            $total_tot_descuento_lugar += $value['total_descuento'];
            $total_liquido_lugar += $value['liquido'];
            $total_subsidio_lugar += $value['subsidio'];

            //suma categoria
            $total_haber += $value['haber'];
            $total_bono += $value['bono'];
            $total_otros_ing += $value['otros_ing'];
            $total_total_ing += $value['total_ing'];
            $total_rc_iva += $value['rc_iva'];
            $total_afp_lab += $value['afp_lab'];
            $total_descuento += $value['descuento'];
            $total_tot_descuento += $value['total_descuento'];
            $total_liquido += $value['liquido'];
            $total_subsidio += $value['subsidio'];

            $this->numeracion++;
            $empleados_gerencia++;
            $empleados_lugar++;

            if ($value['categoria_prog'] == '5.CIJ') {
                $this->modalidad =  'REGIONAL COBIJA';
            }else if ($value['categoria_prog'] == '6.EVE') {
                $this->modalidad = 'PERSONAL EVENTUAL';
            }else {
                $this->modalidad = substr($value['desc_programa'],0,40);
            }

            $this->categoria = $value['categoria_prog'];
            $this->lugar = $value['lugar'];

        }

        $this->SetFont('','B',7);
        $this->Cell(100,3,'Total '.$this->lugar,'',0,'R');
        $this->Cell(16,3,number_format($total_haber_lugar,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_bono_lugar,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_subsidio_lugar,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_otros_ing_lugar,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_total_ing_lugar,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_rc_iva_lugar,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_afp_lab_lugar,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_descuento_lugar,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_tot_descuento_lugar,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_liquido_lugar,2),'T',0,'R');
        $this->ln();
        //generar subtotales
        //$this->SetFont('','B',7);
        $this->Cell(100,3,'Total Planilla : ','',0,'R');
        $this->Cell(16,3,number_format($total_haber,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_bono,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_subsidio,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_otros_ing,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_total_ing,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_rc_iva,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_afp_lab,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_descuento,2),'T',0,'R');
        $this->Cell(15,3,number_format($total_tot_descuento,2),'T',0,'R');
        $this->Cell(16,3,number_format($total_liquido,2),'T',0,'R');
        $this->ln(5);
        $this->Cell(77,3,'Total Funcionarios ' .$this->lugar.': '.$empleados_lugar,'',0,'R');
        $this->ln(10);
        $this->Cell(77,3,'Total Funcionarios '.$this->gerencia . ' : ' .$empleados_gerencia,'',0,'R');
    }
}
?>