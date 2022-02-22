/***********************************I-SCP-JRR-PLANI-0-16/01/2014****************************************/
CREATE TABLE plani.tparametro_valor (
  id_parametro_valor SERIAL, 
  codigo VARCHAR(30) NOT NULL, 
  nombre VARCHAR(200) NOT NULL, 
  fecha_ini DATE NOT NULL, 
  fecha_fin DATE, 
  CONSTRAINT tparametro_valor_pkey PRIMARY KEY(id_parametro_valor)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE TABLE plani.ttipo_planilla (
  id_tipo_planilla SERIAL NOT NULL, 
  codigo VARCHAR(10) NOT NULL, 
  nombre VARCHAR(100) NOT NULL, 
  id_proceso_macro INTEGER NOT NULL, 
  funcion_obtener_empleados VARCHAR(200) NOT NULL, 
  tipo_presu_cc VARCHAR(50) NOT NULL, 
  PRIMARY KEY(id_tipo_planilla)
) INHERITS (pxp.tbase)
WITHOUT OIDS;


ALTER TABLE plani.ttipo_planilla
  ADD CONSTRAINT chk__ttipo_planilla__tipo_presu_cc CHECK (((tipo_presu_cc)::text = 'parametrizacion'::text) OR ((tipo_presu_cc)::text = 'ultimo_activo_periodo'::text));


CREATE TABLE plani.ttipo_columna (
  id_tipo_columna SERIAL NOT NULL,
  id_tipo_planilla INTEGER NOT NULL, 
  codigo VARCHAR(30) NOT NULL, 
  nombre VARCHAR(200) NOT NULL, 
  tipo_dato VARCHAR(30) NOT NULL, 
  descripcion TEXT NOT NULL, 
  formula VARCHAR(255), 
  compromete VARCHAR(15) NOT NULL, 
  tipo_descuento_bono VARCHAR(30), 
  decimales_redondeo INTEGER NOT NULL, 
  orden INTEGER NOT NULL,
  PRIMARY KEY(id_tipo_columna)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.ttipo_columna
  ADD CONSTRAINT chk__ttipo_columna__compromete CHECK (compromete = 'si_pago' or compromete = 'si_devengado' or compromete = 'si' or compromete = 'no');

ALTER TABLE plani.ttipo_columna
  ADD CONSTRAINT chk__ttipo_columna__tipo_dato CHECK (tipo_dato = 'basica' or
tipo_dato = 'formula' or
tipo_dato = 'variable');


ALTER TABLE plani.ttipo_columna
  ADD CONSTRAINT chk__ttipo_columna__tipo_descuento_bono CHECK (((((tipo_descuento_bono)::text = 'monto_fijo_indefinido'::text) OR ((tipo_descuento_bono)::text = 'cantidad_cuotas'::text)) OR ((tipo_descuento_bono)::text = 'monto_fijo_por_fechas'::text)) OR (tipo_descuento_bono IS NULL) OR (tipo_descuento_bono = ''));

CREATE TABLE plani.ttipo_obligacion (
  id_tipo_obligacion SERIAL, 
  id_tipo_planilla INTEGER NOT NULL, 
  codigo VARCHAR(30) NOT NULL, 
  nombre VARCHAR(150) NOT NULL, 
  tipo_obligacion VARCHAR(30), 
  dividir_por_lugar VARCHAR(2), 
  CONSTRAINT ttipo_obligacion_pkey PRIMARY KEY(id_tipo_obligacion)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.ttipo_obligacion
  ADD CONSTRAINT chk__ttipo_obligacion__tipo_obligacion CHECK (tipo_obligacion = 'pago_empleados' or
tipo_obligacion = 'pago_afp' or
tipo_obligacion = 'pago_comun' or tipo_obligacion = 'una_obligacion_x_empleado');


CREATE TABLE plani.ttipo_obligacion_columna (
  id_tipo_obligacion_columna SERIAL NOT NULL, 
  id_tipo_obligacion INTEGER NOT NULL,
  codigo_columna VARCHAR(30) NOT NULL, 
  pago VARCHAR(2) NOT NULL, 
  presupuesto VARCHAR(2) NOT NULL, 
  PRIMARY KEY(id_tipo_obligacion_columna)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.ttipo_obligacion_columna
  ADD CONSTRAINT chk__ttipo_obligacion_columna__presupuesto CHECK (presupuesto = 'si' or presupuesto = 'no');

ALTER TABLE plani.ttipo_obligacion_columna
  ADD CONSTRAINT chk__ttipo_obligacion_columna__pago CHECK (pago='si' or pago = 'no');

CREATE TABLE plani.treporte (
  id_reporte SERIAL, 
  id_tipo_planilla INTEGER,
  hoja_posicion VARCHAR(100) NOT NULL, 
  titulo_reporte VARCHAR(200) NOT NULL, 
  agrupar_por VARCHAR(20) NOT NULL, 
  numerar VARCHAR(2) NOT NULL, 
  mostrar_nombre VARCHAR(2) NOT NULL, 
  mostrar_codigo_empleado VARCHAR(2) NOT NULL, 
  mostrar_doc_id VARCHAR(2) NOT NULL, 
  mostrar_codigo_cargo VARCHAR(2) NOT NULL, 
  ordenar_por VARCHAR(25) NOT NULL, 
  CONSTRAINT treporte_pkey PRIMARY KEY(id_reporte)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__numerar CHECK (numerar='si' or numerar = 'no');

ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__mostrar_nombre CHECK (mostrar_nombre='si' or mostrar_nombre = 'no');

ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__mostrar_codigo_empleado CHECK (mostrar_codigo_empleado='si' or mostrar_codigo_empleado = 'no');
  
ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__mostrar_doc_id CHECK (mostrar_doc_id='si' or mostrar_doc_id = 'no');
  
ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__mostrar_codigo_cargo CHECK (mostrar_codigo_cargo='si' or mostrar_codigo_cargo = 'no');
  
ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__hoja_posicion CHECK (((((hoja_posicion)::text = 'carta_vertical'::text) OR ((hoja_posicion)::text = 'carta_horizontal'::text)) OR ((hoja_posicion)::text = 'oficio_vertical'::text)) OR ((hoja_posicion)::text = 'oficio_horizontal'::text));


ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__agrupar_por CHECK (((agrupar_por)::text = 'gerencia'::text) OR ((agrupar_por)::text = 'gerencia_presupuesto'::text));
  
ALTER TABLE plani.treporte
  ADD CONSTRAINT chk__treporte__ordenar_por CHECK (ordenar_por = 'nombre' or 
ordenar_por = 'doc_id' or 
ordenar_por = 'codigo_cargo' or 
ordenar_por = 'codigo_empleado');

CREATE TABLE plani.treporte_columna (
  id_reporte_columna SERIAL NOT NULL, 
  id_reporte INTEGER NOT NULL, 
  codigo_columna VARCHAR(30) NOT NULL, 
  sumar_total VARCHAR(2) NOT NULL, 
  ancho_columna INTEGER NOT NULL, 
  orden INTEGER NOT NULL,
  PRIMARY KEY(id_reporte_columna)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.treporte_columna
  ADD CONSTRAINT chk__treporte_columna__sumar_total CHECK (sumar_total = 'si' or sumar_total = 'no');

ALTER TABLE plani.tparametro_valor
  ADD COLUMN valor NUMERIC(18,2) NOT NULL;


CREATE UNIQUE INDEX ttipo_planilla_idx ON plani.ttipo_planilla
  USING btree (codigo);
  
ALTER TABLE plani.treporte
  ADD COLUMN ancho_total INTEGER DEFAULT 0 NOT NULL;
  
ALTER TABLE plani.treporte
  ADD COLUMN ancho_utilizado INTEGER DEFAULT 0 NOT NULL;
  
ALTER TABLE plani.ttipo_planilla
  ADD COLUMN funcion_validacion_nuevo_empleado VARCHAR(200) NOT NULL;
  
ALTER TABLE plani.ttipo_planilla
  ADD COLUMN calculo_horas VARCHAR(2) NOT NULL;
  
ALTER TABLE plani.ttipo_planilla
  ADD COLUMN periodicidad VARCHAR(8) NOT NULL;
  
CREATE TABLE plani.tafp (
  id_afp SERIAL, 
  nombre VARCHAR(300) NOT NULL, 
  codigo VARCHAR NOT NULL, 
  CONSTRAINT tafp_pkey PRIMARY KEY(id_afp)
) INHERITS (pxp.tbase) WITHOUT OIDS;

CREATE TABLE plani.tantiguedad (
  id_antiguedad SERIAL, 
  valor_min INTEGER NOT NULL, 
  valor_max INTEGER NOT NULL, 
  porcentaje NUMERIC NOT NULL, 
  CONSTRAINT tantiguedad_pkey PRIMARY KEY(id_antiguedad)
) INHERITS (pxp.tbase) WITHOUT OIDS;

CREATE TABLE plani.tfuncionario_afp (
  id_funcionario_afp SERIAL, 
  id_funcionario INTEGER NOT NULL, 
  id_afp INTEGER NOT NULL, 
  nro_afp VARCHAR(100), 
  tipo_jubilado VARCHAR NOT NULL, 
  fecha_ini DATE NOT NULL,
  fecha_fin DATE, 
  CONSTRAINT tfuncionario_afp_pkey PRIMARY KEY(id_funcionario_afp)
)INHERITS (pxp.tbase) WITHOUT OIDS;




CREATE TABLE plani.tdescuento_bono (
  id_descuento_bono SERIAL, 
  id_tipo_columna INTEGER NOT NULL, 
  id_funcionario INTEGER NOT NULL, 
  id_moneda INTEGER NOT NULL, 
  monto_total NUMERIC, 
  num_cuotas INTEGER, 
  valor_por_cuota NUMERIC, 
  fecha_ini DATE, 
  fecha_fin DATE, 
  CONSTRAINT tdescuento_bono_pkey PRIMARY KEY(id_descuento_bono)
)INHERITS (pxp.tbase) WITHOUT OIDS;

ALTER TABLE plani.ttipo_columna
  ADD COLUMN finiquito VARCHAR(25) NOT NULL;
  

ALTER TABLE plani.ttipo_columna
  ADD CONSTRAINT chk__ttipo_columna__finiquito CHECK (((finiquito)::text = 'ejecutar'::text) OR ((finiquito)::text = 'restar_ejecutado'::text));
  
CREATE TABLE plani.tplanilla (
  id_planilla SERIAL NOT NULL, 
  id_gestion INTEGER NOT NULL,
  id_depto INTEGER NOT NULL,
  id_periodo INTEGER,
  nro_planilla VARCHAR(100) NOT NULL,
  id_uo INTEGER,
  id_tipo_planilla INTEGER NOT NULL,
  observaciones TEXT,
  id_proceso_macro INTEGER NOT NULL,
  id_proceso_wf INTEGER,
  id_estado_wf INTEGER,
  estado VARCHAR(50) NOT NULL, 
  PRIMARY KEY(id_planilla)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE TABLE plani.tfuncionario_planilla (
  id_funcionario_planilla SERIAL NOT NULL, 
  id_funcionario INTEGER NOT NULL,
  id_planilla INTEGER NOT NULL,
  id_uo_funcionario INTEGER NOT NULL,
  id_lugar INTEGER NOT NULL,
  forzar_cheque VARCHAR(2) NOT NULL,
  finiquito VARCHAR(2) NOT NULL, 
  PRIMARY KEY(id_funcionario_planilla)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE TABLE plani.thoras_trabajadas (
  id_horas_trabajadas SERIAL NOT NULL, 
  id_uo_funcionario INTEGER NOT NULL,
  id_funcionario_planilla INTEGER NOT NULL,
  horas_normales NUMERIC(10,2) DEFAULT 0 NOT NULL, 
  horas_extras NUMERIC(10,2) DEFAULT 0 NOT NULL, 
  horas_nocturnas NUMERIC(10,2) DEFAULT 0 NOT NULL, 
  horas_disponibilidad NUMERIC(10,2) DEFAULT 0 NOT NULL, 
  tipo_contrato VARCHAR(10) NOT NULL, 
  sueldo NUMERIC(18,2) NOT NULL, 
  fecha_ini DATE NOT NULL, 
  fecha_fin DATE NOT NULL, 
  porcentaje_sueldo NUMERIC(18,2),
  PRIMARY KEY(id_horas_trabajadas)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.tfuncionario_planilla
  ADD CONSTRAINT chk__tfuncionario_planilla__finiquito 
  CHECK (finiquito = 'si' or finiquito = 'no');
  
ALTER TABLE plani.tfuncionario_planilla
  ADD CONSTRAINT chk__tfuncionario_planilla__forzar_cheque 
  CHECK (forzar_cheque = 'si' or forzar_cheque = 'no');
  
CREATE TABLE plani.tcolumna_valor (
  id_columna_valor SERIAL NOT NULL,
  id_tipo_columna INTEGER NOT NULL,
  id_funcionario_planilla INTEGER NOT NULL, 
  codigo_columna VARCHAR(30) NOT NULL, 
  formula VARCHAR(255), 
  valor NUMERIC(18,2) NOT NULL, 
  valor_generado NUMERIC(18,2) NOT NULL,  
  PRIMARY KEY(id_columna_valor)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

ALTER TABLE plani.thoras_trabajadas
  ADD COLUMN zona_franca VARCHAR(2);
  
ALTER TABLE plani.thoras_trabajadas
  ADD COLUMN frontera VARCHAR(2);

/***********************************F-SCP-JRR-PLANI-0-16/01/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-10/02/2014****************************************/

ALTER TABLE plani.treporte
  ADD COLUMN control_reporte VARCHAR(200);
  
ALTER TABLE plani.treporte_columna
  ADD COLUMN titulo_reporte_superior VARCHAR(30);
  
ALTER TABLE plani.treporte_columna
  ADD COLUMN titulo_reporte_inferior VARCHAR(30);
  
/***********************************F-SCP-JRR-PLANI-0-10/02/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-23/02/2014****************************************/

CREATE TABLE plani.tprorrateo (
  id_prorrateo SERIAL NOT NULL, 
  id_funcionario_planilla INTEGER, 
  id_horas_trabajadas INTEGER, 
  id_presupuesto INTEGER, 
  id_cc INTEGER, 
  tipo_prorrateo VARCHAR(15) NOT NULL, 
  porcentaje NUMERIC(5,2) NOT NULL, 
  PRIMARY KEY(id_prorrateo)
) INHERITS (pxp.tbase) 
WITHOUT OIDS;

CREATE TABLE plani.tprorrateo_columna (
  id_prorrateo_columna SERIAL NOT NULL,
  id_prorrateo INTEGER NOT NULL,
  id_tipo_columna INTEGER NOT NULL,  
  codigo_columna VARCHAR(30) NOT NULL, 
  porcentaje NUMERIC(5,2) NOT NULL, 
  PRIMARY KEY(id_prorrateo_columna)
) INHERITS (pxp.tbase) 
WITHOUT OIDS;

CREATE TABLE plani.tconsolidado (
  id_consolidado SERIAL NOT NULL,
  id_planilla INTEGER NOT NULL,
  id_presupuesto INTEGER,
  id_cc INTEGER,
  tipo_consolidado VARCHAR(15) NOT NULL,
  PRIMARY KEY(id_consolidado)
) INHERITS (pxp.tbase) 
WITHOUT OIDS;

CREATE TABLE plani.tconsolidado_columna (
  id_consolidado_columna SERIAL NOT NULL,
  id_consolidado INTEGER NOT NULL,
  id_tipo_columna INTEGER NOT NULL,  
  codigo_columna VARCHAR(30) NOT NULL,
  valor NUMERIC(18,2) NOT NULL, 
  valor_ejecutado NUMERIC(18,2) DEFAULT 0,
  id_partida INTEGER,
  id_cuenta INTEGER,
  id_auxiliar INTEGER,
  tipo_contrato VARCHAR(20) NOT NULL,
  PRIMARY KEY(id_consolidado_columna)
) INHERITS (pxp.tbase) 
WITHOUT OIDS;

/***********************************F-SCP-JRR-PLANI-0-23/02/2014****************************************/
/***********************************I-SCP-JRR-PLANI-0-17/06/2014****************************************/


ALTER TABLE plani.tcolumna_valor
  ALTER COLUMN valor TYPE NUMERIC(18,10);
  
ALTER TABLE plani.tcolumna_valor
  ALTER COLUMN valor_generado TYPE NUMERIC(18,10);

/***********************************F-SCP-JRR-PLANI-0-17/06/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-08/07/2014****************************************/
ALTER TABLE plani.ttipo_columna
  ALTER COLUMN formula TYPE VARCHAR(500);
  
/***********************************F-SCP-JRR-PLANI-0-08/07/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-09/07/2014****************************************/
ALTER TABLE plani.ttipo_obligacion
  ADD COLUMN es_pagable VARCHAR(2) DEFAULT 'si' NOT NULL;
  
ALTER TABLE plani.ttipo_obligacion_columna
  ADD COLUMN es_ultimo VARCHAR(2) DEFAULT 'no' NOT NULL;  

ALTER TABLE plani.tprorrateo_columna
  ADD COLUMN compromete VARCHAR(2) DEFAULT 'si' NOT NULL;

ALTER TABLE plani.ttipo_columna
  DROP CONSTRAINT chk__ttipo_columna__compromete RESTRICT;

ALTER TABLE plani.ttipo_columna
  ADD CONSTRAINT chk__ttipo_columna__compromete CHECK (((((compromete)::text = 'si_pago'::text) OR ((compromete)::text = 'si_contable'::text)) OR ((compromete)::text = 'si'::text)) OR ((compromete)::text = 'no'::text));

ALTER TABLE plani.tfuncionario_planilla
  ADD COLUMN id_afp INTEGER;

ALTER TABLE plani.tfuncionario_planilla
  ADD COLUMN id_cuenta_bancaria INTEGER;
    
/***********************************F-SCP-JRR-PLANI-0-09/07/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-11/07/2014****************************************/
CREATE TABLE plani.tobligacion (
  id_obligacion SERIAL NOT NULL, 
  id_tipo_obligacion INTEGER NOT NULL,
  id_planilla INTEGER NOT NULL, 
  id_cuenta INTEGER, 
  id_auxiliar INTEGER, 
  tipo_pago VARCHAR(50) NOT NULL, 
  acreedor VARCHAR(255) NOT NULL, 
  descripcion varchar(500), 
  monto_obligacion NUMERIC (18,2) NOT NULL,   
  PRIMARY KEY(id_obligacion) 
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE TABLE plani.tobligacion_columna (
  id_obligacion_columna SERIAL NOT NULL, 
  id_obligacion INTEGER NOT NULL,
  id_presupuesto INTEGER, 
  id_cc INTEGER, 
  id_tipo_columna INTEGER, 
  codigo_columna VARCHAR(50) NOT NULL, 
  tipo_contrato VARCHAR(5) NOT NULL, 
  monto_detalle_obligacion NUMERIC (18,2) NOT NULL,
  PRIMARY KEY (id_obligacion_columna) 
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE TABLE plani.tdetalle_transferencia (
  id_detalle_transferencia SERIAL NOT NULL, 
  id_obligacion INTEGER NOT NULL,
  id_institucion INTEGER NOT NULL, 
  nro_cuenta VARCHAR(50) NOT NULL, 
  id_funcionario INTEGER NOT NULL, 
  monto_transferencia NUMERIC(18,2) NOT NULL,   
  PRIMARY KEY (id_detalle_transferencia) 
) INHERITS (pxp.tbase)
WITHOUT OIDS;

/***********************************F-SCP-JRR-PLANI-0-11/07/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-17/11/2014****************************************/

ALTER TABLE plani.tplanilla
  ADD COLUMN id_obligacion_pago INTEGER;
  
ALTER TABLE plani.tconsolidado_columna
  ADD COLUMN id_obligacion_det INTEGER;
  
ALTER TABLE plani.tobligacion
  ADD COLUMN id_plan_pago INTEGER;
  

/***********************************F-SCP-JRR-PLANI-0-17/11/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-20/11/2014****************************************/

ALTER TABLE plani.tplanilla
  ADD COLUMN requiere_calculo VARCHAR(2) DEFAULT 'no' NOT NULL;
  
ALTER TABLE plani.tobligacion
  ADD COLUMN id_partida INTEGER;
  
ALTER TABLE plani.tobligacion
  ADD COLUMN id_afp INTEGER;
  
/***********************************F-SCP-JRR-PLANI-0-20/11/2014****************************************/

/***********************************I-SCP-JRR-PLANI-0-02/12/2014****************************************/

ALTER TABLE plani.tobligacion
  ADD COLUMN id_obligacion_pago INTEGER;
  

/***********************************F-SCP-JRR-PLANI-0-02/12/2014****************************************/
/***********************************I-SCP-JRR-PLANI-0-04/12/2014****************************************/


ALTER TABLE plani.tplanilla
  ADD COLUMN fecha_planilla DATE;
  
ALTER TABLE plani.ttipo_columna
  ADD COLUMN tiene_detalle VARCHAR(2) DEFAULT 'no' NOT NULL;  
  
CREATE TABLE plani.tcolumna_detalle (
  id_columna_detalle SERIAL NOT NULL, 
  id_horas_trabajadas INTEGER NOT NULL,
  id_columna_valor INTEGER NOT NULL, 
  valor NUMERIC(18,10) NOT NULL,
  valor_generado NUMERIC(18,10) NOT NULL,   
  PRIMARY KEY (id_columna_detalle) 
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE INDEX tcolumna_detalle_idx1 ON plani.tcolumna_detalle
  USING btree (id_horas_trabajadas);
  
CREATE INDEX tcolumna_detalle_idx2 ON plani.tcolumna_detalle
  USING btree (id_columna_valor);
  
ALTER TABLE plani.tfuncionario_planilla
  ADD COLUMN tipo_contrato VARCHAR;  

ALTER TABLE plani.thoras_trabajadas
  ADD COLUMN horas_normales_contrato NUMERIC(10,2);

  
/***********************************F-SCP-JRR-PLANI-0-04/12/2014****************************************/


/***********************************I-SCP-JRR-PLANI-0-10/07/2015****************************************/
ALTER TABLE plani.ttipo_planilla
  DROP CONSTRAINT chk__ttipo_planilla__tipo_presu_cc RESTRICT;

ALTER TABLE plani.ttipo_planilla
  ADD CONSTRAINT chk__ttipo_planilla__tipo_presu_cc CHECK (tipo_presu_cc = 'parametrizacion' OR tipo_presu_cc = 'ultimo_activo_periodo' OR tipo_presu_cc = 'prorrateo_aguinaldo' OR tipo_presu_cc = 'retroactivo_sueldo' OR tipo_presu_cc = 'retroactivo_asignaciones');

ALTER TABLE plani.tprorrateo
  ADD COLUMN tipo_contrato VARCHAR(10);  

/***********************************F-SCP-JRR-PLANI-0-10/07/2015****************************************/


/***********************************I-SCP-JRR-PLANI-0-20/07/2015****************************************/

ALTER TABLE plani.tprorrateo
  ADD COLUMN porcentaje_dias NUMERIC(5,2); 
  
/***********************************F-SCP-JRR-PLANI-0-20/07/2015****************************************/ 

/***********************************I-SCP-JRR-PLANI-0-29/07/2015****************************************/

ALTER TABLE plani.tprorrateo
  ADD COLUMN id_oficina INTEGER; 
  
ALTER TABLE plani.tprorrateo
  ADD COLUMN id_lugar INTEGER;
  
ALTER TABLE plani.tprorrateo_columna
  ADD COLUMN id_oficina INTEGER; 
  
ALTER TABLE plani.tprorrateo_columna
  ADD COLUMN id_lugar INTEGER; 
  
/***********************************F-SCP-JRR-PLANI-0-29/07/2015****************************************/ 

/***********************************I-SCP-JRR-PLANI-0-29/08/2015****************************************/
 -- object recreation
ALTER TABLE plani.ttipo_planilla
  DROP CONSTRAINT chk__ttipo_planilla__tipo_presu_cc RESTRICT;

ALTER TABLE plani.ttipo_planilla
  ADD CONSTRAINT chk__ttipo_planilla__tipo_presu_cc CHECK (((((((tipo_presu_cc)::text = 'parametrizacion'::text) OR ((tipo_presu_cc)::text = 'ultimo_activo_periodo'::text)) OR ((tipo_presu_cc)::text = 'prorrateo_aguinaldo'::text)) OR ((tipo_presu_cc)::text = 'retroactivo_sueldo'::text)) OR ((tipo_presu_cc)::text = 'retroactivo_asignaciones'::text)) OR ((tipo_presu_cc)::text = 'ultimo_activo_gestion'::text));
  
/***********************************F-SCP-JRR-PLANI-0-29/08/2015****************************************/


/***********************************I-SCP-JRR-PLANI-0-22/09/2015****************************************/

CREATE TABLE plani.tplanilla_sigma (
  id_planilla_sigma SERIAL NOT NULL, 
  id_funcionario INTEGER NOT NULL, 
  id_periodo INTEGER,
  id_gestion INTEGER NOT NULL,
  id_tipo_planilla INTEGER NOT NULL,
  sueldo_liquido numeric NOT NULL,   
  PRIMARY KEY(id_planilla_sigma)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

CREATE TABLE plani.tsigma_equivalencias (
  ci_sigma VARCHAR NOT NULL, 
  ci_erp VARCHAR NOT NULL
) 
WITHOUT OIDS;

/***********************************F-SCP-JRR-PLANI-0-22/09/2015****************************************/

/***********************************I-SCP-JRR-PLANI-0-29/10/2015****************************************/
CREATE TABLE plani.tlicencia (
  id_licencia SERIAL NOT NULL, 
  id_funcionario INTEGER NOT NULL, 
  motivo TEXT NOT NULL,
  desde DATE NOT NULL,
  hasta DATE NOT NULL,
  estado VARCHAR NOT NULL,
  id_tipo_licencia INTEGER NOT NULL,   
  PRIMARY KEY(id_licencia)
) INHERITS (pxp.tbase)
WITHOUT OIDS;


CREATE TABLE plani.ttipo_licencia (
  id_tipo_licencia SERIAL NOT NULL, 
  codigo VARCHAR(20) NOT NULL, 
  nombre VARCHAR (100) NOT NULL,
  genera_descuento VARCHAR(2) NOT NULL,   
  PRIMARY KEY(id_tipo_licencia)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

/***********************************F-SCP-JRR-PLANI-0-29/10/2015****************************************/

/***********************************I-SCP-JRR-PLANI-0-31/12/2015****************************************/

ALTER TABLE plani.ttipo_planilla
  DROP CONSTRAINT chk__ttipo_planilla__tipo_presu_cc RESTRICT;

ALTER TABLE plani.ttipo_planilla
  ADD CONSTRAINT chk__ttipo_planilla__tipo_presu_cc CHECK (((((((tipo_presu_cc)::text = 'parametrizacion'::text) OR ((tipo_presu_cc)::text = 'ultimo_activo_periodo'::text)) OR ((tipo_presu_cc)::text = 'prorrateo_aguinaldo'::text)) OR ((tipo_presu_cc)::text = 'retroactivo_sueldo'::text)) OR ((tipo_presu_cc)::text = 'retroactivo_asignaciones'::text)) OR ((tipo_presu_cc)::text = 'ultimo_activo_gestion'::text) OR ((tipo_presu_cc)::text = 'ultimo_activo_gestion_anterior'::text));
  

/***********************************F-SCP-JRR-PLANI-0-31/12/2015****************************************/

/***********************************I-SCP-JRR-PLANI-0-28/02/2016****************************************/

ALTER TABLE plani.treporte
  ADD COLUMN tipo_reporte VARCHAR(200) DEFAULT 'planilla' NOT NULL;
  
ALTER TABLE plani.treporte_columna
  ADD COLUMN tipo_columna VARCHAR(200) DEFAULT 'otro';
 
ALTER TABLE plani.treporte_columna
  ADD CONSTRAINT chk__treporte_columna__tipo_columna CHECK (tipo_columna::text = 'ingreso'::text OR tipo_columna::text = 'descuento_ley'::text OR tipo_columna::text = 'otros_descuentos'::text OR tipo_columna::text = 'iva'::text OR tipo_columna::text = 'otro'::text);
  
/***********************************F-SCP-JRR-PLANI-0-28/02/2016****************************************/


/***********************************I-SCP-JRR-PLANI-0-10/04/2016****************************************/

ALTER TABLE plani.ttipo_planilla
  ADD COLUMN funcion_calculo_horas VARCHAR(200);  

/***********************************F-SCP-JRR-PLANI-0-10/04/2016****************************************/

/***********************************I-SCP-JRR-PLANI-0-13/04/2016****************************************/

ALTER TABLE plani.ttipo_planilla
  ADD COLUMN recalcular_desde INTEGER;  
  
ALTER TABLE plani.ttipo_columna
  ADD COLUMN recalcular varchar(2) DEFAULT 'no' NOT NULL; 

/***********************************F-SCP-JRR-PLANI-0-13/04/2016****************************************/

/***********************************I-SCP-JRR-PLANI-0-25/04/2016****************************************/

ALTER TABLE plani.tplanilla
  ADD COLUMN id_int_comprobante INTEGER; 

ALTER TABLE plani.tconsolidado_columna
  ADD COLUMN id_int_transaccion INTEGER; 

/***********************************F-SCP-JRR-PLANI-0-25/04/2016****************************************/

/***********************************I-SCP-JRR-PLANI-0-26/04/2016****************************************/
ALTER TABLE plani.tprorrateo_columna ALTER COLUMN compromete TYPE varchar(20);

/***********************************F-SCP-JRR-PLANI-0-26/04/2016****************************************/

/***********************************I-SCP-JRR-PLANI-0-04/05/2016****************************************/
ALTER TABLE plani.tprorrateo
  ADD CONSTRAINT tprorrateo_chk__id_presupuesto_id_cc CHECK (id_presupuesto is not null or id_cc is not null);
/***********************************F-SCP-JRR-PLANI-0-04/05/2016****************************************/

/***********************************I-SCP-JRR-PLANI-0-10/03/2017****************************************/
ALTER TABLE plani.tobligacion
  ADD COLUMN id_int_comprobante INTEGER;

/***********************************F-SCP-JRR-PLANI-0-04/03/2017****************************************/

/***********************************I-SCP-FEA-PLANI-0-07/11/2018****************************************/
ALTER TABLE plani.tplanilla
  ADD COLUMN codigo_poa VARCHAR(25),
  ADD COLUMN obs_poa TEXT;
/***********************************F-SCP-FEA-PLANI-0-07/11/2018****************************************/

/***********************************I-SCP-FEA-PLANI-0-27/08/2019****************************************/
CREATE TABLE plani.tparam_planilla (
  id_param_planilla SERIAL,
  id_tipo_planilla INTEGER,
  porcentaje_calculo NUMERIC,
  valor_promedio NUMERIC,
  porcentaje_menor_promedio NUMERIC,
  porcentaje_mayor_promedio NUMERIC,
  fecha_incremento DATE,
  porcentaje_antiguedad NUMERIC,
  CONSTRAINT tparam_planilla_pkey PRIMARY KEY(id_param_planilla)
) INHERITS (pxp.tbase)
WITH (oids = false);
/***********************************F-SCP-FEA-PLANI-0-27/08/2019****************************************/

/***********************************I-SCP-FEA-PLANI-0-29/08/2019****************************************/
ALTER TABLE plani.tparam_planilla
  ADD COLUMN haber_basico_inc VARCHAR(256);
/***********************************F-SCP-FEA-PLANI-0-29/08/2019****************************************/

/***********************************I-SCP-FEA-PLANI-0-26/09/2019****************************************/
CREATE TABLE plani.totros_ingresos (
  id_otros_ingresos SERIAL,
  id_funcionario INTEGER NOT NULL,
  ci VARCHAR(20) NOT NULL,
  monto NUMERIC(18,2) NOT NULL,
  fecha_pago TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  id_int_comprobante INTEGER,
  nro_comprobante VARCHAR(50),
  sistema_fuente VARCHAR(256) NOT NULL,
  nro_cuenta VARCHAR(25),
  nro_orden VARCHAR(50),
  tipo_viaje VARCHAR(25),
  routing VARCHAR(128),
  motivo_viaje VARCHAR(2000),
  periodo INTEGER NOT NULL,
  gestion INTEGER NOT NULL,
  procesado VARCHAR(2) DEFAULT 'si'::character varying,
  CONSTRAINT totros_ingresos_pkey PRIMARY KEY(id_otros_ingresos)
) INHERITS (pxp.tbase)
WITH (oids = false);

COMMENT ON COLUMN plani.totros_ingresos.id_funcionario
IS 'identificador funcionario BoA.';

COMMENT ON COLUMN plani.totros_ingresos.id_int_comprobante
IS 'aplica para viaticos';

COMMENT ON COLUMN plani.totros_ingresos.nro_comprobante
IS 'aplica para viaticos';

COMMENT ON COLUMN plani.totros_ingresos.sistema_fuente
IS 'nombre sistema(refrigerio/viatico).';

COMMENT ON COLUMN plani.totros_ingresos.nro_cuenta
IS 'cuenta bancaria funcionario.';

COMMENT ON COLUMN plani.totros_ingresos.nro_orden
IS 'aplica de acuerdo al pago (opcional).';

COMMENT ON COLUMN plani.totros_ingresos.tipo_viaje
IS 'aplica para viaticos.';

COMMENT ON COLUMN plani.totros_ingresos.routing
IS 'aplica para viaticos.';

COMMENT ON COLUMN plani.totros_ingresos.motivo_viaje
IS 'aplica para viaticos.';

COMMENT ON COLUMN plani.totros_ingresos.periodo
IS 'campo obligatorio indica periodo de pago.';

COMMENT ON COLUMN plani.totros_ingresos.gestion
IS 'campo obligatorio indica gestion de pago.';

COMMENT ON COLUMN plani.totros_ingresos.procesado
IS 'campo que indica si el pago se realizo';
/***********************************F-SCP-FEA-PLANI-0-26/09/2019****************************************/

/***********************************I-SCP-FEA-PLANI-0-27/09/2019****************************************/
ALTER TABLE plani.ttipo_columna
  ALTER COLUMN orden TYPE NUMERIC;
/***********************************F-SCP-FEA-PLANI-0-27/09/2019****************************************/

/***********************************I-SCP-FEA-PLANI-1-27/09/2019****************************************/
ALTER TABLE plani.tplanilla
  ADD COLUMN modalidad VARCHAR(50);

COMMENT ON COLUMN plani.tplanilla.modalida
IS 'Campo que indica si es planilla administrativo o pilotos.';
/***********************************F-SCP-FEA-PLANI-1-27/09/2019****************************************/

/***********************************I-SCP-FEA-PLANI-1-30/07/2020****************************************/
ALTER TABLE plani.totros_ingresos
  ADD COLUMN validado_erp VARCHAR(2);

ALTER TABLE plani.totros_ingresos
  ALTER COLUMN validado_erp SET DEFAULT 'no';
/***********************************F-SCP-FEA-PLANI-1-30/07/2020****************************************/