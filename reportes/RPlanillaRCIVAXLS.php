<?php
class RPlanillaRCIVAXLS
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

    function generarDatos()
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

        $this->numero = 1;
        $fila = 3;
        $datos = $this->objParam->getParametro('datos');//var_dump($datos);exit;
        $tipo  = $this->objParam->getParametro('tipo');


        $numberFormat = '#,##0.00';
        $cant_datos = count($datos);
        $cont_total = 1;
        $fila_total = 1;
        // $this->addHoja('Resumen',0);
        $index = 0;
        $color_pestana = array('ff0000','1100ff','55ff00','3ba3ff','ff4747','697dff','78edff','ba8cff',
            'ff80bb','ff792b','ffff5e','52ff97','bae3ff','ffaf9c','bfffc6','b370ff','ffa8b4','7583ff','9aff17','ff30c8');
        $this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0,3);
        $this->addHoja('RC-IVA Rev. Interna',$index);
        $this->docexcel->getActiveSheet()->getTabColor()->setRGB($color_pestana[$index]);
        if($tipo == 'planilla'){

            $this->docexcel->getActiveSheet()->getStyle('A1:AC2')->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->getStyle('A1:AC2')->applyFromArray($styleTitulos3);

            $this->docexcel->getActiveSheet()->mergeCells('A1:A2');
            $this->docexcel->getActiveSheet()->mergeCells('B1:B2');
            $this->docexcel->getActiveSheet()->mergeCells('C1:C2');
            $this->docexcel->getActiveSheet()->mergeCells('D1:D2');
            $this->docexcel->getActiveSheet()->mergeCells('E1:E2');
            $this->docexcel->getActiveSheet()->mergeCells('F1:F2');
            $this->docexcel->getActiveSheet()->mergeCells('G1:G2');
            $this->docexcel->getActiveSheet()->mergeCells('H1:H2');
            $this->docexcel->getActiveSheet()->mergeCells('I1:I2');

            $this->docexcel->getActiveSheet()->mergeCells('J1:J2');
            $this->docexcel->getActiveSheet()->mergeCells('K1:K2');
            $this->docexcel->getActiveSheet()->mergeCells('L1:L2');
            $this->docexcel->getActiveSheet()->mergeCells('M1:M2');
            $this->docexcel->getActiveSheet()->mergeCells('N1:N2');

            $this->docexcel->getActiveSheet()->mergeCells('O1:O2');
            $this->docexcel->getActiveSheet()->mergeCells('P1:P2');
            $this->docexcel->getActiveSheet()->mergeCells('Q1:Q2');
            $this->docexcel->getActiveSheet()->mergeCells('R1:R2');
            $this->docexcel->getActiveSheet()->mergeCells('S1:S2');
            $this->docexcel->getActiveSheet()->mergeCells('T1:T2');
            $this->docexcel->getActiveSheet()->mergeCells('U1:U2');
            $this->docexcel->getActiveSheet()->mergeCells('V1:V2');
            $this->docexcel->getActiveSheet()->mergeCells('W1:W2');

            $this->docexcel->getActiveSheet()->mergeCells('X1:Z1');

            $this->docexcel->getActiveSheet()->mergeCells('AA1:AA2');
            $this->docexcel->getActiveSheet()->mergeCells('AB1:AB2');
            $this->docexcel->getActiveSheet()->mergeCells('AC1:AC2');

            $this->docexcel->getActiveSheet()->setTitle('RC-IVA Rev. Interna');

            $this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
            $this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(10);//gerencia
            $this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(20);//contrato
            $this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(40);//funcionario
            $this->docexcel->getActiveSheet()->getColumnDimension('E')->setWidth(40);//documento
            $this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(35);//cargo
            $this->docexcel->getActiveSheet()->getColumnDimension('G')->setWidth(30);//correo
            $this->docexcel->getActiveSheet()->getColumnDimension('H')->setWidth(30);//correo_personal
            $this->docexcel->getActiveSheet()->getColumnDimension('I')->setWidth(25);//telefonos

            $this->docexcel->getActiveSheet()->getColumnDimension('J')->setWidth(25);//cotizable
            $this->docexcel->getActiveSheet()->getColumnDimension('K')->setWidth(25);//refrigerio
            $this->docexcel->getActiveSheet()->getColumnDimension('L')->setWidth(25);//viatico
            $this->docexcel->getActiveSheet()->getColumnDimension('M')->setWidth(25);//prima

            $this->docexcel->getActiveSheet()->getColumnDimension('N')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('O')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('P')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('Q')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('R')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('S')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('T')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('U')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('V')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('W')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('X')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('Y')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('Z')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('AA')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('AB')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('AC')->setWidth(25);//celulares

            $this->docexcel->getActiveSheet()->setCellValue('A1', 'Año');
            $this->docexcel->getActiveSheet()->setCellValue('B1', 'Periodo');
            $this->docexcel->getActiveSheet()->setCellValue('C1', 'Codigo Dependiente RC-IVA');
            $this->docexcel->getActiveSheet()->setCellValue('D1', 'Nombres');
            $this->docexcel->getActiveSheet()->setCellValue('E1', 'Primer Apellido');
            $this->docexcel->getActiveSheet()->setCellValue('F1', 'Segundo Apellido');
            $this->docexcel->getActiveSheet()->setCellValue('G1', 'Número de Documento o de Identidad');
            $this->docexcel->getActiveSheet()->setCellValue('H1', 'Tipo de Documento');
            $this->docexcel->getActiveSheet()->setCellValue('I1', 'Novedades');

            $this->docexcel->getActiveSheet()->setCellValue('J1','Cotizable');
            $this->docexcel->getActiveSheet()->setCellValue('K1','Refrigerio');
            $this->docexcel->getActiveSheet()->setCellValue('L1','Viatico');
            $this->docexcel->getActiveSheet()->setCellValue('M1','Prima');
            $this->docexcel->getActiveSheet()->setCellValue('N1','Total Otros/Ingresos');

            $this->docexcel->getActiveSheet()->setCellValue('O1', 'Monto de Ingreso Neto');
            $this->docexcel->getActiveSheet()->setCellValue('P1', 'Dos salarios Minimos Nacionales no Imponible');
            $this->docexcel->getActiveSheet()->setCellValue('Q1', 'Imponible Sujeto a Impuesto(base imponible)');
            $this->docexcel->getActiveSheet()->setCellValue('R1', 'Impuesto RC-IVA');
            $this->docexcel->getActiveSheet()->setCellValue('S1', '13 % Dos Salarios Minimos Nacionales');
            $this->docexcel->getActiveSheet()->setCellValue('T1', 'Impuesto Neto RC-IVA');
            $this->docexcel->getActiveSheet()->setCellValue('U1', 'F-110 13% de Facturas Presentadas');
            $this->docexcel->getActiveSheet()->setCellValue('V1', 'Saldo a Favor del Fisco');
            $this->docexcel->getActiveSheet()->setCellValue('W1', 'Saldo a Favor del Depend.');

            $this->docexcel->getActiveSheet()->setCellValue('X1', 'Saldo a Favor del Dependiente');
            $this->docexcel->getActiveSheet()->setCellValue('X2', 'Del Periodo Anterior');
            $this->docexcel->getActiveSheet()->setCellValue('Y2', 'Mant. de Valor');
            $this->docexcel->getActiveSheet()->setCellValue('Z2', 'Saldo Actualizado');
            $this->docexcel->getActiveSheet()->setCellValue('AA1', 'Saldo Utilizado');
            $this->docexcel->getActiveSheet()->setCellValue('AB1', 'Impuesto RC-IVA retenido');
            $this->docexcel->getActiveSheet()->setCellValue('AC1', 'Saldo de Crédito Fiscal a favor del dependiente para el mes siguiente');

        }else {
            $this->docexcel->getActiveSheet()->getStyle('A1:X2')->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->getStyle('A1:X2')->applyFromArray($styleTitulos3);

            $this->docexcel->getActiveSheet()->mergeCells('A1:A2');
            $this->docexcel->getActiveSheet()->mergeCells('B1:B2');
            $this->docexcel->getActiveSheet()->mergeCells('C1:C2');
            $this->docexcel->getActiveSheet()->mergeCells('D1:D2');
            $this->docexcel->getActiveSheet()->mergeCells('E1:E2');
            $this->docexcel->getActiveSheet()->mergeCells('F1:F2');
            $this->docexcel->getActiveSheet()->mergeCells('G1:G2');
            $this->docexcel->getActiveSheet()->mergeCells('H1:H2');
            $this->docexcel->getActiveSheet()->mergeCells('I1:I2');
            $this->docexcel->getActiveSheet()->mergeCells('J1:J2');
            $this->docexcel->getActiveSheet()->mergeCells('K1:K2');
            $this->docexcel->getActiveSheet()->mergeCells('L1:L2');
            $this->docexcel->getActiveSheet()->mergeCells('M1:M2');
            $this->docexcel->getActiveSheet()->mergeCells('N1:N2');
            $this->docexcel->getActiveSheet()->mergeCells('O1:O2');
            $this->docexcel->getActiveSheet()->mergeCells('P1:P2');
            $this->docexcel->getActiveSheet()->mergeCells('Q1:Q2');
            $this->docexcel->getActiveSheet()->mergeCells('R1:R2');

            $this->docexcel->getActiveSheet()->mergeCells('S1:U1');
            $this->docexcel->getActiveSheet()->mergeCells('V1:V2');
            $this->docexcel->getActiveSheet()->mergeCells('W1:W2');
            $this->docexcel->getActiveSheet()->mergeCells('X1:X2');


            $this->docexcel->getActiveSheet()->setTitle('RC-IVA');

            $this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
            $this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(10);//gerencia
            $this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(20);//contrato
            $this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(40);//funcionario
            $this->docexcel->getActiveSheet()->getColumnDimension('E')->setWidth(40);//documento
            $this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(35);//cargo
            $this->docexcel->getActiveSheet()->getColumnDimension('G')->setWidth(30);//correo
            $this->docexcel->getActiveSheet()->getColumnDimension('H')->setWidth(30);//correo_personal
            $this->docexcel->getActiveSheet()->getColumnDimension('I')->setWidth(25);//telefonos
            $this->docexcel->getActiveSheet()->getColumnDimension('J')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('K')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('L')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('M')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('N')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('O')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('P')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('Q')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('R')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('S')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('T')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('U')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('V')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('W')->setWidth(25);//celulares
            $this->docexcel->getActiveSheet()->getColumnDimension('X')->setWidth(25);//celulares

            $this->docexcel->getActiveSheet()->setCellValue('A1', 'Año');
            $this->docexcel->getActiveSheet()->setCellValue('B1', 'Periodo');
            $this->docexcel->getActiveSheet()->setCellValue('C1', 'Codigo Dependiente RC-IVA');
            $this->docexcel->getActiveSheet()->setCellValue('D1', 'Nombres');
            $this->docexcel->getActiveSheet()->setCellValue('E1', 'Primer Apellido');
            $this->docexcel->getActiveSheet()->setCellValue('F1', 'Segundo Apellido');
            $this->docexcel->getActiveSheet()->setCellValue('G1', 'Número de Documento o de Identidad');
            $this->docexcel->getActiveSheet()->setCellValue('H1', 'Tipo de Documento');
            $this->docexcel->getActiveSheet()->setCellValue('I1', 'Novedades');


            $this->docexcel->getActiveSheet()->setCellValue('J1', 'Monto de Ingreso Neto');
            $this->docexcel->getActiveSheet()->setCellValue('K1', 'Dos salarios Minimos Nacionales no Imponible');
            $this->docexcel->getActiveSheet()->setCellValue('L1', 'Imponible Sujeto a Impuesto(base imponible)');
            $this->docexcel->getActiveSheet()->setCellValue('M1', 'Impuesto RC-IVA');
            $this->docexcel->getActiveSheet()->setCellValue('N1', '13 % Dos Salarios Minimos Nacionales');
            $this->docexcel->getActiveSheet()->setCellValue('O1', 'Impuesto Neto RC-IVA');
            $this->docexcel->getActiveSheet()->setCellValue('P1', 'F-110 13% de Facturas Presentadas');
            $this->docexcel->getActiveSheet()->setCellValue('Q1', 'Saldo a Favor del Fisco');
            $this->docexcel->getActiveSheet()->setCellValue('R1', 'Saldo a Favor del Depend.');
            $this->docexcel->getActiveSheet()->setCellValue('S1', 'Saldo a Favor del Dependiente');
            $this->docexcel->getActiveSheet()->setCellValue('S2', 'Del Periodo Anterior');
            $this->docexcel->getActiveSheet()->setCellValue('T2', 'Mant. de Valor');
            $this->docexcel->getActiveSheet()->setCellValue('U2', 'Saldo Actualizado');
            $this->docexcel->getActiveSheet()->setCellValue('V1', 'Saldo Utilizado');
            $this->docexcel->getActiveSheet()->setCellValue('W1', 'Impuesto RC-IVA retenido');
            $this->docexcel->getActiveSheet()->setCellValue('X1', 'Saldo de Crédito Fiscal a favor del dependiente para el mes siguiente');
        }

        foreach ($datos as $value) {
            if($tipo == 'planilla'){

                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $value['gestion']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['periodo']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['codigo_rc_iva']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['nombre']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $value['apellido_paterno']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, $value['apellido_materno']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, $value['numero_documento']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $value['tipo_documento']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, $value['novedades']);


                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(9, $fila, $value['cotizable']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(10, $fila, $value['refrigerio']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(11, $fila, $value['viatico']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(12, $fila, $value['prima']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(13, $fila, '=K'.$fila.'+L'.$fila.'+M'.$fila);

                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(14, $fila, $value['ingreso_neto']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(15, $fila, $value['dos_salario_minimo']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(16, $fila, $value['base_imponible']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(17, $fila, $value['impuesto_rc_iva']);//R
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(18, $fila, $value['trece_dos_salario_minimo']);//S
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(19, $fila, '=IF(R' . $fila . '>S' . $fila . ',R' . $fila . '-S' . $fila . ',0)');//T
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(20, $fila, $value['trece_facturas']);//U
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(21, $fila, '=IF(T' . $fila . '>U' . $fila . ',T' . $fila . '-U' . $fila . ',0)');//V
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(22, $fila, '=IF(U' . $fila . '>T' . $fila . ',U' . $fila . '-T' . $fila . ',0)');//W
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(23, $fila, $value['saldo_per_anterior']);//X
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(24, $fila, $value['mantenimiento_valor']);//Y
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(25, $fila, $value['saldo_per_anterior'] + $value['mantenimiento_valor']);//Z
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(26, $fila, '=IF(Z' . $fila . '<=U' . $fila . ',Z' . $fila . ',U' . $fila . ')');//AA
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(27, $fila, '=IF(V' . $fila . '>AA' . $fila . ',V' . $fila . '-AA' . $fila . ',0)');//AB
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(28, $fila, '=W' . $fila . '+Z' . $fila . '-AA' . $fila);//AC

            }else {
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(0, $fila, $value['gestion']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $value['periodo']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['codigo_rc_iva']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['nombre']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $value['apellido_paterno']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, $value['apellido_materno']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, $value['numero_documento']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(7, $fila, $value['tipo_documento']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(8, $fila, $value['novedades']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(9, $fila, $value['ingreso_neto']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(10, $fila, $value['dos_salario_minimo']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(11, $fila, $value['base_imponible']);
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(12, $fila, $value['impuesto_rc_iva']);//M
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(13, $fila, $value['trece_dos_salario_minimo']);//N
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(14, $fila, '=IF(M' . $fila . '>N' . $fila . ',M' . $fila . '-N' . $fila . ',0)');//O
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(15, $fila, $value['trece_facturas']);//P
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(16, $fila, '=IF(O' . $fila . '>P' . $fila . ',O' . $fila . '-P' . $fila . ',0)');//Q
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(17, $fila, '=IF(P' . $fila . '>O' . $fila . ',P' . $fila . '-O' . $fila . ',0)');//R
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(18, $fila, $value['saldo_per_anterior']);//S
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(19, $fila, $value['mantenimiento_valor']);//T
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(20, $fila, $value['saldo_per_anterior'] + $value['mantenimiento_valor']);//U
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(21, $fila, '=IF(U' . $fila . '<=Q' . $fila . ',U' . $fila . ',Q' . $fila . ')');//V
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(22, $fila, '=IF(Q' . $fila . '>V' . $fila . ',Q' . $fila . '-V' . $fila . ',0)');//W
                $this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(23, $fila, '=R' . $fila . '+U' . $fila . '-V' . $fila);//X
            }

            $fila++;
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
        $this->generarDatos();
        $this->docexcel->setActiveSheetIndex(0);
        $this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
        $this->objWriter->save($this->url_archivo);
        //$this->imprimeCabecera(0);

    }
}
?>