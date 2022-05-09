<?php
// Extend the TCPDF class to create custom MultiRow
class RPlanillaPresupuestariaItemPDF extends  ReportePDF {
    var $datos_titulo;
    var $datos_detalle;
    var $ancho_hoja;
    var $gerencia;
    var $numeracion;
    var $ancho_sin_totales;
    var $cantidad_columnas_estaticas;

    var $programa;

    function setDatos($datos) {
        $this->datos = $datos; //var_dump($datos);exit;
        $this->programa = $this->datos[0]['programa'];

    }

    function Header() {
        $this->Image(dirname(__FILE__) . '/../../lib/imagenes/logos/logo.jpg', 16, 5, 30, 10);
        $this->ln(5);
        $this->SetFont('', 'B', 12);
        $this->Cell(0, 5, "Planilla Presupuestaria", 0, 1, 'C');

        $this->SetFont('', '', 10);
        $tbl_head = '<table border="0" style="font-size: 9pt;">
                        <tr><td style="text-align: center">Modalidad  % </td><td style="text-align: center">Gestión ' . $this->datos[0]['gestion'] . '</td><td style="text-align: center">Version 1</td></tr>
                        </table>
                        ';
        $this->writeHTML($tbl_head);


        $this->SetFont('', 'B', 7);

        $this->Cell(50, 3.5, 'Entidad', '', 0, 'L');
        $this->Cell(140, 3.5, $this->datos[0]['entidad'], '', 0, 'L');

        $this->ln();

        $this->Cell(50, 3.5, 'Dirección Administrativa', '', 0, 'L');
        $this->Cell(140, 3.5, $this->datos[0]['dir_admin'], '', 0, 'L');

        $this->ln();

        $this->Cell(10, 3.5, 'Ue  '.$this->datos[0]['ue'], '', 0, 'C');
        $this->Cell(15, 3.5, 'Prog.  '.$this->programa, '', 0, 'C');
        $this->Cell(10, 3.5, 'Proy.  0', '', 0, 'C');
        $this->Cell(40, 3.5, '', '', 0, 'C');
        $this->Cell(20, 3.5, 'Actividad  '.$this->datos[0]['actividad'], '', 0, 'C');
        $this->Cell(15, 3.5, 'Fuente  '.$this->datos[0]['fuente'], '', 0, 'C');
        $this->Cell(20, 3.5, 'Organismo  '.$this->datos[0]['organismo'], '', 0, 'C');
        $this->Cell(20, 3.5, 'Obj. del Gas.', '', 0, 'C');
        $this->Cell(5, 3.5, $this->datos[0]['objeto_gasto'], '', 0, 'C');
        $this->Cell(30, 3.5, 'Entidad de Transferencia', '', 0, 'C');
        $this->Cell(5, 3.5, '0', '', 0, 'C');

        $this->Ln(4);

        $this->Cell(20, 3.5, 'Item', '', 0, 'R');
        $this->Cell(15, 3.5, '', '', 0, 'R');
        $this->Cell(65, 3.5, 'Denominación Puesto', '', 0, 'L');
        $this->Cell(45, 3.5, 'Haber Basico', '', 0, 'R');
        $this->Cell(45, 3.5, 'Costo Anual', '', 0, 'R');

        $this->ancho_hoja = $this->getPageWidth() - PDF_MARGIN_LEFT - PDF_MARGIN_RIGHT - 10;
        $this->SetMargins(5, 40, 5);

    }


    function generarReporte(){

        $this->setFontSubsetting(false);
        $this->AddPage();

        //iniciacion de datos
        $this->numeracion = 1;
        $empleados_gerencia = 0;

        $total_haber = 0;
        $total_costo = 0;

        $total_haber_plani = 0;
        $total_costo_plani = 0;

        $total_items = 0;



        $this->tablewidths = array(20, 15, 65, 45, 45);
        $this->tablealigns = array('R', 'C', 'L', 'R', 'R');
        $this->tablenumbers = array(0, 0, 0, 2, 2);

        foreach ($this->datos as $key => $value) {


            //Si cambia la gerencia
            if ($this->programa != $value['programa']) {
                $this->ln();
                //generar subtotales
                $this->SetFont('','B',7);
                $this->Cell(100,3,'SubTotal Planilla Presupuestaria: ','',0,'R');
                $this->Cell(45,3,number_format($total_haber,2),'T',0,'R');
                $this->Cell(45,3,number_format($total_costo,2),'T',0,'R');


                $this->ln(10);
                $this->Cell(77,3,'Total Items '.$this->gerencia . ' : ' .$empleados_gerencia,'',0,'R');

                $this->programa = $value['programa'];

                $total_items +=  $empleados_gerencia;

                $this->numeracion = 1;

                $total_haber_plani += $total_haber;
                $total_costo_plani += $total_costo;

                $total_haber = 0;
                $total_costo = 0;


                //crear nueva pagina y cambiar de gerencia
                $empleados_gerencia = 0;
                $this->AddPage();
            }

            $this->SetFont('','',7);
            if (strlen($value['cargo']) < 65){
                $this->UniRow(array(
                    $value['item'],'', $value['cargo'], $value['haber_basico'], $value['costo_anual']
                ),false,0);
            }else{
                $this->MultiRow(array(
                    $value['item'], '',$value['cargo'], $value['haber_basico'], $value['costo_anual']
                ),false,0);
            }

            //suma categoria
            $total_haber += $value['haber_basico'];
            $total_costo += $value['costo_anual'];


            $this->numeracion++;
            $empleados_gerencia++;


            $this->programa = $value['programa'];


        }

        $total_items +=  $empleados_gerencia;
        $total_haber_plani += $total_haber;
        $total_costo_plani += $total_costo;
        //generar subtotales
        $this->SetFont('','B',7);
        $this->Cell(100,3,'SubTotal Planilla Presupuestaria: ','',0,'R');
        $this->Cell(45,3,number_format($total_haber,2),'T',0,'R');
        $this->Cell(45,3,number_format($total_costo,2),'T',0,'R');
        $this->ln();
        $this->Cell(100,3,'Totales: ','',0,'R');
        $this->Cell(45,3,number_format($total_haber_plani,2),'T',0,'R');
        $this->Cell(45,3,number_format($total_costo_plani,2),'T',0,'R');
        $this->ln(10);
        $this->Cell(77,3,'Total Items : ' .$empleados_gerencia,'',0,'R');
        $this->ln();
        $this->Cell(77,3,'Totales Items : ' .$total_items,'T',0,'R');
    }
}
?>