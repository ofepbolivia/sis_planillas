<?php
class RDetalleOtrosIngresosTableXLS
{
    private $docexcel;
    private $objWriter;
    private $numero;
    private $col=array();
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


        $this->col=array( 0=>'A',1=>'B',2=>'C',3=>'D',4=>'E',5=>'F',6=>'G',7=>'H',8=>'I',
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

    function definitionStyle() {
        $this->styleTitulos = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 9,
                'name'  => 'Arial',
                'color' => array(
                    'rgb' => '000000'
                )
            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array('rgb' => 'ffffff')
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_NONE
                )
            )
        );

        $this->styleTitulos1 = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 9,
                'name'  => 'Arial',
                'color' => array(
                    'rgb' => 'ffffff'
                )

            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array(
                    'rgb' => '4682b4'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_NONE
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
    }

    function array_sort_by(&$arrIni, $col, $order = SORT_ASC)
    {
        $arrAux = array();
        foreach ($arrIni as $key=> $row)
        {
            $arrAux[$key] = is_object($row) ? $arrAux[$key] = $row->$col : $row[$col];
            $arrAux[$key] = strtolower($arrAux[$key]);
        }
        array_multisort($arrAux, $order, $arrIni);
    }

    function imprimeDatos(){


        $this->definitionStyle();

        $datos = $this->objParam->getParametro('datos');//print_r($datos);exit;
        $gestion = $this->objParam->getParametro('gestion');
        $periodo = $this->objParam->getParametro('periodo');

        $fecha_desde =  date("d-m-Y",strtotime( "{$periodo}/01/{$gestion}"));//print_r($fecha_desde);exit;
        $fecha_hasta = date("d-m-Y",strtotime(date("d-m-Y",strtotime("$fecha_desde + 1 month"))."- 1 days"));

        $numberFormat = '#,##0.00';

        $index = 0;
        $color_pestana = array('ff0000','1100ff','55ff00','3ba3ff','ff4747','697dff','78edff','ba8cff',
            'ff80bb','ff792b','ffff5e','52ff97','bae3ff','ffaf9c','bfffc6','b370ff','ffa8b4','7583ff','9aff17','ff30c8');


        $this->addHoja('DETALLE OTROS INGRESOS',$index);

        $column_end = 26;
        $size_column = [
            10,30,15,15,15,15,15,30,15,15,
            15,15,15,15,20,15,30,15,20,15,
            15,20,15,15,20,15
        ];
        $column_name = [
            'C.I.','FUNCIONARIO', 'ESTADO', 'AREA', 'REGIONAL',
            'C31', 'DOCUMENTO','MONTO PAGO(Bs)','TASA NAC.(Bs)','TASA INT.(Bs)','MONTO CALCULADO(Bs)','FECHA PAGO',
            'C31', 'DOCUMENTO','MONTO PAGO (Bs)','FECHA PAGO', 'TOTAL VIÁTICO(ADM + OPE)(Bs)',
            'C31', 'MONTO PAGO (Bs)', 'FECHA PAGO',
            'C31', 'MONTO PAGO (Bs)', 'FECHA PAGO',
            'C31','MONTO PAGO (Bs)', 'FECHA PAGO'
        ];

        for($i=0; $i<$column_end; $i++){
            $this->docexcel->getActiveSheet()->getColumnDimension($this->col[$i])->setWidth($size_column[$i]);
        }

        $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0,7);
        $this->docexcel->getActiveSheet()->getTabColor()->setRGB($color_pestana[$index]);

        /*logo*/
        $objDrawing = new PHPExcel_Worksheet_Drawing();
        $objDrawing->setName('BoA ERP');
        $objDrawing->setDescription('BoA ERP');
        $objDrawing->setPath('../../lib/imagenes/logos/logo.jpg');
        $objDrawing->setCoordinates('A1');
        $objDrawing->setOffsetX(0);
        $objDrawing->setOffsetY(0);
        $objDrawing->setWidth(105);
        $objDrawing->setHeight(75);
        $objDrawing->setWorksheet($this->docexcel->getActiveSheet());
        /*logo*/

        /*Estilo Cabecera*/
        $row_header = 6;

        $this->docexcel->getActiveSheet()->getStyle('A1:'.$this->col[$column_end-1].'4')->applyFromArray($this->styleTitulos);
        $this->docexcel->getActiveSheet()->getStyle('A1:'.$this->col[$column_end-1].$row_header)->getAlignment()->setWrapText(true);

        $this->docexcel->getActiveSheet()->mergeCells('A1:'.$this->col[$column_end-1].'2');
        $this->docexcel->getActiveSheet()->setCellValue('A1','DETALLE OTROS INGRESOS');
        $this->docexcel->getActiveSheet()->mergeCells('A3:'.$this->col[$column_end-1].'3');
        $this->docexcel->getActiveSheet()->setCellValue('A3','(Importes expresados en Bolivianos)');
        $this->docexcel->getActiveSheet()->mergeCells('A4:'.$this->col[$column_end-1].'4');
        $this->docexcel->getActiveSheet()->setCellValue('A4','Pagos Del: '.date_format(date_create($fecha_desde),'d/m/Y').' Al: '.date_format(date_create($fecha_hasta),'d/m/Y'));

        $this->docexcel->getActiveSheet()->getStyle('A5:'.$this->col[4].$row_header)->applyFromArray($this->styleTitulos1);

        $this->docexcel->getActiveSheet()->mergeCells('A5:A'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('B5:B'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('C5:C'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('D5:D'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('E5:E'.$row_header);

        $this->styleTitulos1['fill']['color']['rgb'] = '00B167';
        $this->docexcel->getActiveSheet()->getStyle('F5:L'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('F5:L5');
        $this->docexcel->getActiveSheet()->setCellValue('F5','VIÁTICO ADMINISTRATIVO');

        $this->styleTitulos1['fill']['color']['rgb'] = 'B066BB';
        $this->docexcel->getActiveSheet()->getStyle('M5:P'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('M5:P5');
        $this->docexcel->getActiveSheet()->setCellValue('M5','VIÁTICO OPERATIVO');

        $col_tot_via = 16;
        $this->styleTitulos1['fill']['color']['rgb'] = '00B167';
        $this->docexcel->getActiveSheet()->getStyle('Q5:Q'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('Q5:Q'.$row_header);

        $this->styleTitulos1['fill']['color']['rgb'] = 'FFAD3A';
        $this->docexcel->getActiveSheet()->getStyle('R5:T'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('R5:T5');
        $this->docexcel->getActiveSheet()->setCellValue('R5','REFRIGERIO');

        $this->styleTitulos1['fill']['color']['rgb'] = 'FF8F85';
        $this->docexcel->getActiveSheet()->getStyle('U5:W'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('U5:W5');
        $this->docexcel->getActiveSheet()->setCellValue('U5','PRIMA');

        $this->styleTitulos1['fill']['color']['rgb'] = 'A5A5A5';
        $this->docexcel->getActiveSheet()->getStyle('X5:Z'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('X5:Z5');
        $this->docexcel->getActiveSheet()->setCellValue('X5','RETROACTIVO');


        for($i=0; $i<$column_end; $i++){
            if( $i<5 || $i == $col_tot_via){
                $this->docexcel->getActiveSheet()->setCellValue($this->col[$i].($row_header-1),$column_name[$i]);
            }else{
                $this->docexcel->getActiveSheet()->setCellValue($this->col[$i].$row_header,$column_name[$i]);
            }

        }

        $nombre_funcionario = '';
        $categoria = '';
        //$codigo = '';
        $total = 0;
        $fechas = '';
        $this->numero = 1;
        $fila = 7;
        $col_admin = 5;
        $col_ope = 12;
        $col_ref = 17;
        $col_pri = 20;
        $col_ret = 23;

        $row_ini = 0;
        $color_cell = ['4682b4','00B167','B066BB','FFAD3A','FF8F85','A5A5A5'];//C6EFCE

        $sum_via_adm = 0;$sum_tasa_nac = 0;$sum_tasa_int = 0;$total_via_adm = 0;$total_via_ope = 0;$total_viatico = 0;
        $total_refri = 0;$total_prima = 0;$total_retro = 0;

        $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;$sum_viatico = 0;
        $total_ref = 0;$total_pri = 0;$total_ret = 0;

        $color_group = ['FFC7CE', '70AD47'];

        foreach ($datos as $value) {

            if ($nombre_funcionario != '' && $nombre_funcionario != $value['nombre_empleado']) {

                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setName('Calibri');
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setSize(11);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

                $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
                $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'SUBTOTAL '.$nombre_funcionario);


                $this->docexcel->getActiveSheet()->setCellValue('H'.$fila,'=SUM(H'.$row_ini.':H'.($fila-1).')');
                $this->docexcel->getActiveSheet()->setCellValue('I'.$fila,'=SUM(I'.$row_ini.':I'.($fila-1).')');
                $this->docexcel->getActiveSheet()->setCellValue('J'.$fila,'=SUM(J'.$row_ini.':J'.($fila-1).')');
                $this->docexcel->getActiveSheet()->setCellValue('K'.$fila,'=SUM(K'.$row_ini.':K'.($fila-1).')');

                $this->docexcel->getActiveSheet()->setCellValue('O'.$fila,'=SUM(O'.$row_ini.':O'.($fila-1).')');

                $this->docexcel->getActiveSheet()->setCellValue('Q'.$fila,'=SUM(Q'.$row_ini.':Q'.($fila-1).')');

                $this->docexcel->getActiveSheet()->setCellValue('S'.$fila,'=SUM(S'.$row_ini.':S'.($fila-1).')');

                $this->docexcel->getActiveSheet()->setCellValue('V'.$fila,'=SUM(V'.$row_ini.':V'.($fila-1).')');

                $this->docexcel->getActiveSheet()->setCellValue('Y'.$fila,'=SUM(Y'.$row_ini.':Y'.($fila-1).')');

                $fila++;
            }
            if( $nombre_funcionario != $value['nombre_empleado'] ){
                $row_ini = $fila;
            }

            if($categoria != $value['categoria'] && $categoria != ''){

                $sum_viatico = $total_adm + $total_ope;

                if($categoria == '1.ADM'){

                    $totales_x_categoria['admin']['adm']['monto'] = $sum_adm;
                    $totales_x_categoria['admin']['adm']['nacional'] = $sum_nac;
                    $totales_x_categoria['admin']['adm']['internacional'] = $sum_int;
                    $totales_x_categoria['admin']['adm']['total'] = $total_adm;
                    $totales_x_categoria['admin']['ope']['monto'] = $total_ope;
                    $totales_x_categoria['admin']['ope']['total'] = $sum_viatico;
                    $totales_x_categoria['admin']['ref']['monto']=$total_ref;
                    $totales_x_categoria['admin']['pri']['monto']=$total_pri;
                    $totales_x_categoria['admin']['ret']['monto']=$total_ret;

                }else if($categoria == '2.OPE'){

                    $totales_x_categoria['ope']['adm']['monto'] = $sum_adm;
                    $totales_x_categoria['ope']['adm']['nacional'] = $sum_nac;
                    $totales_x_categoria['ope']['adm']['internacional'] = $sum_int;
                    $totales_x_categoria['ope']['adm']['total'] = $total_adm;
                    $totales_x_categoria['ope']['ope']['monto'] = $total_ope;
                    $totales_x_categoria['ope']['ope']['total'] = $sum_viatico;
                    $totales_x_categoria['ope']['ref']['monto']=$total_ref;
                    $totales_x_categoria['ope']['pri']['monto']=$total_pri;
                    $totales_x_categoria['ope']['ret']['monto']=$total_ret;

                }else if($categoria == '3.ESP'){

                    $totales_x_categoria['esp']['adm']['monto'] = $sum_adm;
                    $totales_x_categoria['esp']['adm']['nacional'] = $sum_nac;
                    $totales_x_categoria['esp']['adm']['internacional'] = $sum_int;
                    $totales_x_categoria['esp']['adm']['total'] = $total_adm;
                    $totales_x_categoria['esp']['ope']['monto'] = $total_ope;
                    $totales_x_categoria['esp']['ope']['total'] = $sum_viatico;
                    $totales_x_categoria['esp']['ref']['monto']=$total_ref;
                    $totales_x_categoria['esp']['pri']['monto']=$total_pri;
                    $totales_x_categoria['esp']['ret']['monto']=$total_ret;
                }else if($categoria == '4.COM'){

                    $totales_x_categoria['com']['adm']['monto'] = $sum_adm;
                    $totales_x_categoria['com']['adm']['nacional'] = $sum_nac;
                    $totales_x_categoria['com']['adm']['internacional'] = $sum_int;
                    $totales_x_categoria['com']['adm']['total'] = $total_adm;
                    $totales_x_categoria['com']['ope']['monto'] = $total_ope;
                    $totales_x_categoria['com']['ope']['total'] = $sum_viatico;
                    $totales_x_categoria['com']['ref']['monto']=$total_ref;
                    $totales_x_categoria['com']['pri']['monto']=$total_pri;
                    $totales_x_categoria['com']['ret']['monto']=$total_ret;

                }else if($categoria == '6.EVE'){

                    $totales_x_categoria['eve']['adm']['monto'] = $sum_adm;
                    $totales_x_categoria['eve']['adm']['nacional'] = $sum_nac;
                    $totales_x_categoria['eve']['adm']['internacional'] = $sum_int;
                    $totales_x_categoria['eve']['adm']['total'] = $total_adm;
                    $totales_x_categoria['eve']['ope']['monto'] = $total_ope;
                    $totales_x_categoria['eve']['ope']['total'] = $sum_viatico;
                    $totales_x_categoria['eve']['ref']['monto']=$total_ref;
                    $totales_x_categoria['eve']['pri']['monto']=$total_pri;
                    $totales_x_categoria['eve']['ret']['monto']=$total_ret;

                }else if($categoria == '7.FIN'){

                    $totales_x_categoria['fin']['adm']['monto'] = $sum_adm;
                    $totales_x_categoria['fin']['adm']['nacional'] = $sum_nac;
                    $totales_x_categoria['fin']['adm']['internacional'] = $sum_int;
                    $totales_x_categoria['fin']['adm']['total'] = $total_adm;
                    $totales_x_categoria['fin']['ope']['monto'] = $total_ope;
                    $totales_x_categoria['fin']['ope']['total'] = $sum_viatico;
                    $totales_x_categoria['fin']['ref']['monto']=$total_ref;
                    $totales_x_categoria['fin']['pri']['monto']=$total_pri;
                    $totales_x_categoria['fin']['ret']['monto']=$total_ret;
                }

                $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;$sum_viatico = 0;
                $total_ref = 0;$total_pri = 0;$total_ret = 0;
            }


            $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':E'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[0]);
            $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $value['ci']);
            $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['nombre_empleado']);
            $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['estado']);
            $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['area']);
            $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $value['regional']);


            if($value['tipo'] == 'adm') {
                $this->docexcel->getActiveSheet()->getStyle('F'.$fila.':L'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[1]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin, $fila, $value['c31']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+1, $fila, $value['orden']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+2, $fila, $value['monto']-$value['tasa_nacional']-$value['tasa_internacional']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+3, $fila, $value['tasa_nacional']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+4, $fila, $value['tasa_internacional']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+5, $fila, '=H'.$fila.'+I'.$fila.'+J'.$fila);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+6, $fila, date_format(date_create($value['fecha_pago']), 'd/m/Y'));

                //total detalle
                $sum_via_adm +=  $value['monto'];
                $sum_tasa_nac +=  $value['tasa_nacional'];
                $sum_tasa_int +=  $value['tasa_internacional'];
                $total_via_adm += $value['monto']+$value['tasa_nacional']+$value['tasa_internacional'];

                //total_resumen
                $sum_adm+=  $value['monto'];$sum_nac+= $value['tasa_nacional'];$sum_int += $value['tasa_internacional'];
                $total_adm+= $value['monto']+$value['tasa_nacional']+$value['tasa_internacional'];

            }else {
                $this->docexcel->getActiveSheet()->getStyle('F'.$fila.':L'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[1]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+1, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+2, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+3, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+4, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+5, $fila, '=H'.$fila.'+I'.$fila.'+J'.$fila);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_admin+6, $fila, '');
                $sum_via_adm +=  0;
                $sum_tasa_nac +=  0;
                $sum_tasa_int +=  0;
                $total_via_adm += 0;
            }

            if($value['tipo'] == 'ope'){
                $this->docexcel->getActiveSheet()->getStyle('M'.$fila.':P'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[2]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope, $fila, $value['c31']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+1, $fila, $value['orden']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+2, $fila, $value['monto']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+3, $fila,  date_format(date_create($value['fecha_pago']), 'd/m/Y'));
                $this->docexcel->getActiveSheet()->getStyle('Q'.$fila.':Q'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[1]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+4, $fila, '=K'.$fila.'+O'.$fila);

                $total_via_ope += $value['monto'];
                $total_ope += $value['monto'];
            }else {
                $this->docexcel->getActiveSheet()->getStyle('M'.$fila.':P'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[2]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+1, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+2, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+3, $fila, '');
                $this->docexcel->getActiveSheet()->getStyle('Q'.$fila.':Q'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[1]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ope+4, $fila, '=K'.$fila.'+O'.$fila);
                $total_via_ope += 0;
            }


            if($value['tipo'] == 'ref'){
                $this->docexcel->getActiveSheet()->getStyle('R'.$fila.':T'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[3]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ref, $fila, $value['c31']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ref+1, $fila, $value['monto']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ref+2, $fila,  date_format(date_create($value['fecha_pago']), 'd/m/Y'));
                $total_refri += $value['monto'];
                $total_ref += $value['monto'];
            }else {
                $this->docexcel->getActiveSheet()->getStyle('R'.$fila.':T'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[3]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ref, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ref+1, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ref+2, $fila, '');
                $total_refri += 0;
            }

            if($value['tipo'] == 'pri'){
                $this->docexcel->getActiveSheet()->getStyle('U'.$fila.':W'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[4]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_pri, $fila, $value['c31']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_pri+1, $fila, $value['monto']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_pri+2, $fila, date_format(date_create($value['fecha_pago']), 'd/m/Y'));
                $total_prima += $value['monto'];
                $total_pri += $value['monto'];
            }else {
                $this->docexcel->getActiveSheet()->getStyle('U'.$fila.':W'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[4]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_pri, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_pri+1, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_pri+2, $fila, '');
                $total_prima += 0;
            }
            if($value['tipo'] == 'ret'){
                $this->docexcel->getActiveSheet()->getStyle('X'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[5]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ret, $fila, $value['c31']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ret+1, $fila, $value['monto']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ret+2, $fila, date_format(date_create($value['fecha_pago']), 'd/m/Y'));
                $total_retro += $value['monto'];
                $total_ret += $value['monto'];
            }else{
                $this->docexcel->getActiveSheet()->getStyle('X'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_cell[5]);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ret, $fila, '');
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ret+1, $fila, 0);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow($col_ret+2, $fila, '');
                $total_retro += 0;
            }

            $nombre_funcionario = $value['nombre_empleado'];
            $categoria = $value['categoria'];
            //$codigo = $value['codigo'];
            $fila++;
        }
        if($categoria == '7.FIN'){

            $totales_x_categoria['fin']['adm']['monto'] = $sum_adm;
            $totales_x_categoria['fin']['adm']['nacional'] = $sum_nac;
            $totales_x_categoria['fin']['adm']['internacional'] = $sum_int;
            $totales_x_categoria['fin']['adm']['total'] = $total_adm;
            $totales_x_categoria['fin']['ope']['monto'] = $total_ope;
            $totales_x_categoria['fin']['ope']['total'] = $sum_viatico;
            $totales_x_categoria['fin']['ref']['monto']=$total_ref;
            $totales_x_categoria['fin']['pri']['monto']=$total_pri;
            $totales_x_categoria['fin']['ret']['monto']=$total_ret;
        }//var_export($totales_x_categoria);exit;  //print_r($totales_x_categoria);exit;

        $total_viatico += $total_via_adm + $total_via_ope;
        //$this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0, 7);

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
        $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'SUBTOTAL '.$nombre_funcionario);

        $this->docexcel->getActiveSheet()->setCellValue('H'.$fila,'=SUM(H'.$row_ini.':H'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValue('I'.$fila,'=SUM(I'.$row_ini.':I'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValue('J'.$fila,'=SUM(J'.$row_ini.':J'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValue('K'.$fila,'=SUM(K'.$row_ini.':K'.($fila-1).')');

        $this->docexcel->getActiveSheet()->setCellValue('O'.$fila,'=SUM(O'.$row_ini.':O'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValue('Q'.$fila,'=SUM(Q'.$row_ini.':Q'.($fila-1).')');

        $this->docexcel->getActiveSheet()->setCellValue('S'.$fila,'=SUM(S'.$row_ini.':S'.($fila-1).')');

        $this->docexcel->getActiveSheet()->setCellValue('V'.$fila,'=SUM(V'.$row_ini.':V'.($fila-1).')');

        $this->docexcel->getActiveSheet()->setCellValue('Y'.$fila,'=SUM(Y'.$row_ini.':Y'.($fila-1).')');
        $fila++;

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[0]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(true);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setName('Calibri');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setSize(11);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('000000');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
        $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL CONCEPTO');
        //admin
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $sum_via_adm);
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, $sum_tasa_nac);
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(9, $fila, $sum_tasa_int);
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(10, $fila, $total_via_adm);
        //operativo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(14, $fila, $total_via_ope);
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(16, $fila, $total_viatico);
        //refrigerio
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(18, $fila, $total_refri);
        //prima
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(21, $fila, $total_prima);
        //retroactivo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(24, $fila, $total_retro);
        /*FIN DETALLE */

        $index++;

        $this->addHoja('RESUMEN OTROS INGRESOS',$index);
        $this->definitionStyle();

        for($i=0; $i<$column_end; $i++){
            $this->docexcel->getActiveSheet()->getColumnDimension($this->col[$i])->setWidth($size_column[$i]);
        }

        $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0,7);
        $this->docexcel->getActiveSheet()->getTabColor()->setRGB($color_pestana[$index]);

        /*logo*/
        $objDrawing = new PHPExcel_Worksheet_Drawing();
        $objDrawing->setName('BoA ERP');
        $objDrawing->setDescription('BoA ERP');
        $objDrawing->setPath('../../lib/imagenes/logos/logo.jpg');
        $objDrawing->setCoordinates('A1');
        $objDrawing->setOffsetX(0);
        $objDrawing->setOffsetY(0);
        $objDrawing->setWidth(105);
        $objDrawing->setHeight(75);
        $objDrawing->setWorksheet($this->docexcel->getActiveSheet());
        /*logo*/

        /*Estilo Cabecera*/
        $row_header = 6;

        $this->docexcel->getActiveSheet()->getStyle('A1:'.$this->col[$column_end-1].'4')->applyFromArray($this->styleTitulos);
        $this->docexcel->getActiveSheet()->getStyle('A1:'.$this->col[$column_end-1].$row_header)->getAlignment()->setWrapText(true);

        $this->docexcel->getActiveSheet()->mergeCells('A1:'.$this->col[$column_end-1].'2');
        $this->docexcel->getActiveSheet()->setCellValue('A1','RESUMEN OTROS INGRESOS');
        $this->docexcel->getActiveSheet()->mergeCells('A3:'.$this->col[$column_end-1].'3');
        $this->docexcel->getActiveSheet()->setCellValue('A3','(Importes expresados en Bolivianos)');
        $this->docexcel->getActiveSheet()->mergeCells('A4:'.$this->col[$column_end-1].'4');
        $this->docexcel->getActiveSheet()->setCellValue('A4','Pagos Del: '.date_format(date_create($fecha_desde),'d/m/Y').' Al: '.date_format(date_create($fecha_hasta),'d/m/Y'));


        $this->docexcel->getActiveSheet()->getStyle('A5:'.$this->col[4].$row_header)->applyFromArray($this->styleTitulos1);

        $this->docexcel->getActiveSheet()->mergeCells('A5:A'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('B5:B'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('C5:C'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('D5:D'.$row_header);
        $this->docexcel->getActiveSheet()->mergeCells('E5:E'.$row_header);

        $this->styleTitulos1['fill']['color']['rgb'] = '00B167';
        $this->docexcel->getActiveSheet()->getStyle('F5:L'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('F5:L5');
        $this->docexcel->getActiveSheet()->setCellValue('F5','VIÁTICO ADMINISTRATIVO');

        $this->styleTitulos1['fill']['color']['rgb'] = 'B066BB';
        $this->docexcel->getActiveSheet()->getStyle('M5:P'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('M5:P5');
        $this->docexcel->getActiveSheet()->setCellValue('M5','VIÁTICO OPERATIVO');

        $col_tot_via = 16;
        $this->styleTitulos1['fill']['color']['rgb'] = '00B167';
        $this->docexcel->getActiveSheet()->getStyle('Q5:Q'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('Q5:Q'.$row_header);

        $this->styleTitulos1['fill']['color']['rgb'] = 'FFAD3A';
        $this->docexcel->getActiveSheet()->getStyle('R5:T'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('R5:T5');
        $this->docexcel->getActiveSheet()->setCellValue('R5','REFRIGERIO');

        $this->styleTitulos1['fill']['color']['rgb'] = 'FF8F85';
        $this->docexcel->getActiveSheet()->getStyle('U5:W'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('U5:W5');
        $this->docexcel->getActiveSheet()->setCellValue('U5','PRIMA');

        $this->styleTitulos1['fill']['color']['rgb'] = 'A5A5A5';
        $this->docexcel->getActiveSheet()->getStyle('X5:Z'.$row_header)->applyFromArray($this->styleTitulos1);
        $this->docexcel->getActiveSheet()->mergeCells('X5:Z5');
        $this->docexcel->getActiveSheet()->setCellValue('X5','RETROACTIVO');


        for($i=0; $i<$column_end; $i++){
            if( $i<5 || $i == $col_tot_via){
                $this->docexcel->getActiveSheet()->setCellValue($this->col[$i].($row_header-1),$column_name[$i]);
            }else{
                $this->docexcel->getActiveSheet()->setCellValue($this->col[$i].$row_header,$column_name[$i]);
            }

        }

        $nombre_funcionario = '';
        $categoria = '';
        //$codigo = '';
        $total = 0;
        $fechas = '';
        $this->numero = 1;
        $fila = 7;
        $col_admin = 5;
        $col_ope = 12;
        $col_ref = 17;
        $col_pri = 20;
        $col_ret = 23;

        $row_ini = 0;
        $color_cell = ['4682b4','00B167','B066BB','FFAD3A','FF8F85','A5A5A5'];//C6EFCE

        $sum_via_adm = 0;$sum_tasa_nac = 0;$sum_tasa_int = 0;$total_via_adm = 0;$total_via_ope = 0;$total_viatico = 0;
        $total_refri = 0;$total_prima = 0;$total_retro = 0;

        $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;$sum_viatico = 0;
        $total_ref = 0;$total_pri = 0;$total_ret = 0;

        $color_group = ['FFC7CE', '70AD47'];

        $row_ini = $fila;
        foreach ($totales_x_categoria as $pro => $programa) {

            switch ($pro){
                case 'admin': $grupo = 'ADMINISTRACIÓN'; break;
                case 'ope': $grupo = 'OPERACIÓN'; break;
                case 'esp': $grupo = 'ESPECIAL'; break;
                case 'com': $grupo = 'COMERCIAL'; break;
                case 'eve': $grupo = 'EVENTUAL'; break;
                case 'fin': $grupo = 'DESVINCULADOS'; break;
            }
            $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
            $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
            $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
            $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

            $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
            $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL '.$grupo);

            foreach ($programa as $con => $concepto){
                switch ($con){
                    case 'adm':
                        $this->docexcel->getActiveSheet()->setCellValue('H'.$fila,$concepto['monto']-$value['tasa_nacional']-$value['tasa_internacional']);
                        $this->docexcel->getActiveSheet()->setCellValue('I'.$fila,$concepto['nacional']);
                        $this->docexcel->getActiveSheet()->setCellValue('J'.$fila,$concepto['internacional']);
                        $this->docexcel->getActiveSheet()->setCellValue('K'.$fila,$concepto['total']); break;
                    case 'ope':
                        $this->docexcel->getActiveSheet()->setCellValue('O'.$fila,$concepto['monto']);
                        $this->docexcel->getActiveSheet()->setCellValue('Q'.$fila,$concepto['total']); break;
                    case 'ref': $this->docexcel->getActiveSheet()->setCellValue('S'.$fila,$concepto['monto']); break;
                    case 'pri': $this->docexcel->getActiveSheet()->setCellValue('V'.$fila,$concepto['monto']); break;
                    case 'ret': $this->docexcel->getActiveSheet()->setCellValue('Y'.$fila,$concepto['monto']); break;
                }
            }
            $fila++;
        }

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[0]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(true);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setName('Calibri');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setSize(11);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('000000');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
        $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL X CATEGORIA');
        //admin
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=SUM(H'.$row_ini.':H'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, '=SUM(I'.$row_ini.':I'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(9, $fila, '=SUM(J'.$row_ini.':J'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(10, $fila, '=SUM(K'.$row_ini.':K'.($fila-1).')');
        //operativo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(14, $fila, '=SUM(O'.$row_ini.':O'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(16, $fila, '=SUM(Q'.$row_ini.':Q'.($fila-1).')');
        //refrigerio
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(18, $fila, '=SUM(S'.$row_ini.':S'.($fila-1).')');
        //prima
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(21, $fila, '=SUM(V'.$row_ini.':V'.($fila-1).')');
        //retroactivo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(24, $fila, '=SUM(Y'.$row_ini.':Y'.($fila-1).')');

        $fila +=2;
        /////////C31
        $this->array_sort_by($datos,'c31');
        $mes_anterior = array();

        $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;//$sum_viatico = 0;
        $total_ref = 0;$total_pri = 0;$total_ret = 0;
        $comprobante = '';

        $row_ini = $fila;

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);

        $switch_c31 = '';

        foreach ($datos as $comp){
            if(strtotime($comp['fecha_pago']) < strtotime(fecha_pago)){
                $mes_anterior[]=$comp;
                continue;
            }
            if($comprobante != $comp['c31'] && $comprobante != ''){
                /*if($comp['c31'] == 'TJA BYC 5700-5413'){
                    print_r();exit;
                }*/
                //$sum_viatico = $total_adm + $total_ope;

                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

                $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);

                $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL '.$comprobante);

                $this->docexcel->getActiveSheet()->setCellValue('H'.$fila,$total_adm);
                $this->docexcel->getActiveSheet()->setCellValue('I'.$fila,$sum_nac);
                $this->docexcel->getActiveSheet()->setCellValue('J'.$fila,$sum_int);
                $this->docexcel->getActiveSheet()->setCellValue('K'.$fila,$sum_adm);

                $this->docexcel->getActiveSheet()->setCellValue('O'.$fila,$total_ope);
                $this->docexcel->getActiveSheet()->setCellValue('Q'.$fila,'=SUM(K'.$fila.':O'.$fila.')');

                if($switch_c31 == 'adm'){
                    $this->docexcel->getActiveSheet()->setCellValue('F'.$fila,$comprobante);
                }else if($switch_c31 == 'ope'){
                    $this->docexcel->getActiveSheet()->setCellValue('M'.$fila,$comprobante);
                }else if($switch_c31 == 'ref'){
                    $this->docexcel->getActiveSheet()->setCellValue('R'.$fila,$comprobante);
                }

                $this->docexcel->getActiveSheet()->setCellValue('S'.$fila,$total_ref);
                $this->docexcel->getActiveSheet()->setCellValue('V'.$fila,$total_pri);
                $this->docexcel->getActiveSheet()->setCellValue('Y'.$fila,$total_ret);

                $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;//$sum_viatico = 0;
                $total_ref = 0;$total_pri = 0;$total_ret = 0;
                $fila ++;
            }

            if($comp['tipo'] == 'adm') {

                $sum_adm+=  $comp['monto']-$value['tasa_nacional']-$value['tasa_internacional'];
                $sum_nac+= $comp['tasa_nacional'];
                $sum_int += $comp['tasa_internacional'];
                $total_adm+= $comp['monto']-$comp['tasa_nacional']-$comp['tasa_internacional'];
            }
            if($comp['tipo'] == 'ope'){
                $total_ope += $comp['monto'];
            }

            if($comp['tipo'] == 'ref'){
                $total_ref += $comp['monto'];
            }

            if($comp['tipo'] == 'pri'){
                $total_pri += $comp['monto'];
            }
            if($comp['tipo'] == 'ret'){
                $total_ret += $comp['monto'];
            }

            $comprobante = $comp['c31'];
            $switch_c31 = $comp['tipo'];
        }

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);

        $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL '.$comprobante);

        $this->docexcel->getActiveSheet()->setCellValue('H'.$fila, $total_adm);
        $this->docexcel->getActiveSheet()->setCellValue('I'.$fila,$sum_nac);
        $this->docexcel->getActiveSheet()->setCellValue('J'.$fila,$sum_int);
        $this->docexcel->getActiveSheet()->setCellValue('K'.$fila, $sum_adm);

        $this->docexcel->getActiveSheet()->setCellValue('O'.$fila,$total_ope);
        $this->docexcel->getActiveSheet()->setCellValue('Q'.$fila,'=SUM(K'.$fila.':O'.$fila.')');

        if($switch_c31 == 'adm'){
            $this->docexcel->getActiveSheet()->setCellValue('F'.$fila,$comprobante);
        }else if($switch_c31 == 'ope'){
            $this->docexcel->getActiveSheet()->setCellValue('M'.$fila,$comprobante);
        }else if($switch_c31 == 'ref'){
            $this->docexcel->getActiveSheet()->setCellValue('R'.$fila,$comprobante);
        }

        $this->docexcel->getActiveSheet()->setCellValue('S'.$fila,$total_ref);
        $this->docexcel->getActiveSheet()->setCellValue('V'.$fila,$total_pri);
        $this->docexcel->getActiveSheet()->setCellValue('Y'.$fila,$total_ret);

        $fila++;

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[0]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(true);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setName('Calibri');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setSize(11);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('000000');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
        $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL X COMPROBANTE DECLARADO EN EL MES');
        //admin
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=SUM(H'.$row_ini.':H'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, '=SUM(I'.$row_ini.':I'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(9, $fila, '=SUM(J'.$row_ini.':J'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(10, $fila, '=SUM(K'.$row_ini.':K'.($fila-1).')');
        //operativo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(14, $fila, '=SUM(O'.$row_ini.':O'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(16, $fila, '=SUM(Q'.$row_ini.':Q'.($fila-1).')');
        //refrigerio
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(18, $fila, '=SUM(S'.$row_ini.':S'.($fila-1).')');
        //prima
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(21, $fila, '=SUM(V'.$row_ini.':V'.($fila-1).')');
        //retroactivo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(24, $fila, '=SUM(Y'.$row_ini.':Y'.($fila-1).')');
        //FIN COMPROBANTE MES ACTUAL

        //INICIO COMPROBANTE MES ANTERIOR
        $fila +=2;

        $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;
        $total_ref = 0;$total_pri = 0;$total_ret = 0;
        $comprobante = '';

        $row_ini = $fila;

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);


        foreach ($mes_anterior as $comp){

            if($comprobante != $comp['c31'] && $comprobante != ''){

                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[1]);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(false);
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('ffffff');
                $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);

                $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);

                $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL '.$comprobante);

                $this->docexcel->getActiveSheet()->setCellValue('H'.$fila,$sum_adm);
                $this->docexcel->getActiveSheet()->setCellValue('I'.$fila,$sum_nac);
                $this->docexcel->getActiveSheet()->setCellValue('J'.$fila,$sum_int);
                $this->docexcel->getActiveSheet()->setCellValue('K'.$fila,$total_adm);

                $this->docexcel->getActiveSheet()->setCellValue('O'.$fila,$total_ope);
                $this->docexcel->getActiveSheet()->setCellValue('Q'.$fila,'=SUM(K'.$fila.':O'.$fila.')');

                if($switch_c31 == 'adm'){
                    $this->docexcel->getActiveSheet()->setCellValue('F'.$fila,$comprobante);
                }else if($switch_c31 == 'ope'){
                    $this->docexcel->getActiveSheet()->setCellValue('M'.$fila,$comprobante);
                }else if($switch_c31 == 'ref'){
                    $this->docexcel->getActiveSheet()->setCellValue('R'.$fila,$comprobante);
                }

                $this->docexcel->getActiveSheet()->setCellValue('S'.$fila,$total_ref);
                $this->docexcel->getActiveSheet()->setCellValue('V'.$fila,$total_pri);
                $this->docexcel->getActiveSheet()->setCellValue('Y'.$fila,$total_ret);

                $sum_adm = 0;$sum_nac = 0;$sum_int = 0;$total_adm = 0;$total_ope = 0;
                $total_ref = 0;$total_pri = 0;$total_ret = 0;
                $fila ++;
            }

            if($comp['tipo'] == 'adm') {

                $sum_adm+=  $comp['monto'];$sum_nac+= $comp['tasa_nacional'];$sum_int += $comp['tasa_internacional'];
                $total_adm+= $comp['monto']+$comp['tasa_nacional']+$comp['tasa_internacional'];
            }
            if($comp['tipo'] == 'ope'){
                $total_ope += $comp['monto'];
            }

            if($comp['tipo'] == 'ref'){
                $total_ref += $comp['monto'];
            }

            if($comp['tipo'] == 'pri'){
                $total_pri += $comp['monto'];
            }
            if($comp['tipo'] == 'ret'){
                $total_ret += $comp['monto'];
            }

            $comprobante = $comp['c31'];
            $switch_c31 = $comp['tipo'];
        }

        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFill()->setFillType(PHPExcel_Style_Fill::FILL_SOLID)->getStartColor()->setRGB($color_group[0]);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setBold(true);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setName('Calibri');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->setSize(11);
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getFont()->getColor()->setRGB('000000');
        $this->docexcel->getActiveSheet()->getStyle('A'.$fila.':Z'.$fila)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $this->docexcel->getActiveSheet()->mergeCells('A'.$fila.':E'.$fila);
        $this->docexcel->getActiveSheet()->setCellValue('A'.$fila,'TOTAL X COMPROBANTE DECLARADO DEL MES ANTERIOR');
        //admin
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, '=SUM(H'.$row_ini.':H'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, '=SUM(I'.$row_ini.':I'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(9, $fila, '=SUM(J'.$row_ini.':J'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(10, $fila, '=SUM(K'.$row_ini.':K'.($fila-1).')');
        //operativo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(14, $fila, '=SUM(O'.$row_ini.':O'.($fila-1).')');
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(16, $fila, '=SUM(Q'.$row_ini.':Q'.($fila-1).')');
        //refrigerio
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(18, $fila, '=SUM(S'.$row_ini.':S'.($fila-1).')');
        //prima
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(21, $fila, '=SUM(V'.$row_ini.':V'.($fila-1).')');
        //retroactivo
        $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(24, $fila, '=SUM(Y'.$row_ini.':Y'.($fila-1).')');

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