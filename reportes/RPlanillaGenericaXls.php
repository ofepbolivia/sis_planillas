<?php
//incluimos la libreria
//echo dirname(__FILE__);
//include_once(dirname(__FILE__).'/../PHPExcel/Classes/PHPExcel.php');
class RPlanillaGenericaXls
{
	private $docexcel;
	private $objWriter;
	private $nombre_archivo;
	private $hoja;
	private $columnas=array();
	private $fila;
	private $equivalencias=array();
	
	private $indice, $m_fila, $titulo;
	private $swEncabezado=0; //variable que define si ya se imprimi� el encabezado
	private $objParam;
	public  $url_archivo;	
	
	function __construct(CTParametro $objParam){
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
		$this->docexcel->setActiveSheetIndex(0);
		$this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));
		$this->equivalencias=array(0=>'A',1=>'B',2=>'C',3=>'D',4=>'E',5=>'F',6=>'G',7=>'H',8=>'I',
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
			
	function imprimeDatos(){
		$datos = $this->objParam->getParametro('datos');
		
		$config = $this->objParam->getParametro('config');
		$columnas = 0;

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

        $this->styleTitulos = array(
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
                    'rgb' => 'c5d9f1'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            ));

        $this->styledetalle = array(
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
                    'rgb' => '72fa80'
                )
            ),
            'borders' => array(
                'allborders' => array(
                    'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            ));

		//*************************************Cabecera*****************************************

        //$this->docexcel->getActiveSheet()->freezePaneByColumnAndRow(0,3);
        $this->docexcel->getActiveSheet()->getStyle("A1:P2")->applyFromArray($this->styleTitulos);

		$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(20);
        //$this->docexcel->getActiveSheet()->mergeCells('A1:A2');
		$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'Gerencia');
		$columnas++;

        $this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(20);
        //$this->docexcel->getActiveSheet()->mergeCells('B1:B2');
        //$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'Motivo Retiro');
        $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'Cargo');
        $columnas++;

		if ($config['numerar'] == 'si') {
			$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(8);
            //$this->docexcel->getActiveSheet()->mergeCells('C1:C2');
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'No');
			$columnas++;
		}
		if ($config['mostrar_nombre'] == 'si'){
			$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(33);
            //$this->docexcel->getActiveSheet()->mergeCells('D1:D2');
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'Nombre Completo');
			$columnas++;			
		}
		if ($config['mostrar_codigo_empleado'] == 'si') {
			$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(10);
            //$this->docexcel->getActiveSheet()->mergeCells('E1:E2');
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'Cod.');
			$columnas++;			
		}
		if ($config['mostrar_doc_id'] == 'si') {
			$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(10);
            //$this->docexcel->getActiveSheet()->mergeCells('F1:F2');
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'CI.');
			$columnas++;
		}
		if ($config['mostrar_codigo_cargo'] == 'si') {
			$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(10);
            //$this->docexcel->getActiveSheet()->mergeCells('G1:G2');
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,'Item');
			$columnas++;
		}
        /*$this->docexcel->getActiveSheet()->mergeCells('H1:H2');
        $this->docexcel->getActiveSheet()->mergeCells('I1:I2');
        $this->docexcel->getActiveSheet()->mergeCells('J1:J2');
        $this->docexcel->getActiveSheet()->mergeCells('K1:K2');
        $this->docexcel->getActiveSheet()->mergeCells('L1:L2');
        $this->docexcel->getActiveSheet()->mergeCells('M1:M2');
        $this->docexcel->getActiveSheet()->mergeCells('N1:N2');
        $this->docexcel->getActiveSheet()->mergeCells('O1:O2');*/

		$columnas_basicas = $columnas;
		foreach($datos as $value) {
			$this->docexcel->getActiveSheet()->getColumnDimension($this->equivalencias[$columnas])->setWidth(10);
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,1,$value['titulo_reporte_superior']);
			$columnas++;
			if ($columnas - $columnas_basicas == $config['cantidad_columnas']) {
				break;
			}
		}		
		$columnas = 0;
		$columnas++;
		$columnas++;
		//Titulos de columnas inferiores e iniciacion de los arreglos para la tabla
		if ($config['numerar'] == 'si') {			
			$columnas++;
		}
		if ($config['mostrar_nombre'] == 'si'){			
			$columnas++;			
		}
		if ($config['mostrar_codigo_empleado'] == 'si') {			
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,2,'Emp.');
			$columnas++;			
		}
		if ($config['mostrar_doc_id'] == 'si') {			
			$columnas++;
		}
		if ($config['mostrar_codigo_cargo'] == 'si') {			
			$columnas++;
		}
		
		
		foreach($datos as $value) {			
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,2,$value['titulo_reporte_inferior']);
			$columnas++;
			if ($columnas - $columnas_basicas == $config['cantidad_columnas']) {
				break;
			}
		}
		//*************************************Fin Cabecera*****************************************
		$id_funcionario = -1;
		$fila = 2;
		
		/////////////////////***********************************Detalle***********************************************
		foreach($datos as $value) {			
			if ($id_funcionario != $value['id_funcionario']) {				
				$fila++;
				$columnas = $columnas_basicas;
				$this->imprimeDatosBasicos($config,$value,$fila);
				$id_funcionario = $value['id_funcionario'];
				
			}
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,$fila,$value['valor_columna']);
			$columnas++;
		}
		//************************************************Fin Detalle***********************************************
		
	}

	function imprimeDatosBasicos($config,$detalle, $fila) {
		$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(0,$fila,$detalle['gerencia']);	
		$columnas = 1;

        /*if ($detalle['motivo_retiro'] == 'retiro'){
            $this->docexcel->getActiveSheet()->getStyle("A$fila:P$fila")->applyFromArray($this->styleVacio);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$fila,$detalle['motivo_retiro']);
            $columnas = 2;
        }else{

            $this->docexcel->getActiveSheet()->getStyle("A$fila:P$fila")->applyFromArray($this->styledetalle);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$fila,$detalle['motivo_retiro']);
            $columnas = 2;
        }*/
        $this->docexcel->getActiveSheet()->getStyle("A$fila:P$fila")->applyFromArray($this->styledetalle);
        $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$fila,$detalle['cargo']);
        $columnas = 2;
		if ($config['numerar'] == 'si') {
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,$fila,$fila);
			$columnas++;
		}
		if ($config['mostrar_nombre'] == 'si') {
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,$fila,$detalle['nombre_empleado']);
			$columnas++;
		}
		if ($config['mostrar_codigo_empleado'] == 'si') {
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,$fila,$detalle['codigo_empleado']);
			$columnas++;
		}
		if ($config['mostrar_doc_id'] == 'si') {
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,$fila,$detalle['doc_id']);
			$columnas++;
		}
		if ($config['mostrar_codigo_cargo'] == 'si') {
			$this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow($columnas,$fila,$detalle['codigo_cargo']);
			$columnas++;
		}		
	}
	
	function generarReporte(){
		//echo $this->nombre_archivo; exit;
		// Set active sheet index to the first sheet, so Excel opens this as the first sheet
		$this->docexcel->setActiveSheetIndex(0);
		$this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
		$this->objWriter->save($this->url_archivo);	
		
	}	
	

}

?>