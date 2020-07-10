<?php
class RDetalleOtrosIngresosXLS
{
    private $docexcel;
    private $objWriter;
    private $numero;
    private $equivalencias=array();
    private $objParam;
    var $datos_detalle;
    var $datos_titulo;
    public  $url_archivo;
    function __construct(CTParametro $objParam)
    {
        $this->objParam = $objParam;
        $this->url_archivo = "../../../reportes_generados/".$this->objParam->getParametro('nombre_archivo');
        //ini_set('memory_limit','512M');
        set_time_limit(400);
        $cacheMethod = PHPExcel_CachedObjectStorageFactory:: cache_to_phpTemp;
        $cacheSettings = array('memoryCacheSize'  => '10MB');
        PHPExcel_Settings::setCacheStorageMethod($cacheMethod, $cacheSettings);

        $this->docexcel = new PHPExcel();
        $this->docexcel->getProperties()->setCreator("PXP")
            ->setLastModifiedBy("PXP")
            ->setTitle($this->objParam->getParametro('titulo_archivo'))
            ->setSubject($this->objParam->getParametro('titulo_archivo'))
            ->setDescription('Reporte "'.$this->objParam->getParametro('titulo_archivo').'", generado por el framework PXP')
            ->setKeywords("office 2007 openxml php")
            ->setCategory("Report File");


        $this->equivalencias=array( 0=>'A',1=>'B',2=>'C',3=>'D',4=>'E',5=>'F',6=>'G',7=>'H',8=>'I',
            9=>'J',10=>'K',11=>'L',12=>'M',13=>'N',14=>'O',15=>'P',16=>'Q',17=>'R',
            18=>'S',19=>'T',20=>'U',21=>'V',22=>'W',23=>'X',24=>'Y',25=>'Z',
            26=>'AA',27=>'AB',28=>'AC',29=>'AD',30=>'AE',31=>'AF',32=>'AG',33=>'AH',
            34=>'AI',35=>'AJ',36=>'AK',37=>'AL',38=>'AM',39=>'AN',40=>'AO',41=>'AP',
            42=>'AQ',43=>'AR',44=>'AS',45=>'AT',46=>'AU',47=>'AV',48=>'AW',49=>'AX',
            50=>'AY',51=>'AZ',
            52=>'BA',53=>'BB',54=>'BC',55=>'BD',56=>'BE',57=>'BF',58=>'BG',59=>'BH',
            60=>'BI',61=>'BJ',62=>'BK',63=>'BL',64=>'BM',65=>'BN',66=>'BO',67=>'BP',
            68=>'BQ',69=>'BR',70=>'BS',71=>'BT',72=>'BU',73=>'BV',74=>'BW',75=>'BX',
            76=>'BY',77=>'BZ');

    }

    public function addHoja($name,$index){

        $this->docexcel->createSheet($index)->setTitle($name);
        $this->docexcel->setActiveSheetIndex($index);
        return $this->docexcel;
    }


    function imprimeDatos()
    {
        $styleTitulos3 = array(
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
        );

        $styleTitulos2 = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 9,
                'name'  => 'Arial',
                'color' => array(
                    'rgb' => 'FFFFFF'
                )

            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array(
                    'rgb' => '0066CC'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            ));

        $styleTitulos1 = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 9,
                'name'  => 'Arial',
                'color' => array(
                    'rgb' => 'FFFFFF'
                )

            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array(
                    'rgb' => '626eba'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            ));

        $styleTitulos3 = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 9,
                'name'  => 'Arial',
                'color' => array(
                    'rgb' => 'FFFFFF'
                )

            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array(
                    'rgb' => '3287c1'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            ));

        $this->styleVacio = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 8,
                'name'  => 'Arial'
            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array(
                    'rgb' => 'FA8072'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            )
        );

        $this->numero = 1;
        $fila = 2;
        $datos = $this->objParam->getParametro('datos');//var_dump($datos);exit;
        $tipo = $this->objParam->getParametro('tipo');

        $numberFormat = '#,##0.00';

        $index = 0;
        $color_pestana = array('ff0000','1100ff','55ff00','3ba3ff','ff4747','697dff','78edff','ba8cff',
            'ff80bb','ff792b','ffff5e','52ff97','bae3ff','ffaf9c','bfffc6','b370ff','ffa8b4','7583ff','9aff17','ff30c8');
        $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0,2);

        $this->addHoja('Reporte Global Otros Ingresos',$index);
        $this->docexcel->getActiveSheet()->getTabColor()->setRGB($color_pestana[$index]);

        //$this->docexcel->getActiveSheet()->getStyle('A1:H1')->getAlignment()->setWrapText(true);
        $this->docexcel->getActiveSheet()->getStyle('A1:I1')->getAlignment()->setWrapText(true);
        //$this->docexcel->getActiveSheet()->getStyle('A1:H1')->applyFromArray($styleTitulos3);
        $this->docexcel->getActiveSheet()->getStyle('A1:I1')->applyFromArray($styleTitulos3);

        $fila=2;
        $this->numero=1;
        $this->docexcel->getActiveSheet()->setTitle('Reporte Global Otros Ingresos');
        $this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(10);//Numero
        $this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(35);//gerencia
        $this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(40);//nombre
        $this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(15);//ci
        $this->docexcel->getActiveSheet()->getColumnDimension('E')->setWidth(15);//refrigerio
        $this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(15);//viatico
        $this->docexcel->getActiveSheet()->getColumnDimension('G')->setWidth(15);//prima
        $this->docexcel->getActiveSheet()->getColumnDimension('H')->setWidth(15);//hora/vuelo
        $this->docexcel->getActiveSheet()->getColumnDimension('I')->setWidth(15);//total_ingreso
        //$this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(15);//rc_iva



        $this->docexcel->getActiveSheet()->setCellValue('A1','Nro');
        $this->docexcel->getActiveSheet()->setCellValue('B1','Gerencia');
        $this->docexcel->getActiveSheet()->setCellValue('C1','Nombre Completo');
        $this->docexcel->getActiveSheet()->setCellValue('D1','CI.');
        $this->docexcel->getActiveSheet()->setCellValue('E1','Refrigerio.');
        $this->docexcel->getActiveSheet()->setCellValue('F1','Viatico');
        $this->docexcel->getActiveSheet()->setCellValue('G1','Sueldo Abril');
        $this->docexcel->getActiveSheet()->setCellValue('H1','Sueldo Mayo');
        $this->docexcel->getActiveSheet()->setCellValue('I1','Total Otros/Ingresos');
        //$this->docexcel->getActiveSheet()->setCellValue('F1','RC-IVA');

        $nombre_funcionario = '';

        if($tipo == 'formulario'){

            foreach ($datos as $value){

                if ($nombre_funcionario != '' && $nombre_funcionario != $value['nombre_empleado']) {
                    $fila++;
                    $this->numero++;
                }

                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $this->numero);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['gerencia']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['nombre_empleado']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['ci']);

                $ingresos = json_decode(preg_replace('[\n|\r|\n\r]', '', $value['otros_ingresos']));
                foreach ($ingresos as $obj) {
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $obj->refrigerio);
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, $obj->viatico);
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, 0);
                    //$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $obj->horas_vuelo);
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=E'.$fila.'+F'.$fila.'+G'.$fila);
                }

                $nombre_funcionario = $value['nombre_empleado'];
            }

            $index++;
            $codigo_pes = '';
            $nombre_funcionario = '';
            foreach ($datos as $value) {
                if ($codigo_pes == '' || $codigo_pes != $value['categoria_prog']) {
                    $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0, 2);
                    $this->addHoja($value['categoria_prog'], $index);
                    $this->docexcel->getActiveSheet()->getTabColor()->setRGB($color_pestana[$index]);
                    $this->docexcel->getActiveSheet()->getStyle('A1:H1')->getAlignment()->setWrapText(true);
                    $this->docexcel->getActiveSheet()->getStyle('A1:H1')->applyFromArray($styleTitulos3);
                    $fila = 2;
                    $this->numero = 1;
                    $this->docexcel->getActiveSheet()->setTitle($value['categoria_prog']);
                    $this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(10);//Numero
                    $this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(35);//gerencia
                    $this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(40);//nombre
                    $this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(15);//ci
                    $this->docexcel->getActiveSheet()->getColumnDimension('E')->setWidth(15);//refrigerio
                    $this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(15);//viatico
                    $this->docexcel->getActiveSheet()->getColumnDimension('G')->setWidth(15);//prima
                    //$this->docexcel->getActiveSheet()->getColumnDimension('H')->setWidth(15);//hora/vuelo
                    $this->docexcel->getActiveSheet()->getColumnDimension('H')->setWidth(15);//total_ingreso


                    $this->docexcel->getActiveSheet()->setCellValue('A1', 'Nro');
                    $this->docexcel->getActiveSheet()->setCellValue('B1', 'Gerencia');
                    $this->docexcel->getActiveSheet()->setCellValue('C1', 'Nombre Completo');
                    $this->docexcel->getActiveSheet()->setCellValue('D1', 'CI.');
                    $this->docexcel->getActiveSheet()->setCellValue('E1', 'Refrigerio.');
                    $this->docexcel->getActiveSheet()->setCellValue('F1', 'Viatico');
                    $this->docexcel->getActiveSheet()->setCellValue('G1', 'Retroactivo');
                    //$this->docexcel->getActiveSheet()->setCellValue('H1', 'Horas/Vuelo');
                    $this->docexcel->getActiveSheet()->setCellValue('H1', ' Total Otros/Ingresos');

                    $index++;
                    $nombre_funcionario = '';
                }

                if ($nombre_funcionario != '' && $nombre_funcionario != $value['nombre_empleado']) {
                    $fila++;
                    $this->numero++;
                }

                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $this->numero);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['gerencia']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['nombre_empleado']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['ci']);

                $ingresos = json_decode(preg_replace('[\n|\r|\n\r]', '', $value['otros_ingresos']));
                foreach ($ingresos as $obj) {
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $obj->refrigerio);
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, $obj->viatico);
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, 0);
                    //$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $obj->horas_vuelo);
                    $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=E'.$fila.'+F'.$fila.'+G'.$fila);
                }


                $nombre_funcionario = $value['nombre_empleado'];
                $codigo_pes = $value['categoria_prog'];

            }
            $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0, 2);

        }else {
            foreach ($datos as $value) {

                if ($nombre_funcionario != '' && $nombre_funcionario != $value['nombre_empleado']) {
                    $fila++;
                    $this->numero++;
                }

                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $this->numero);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['gerencia']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['nombre_empleado']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['ci']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $value['monto2']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, $value['monto3']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, $value['monto6']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $value['monto7']);
                //$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=E'.$fila.'+F'.$fila.'+G'.$fila);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, '=E'.$fila.'+F'.$fila.'+G'.$fila.'+H'.$fila);

                $nombre_funcionario = $value['nombre_empleado'];
            }

            $index++;
            $codigo_pes = '';
            $nombre_funcionario = '';
            foreach ($datos as $value) { //var_dump($value['gerencia'].' '.$value['nombre_empleado']);
                if ($codigo_pes == '' || $codigo_pes != $value['categoria_prog']) {
                    $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0, 2);
                    $this->addHoja($value['categoria_prog'], $index);
                    $this->docexcel->getActiveSheet()->getTabColor()->setRGB($color_pestana[$index]);
                    //$this->docexcel->getActiveSheet()->getStyle('A1:H1')->getAlignment()->setWrapText(true);
                    $this->docexcel->getActiveSheet()->getStyle('A1:I1')->getAlignment()->setWrapText(true);
                    //$this->docexcel->getActiveSheet()->getStyle('A1:H1')->applyFromArray($styleTitulos3);
                    $this->docexcel->getActiveSheet()->getStyle('A1:I1')->applyFromArray($styleTitulos3);
                    $fila = 2;
                    $this->numero = 1;
                    $this->docexcel->getActiveSheet()->setTitle($value['categoria_prog']);
                    $this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(10);//Numero
                    $this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(35);//gerencia
                    $this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(40);//nombre
                    $this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(15);//ci
                    $this->docexcel->getActiveSheet()->getColumnDimension('E')->setWidth(15);//refrigerio
                    $this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(15);//viatico
                    $this->docexcel->getActiveSheet()->getColumnDimension('G')->setWidth(15);//prima
                    $this->docexcel->getActiveSheet()->getColumnDimension('H')->setWidth(15);//hora/vuelo
                    $this->docexcel->getActiveSheet()->getColumnDimension('I')->setWidth(15);//total_ingreso


                    $this->docexcel->getActiveSheet()->setCellValue('A1', 'Nro');
                    $this->docexcel->getActiveSheet()->setCellValue('B1', 'Gerencia');
                    $this->docexcel->getActiveSheet()->setCellValue('C1', 'Nombre Completo');
                    $this->docexcel->getActiveSheet()->setCellValue('D1', 'CI.');
                    $this->docexcel->getActiveSheet()->setCellValue('E1', 'Refrigerio.');
                    $this->docexcel->getActiveSheet()->setCellValue('F1', 'Viatico');
                    $this->docexcel->getActiveSheet()->setCellValue('G1', 'Sueldo Abril');
                    $this->docexcel->getActiveSheet()->setCellValue('H1', 'Sueldo Mayo');
                    $this->docexcel->getActiveSheet()->setCellValue('I1', 'Total Otros Ingresos');

                    $index++;
                    $nombre_funcionario = '';
                }

                if ($nombre_funcionario != '' && $nombre_funcionario != $value['nombre_empleado']) {
                    $fila++;
                    $this->numero++;
                }


                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $this->numero);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['gerencia']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['nombre_empleado']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['ci']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $value['monto2']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, $value['monto3']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, $value['monto6']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $value['monto7']);
                //$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=E'.$fila.'+F'.$fila.'+G'.$fila);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, '=E'.$fila.'+F'.$fila.'+G'.$fila.'+H'.$fila);

                $nombre_funcionario = $value['nombre_empleado'];
                $codigo_pes = $value['categoria_prog'];
            }
            $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0, 2);
        }
    }

    function obtenerFechaEnLetra($fecha){
        setlocale(LC_ALL,"es_ES@euro","es_ES","esp");
        $dia= date("d", strtotime($fecha));
        $anno = date("Y", strtotime($fecha));
        // var_dump()
        $mes = array('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre');
        $mes = $mes[(date('m', strtotime($fecha))*1)-1];
        return $dia.' de '.$mes.' del '.$anno;
    }
    function generarReporte(){
        $this->imprimeDatos();
        $this->docexcel->setActiveSheetIndex(0);
        $this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
        $this->objWriter->save($this->url_archivo);
    }

}
?>