<?php
/**
 *@package pXP
 *@file    ItemEntRec.php
 *@author  RCM
 *@date    07/08/2013
 *@description Reporte Material Entregado/Recibido
 */
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
	Phx.vista.DiferenciasPlanillaSigma = Ext.extend(Phx.frmInterfaz, {
		Atributos : [
		
            {
                config: {
                    name: 'id_tipo_planilla',
                    fieldLabel: 'Tipo Planilla',
                    typeAhead: false,
                    forceSelection: false,
                    hiddenName: 'id_tipo_planilla',
                    allowBlank: false,
                    emptyText: 'Lista de Planillas...',
                    store: new Ext.data.JsonStore({
                        url: '../../sis_planillas/control/TipoPlanilla/listarTipoPlanilla',
                        id: 'id_tipo_planilla',
                        root: 'datos',
                        sortInfo: {
                            field: 'codigo',
                            direction: 'ASC'
                        },
                        totalProperty: 'total',
                        fields: ['id_tipo_planilla', 'nombre', 'codigo','periodicidad'],
                        // turn on remote sorting
                        remoteSort: true,
                        baseParams: {par_filtro: 'tippla.nombre#tippla.codigo'}
                    }),
                    valueField: 'id_tipo_planilla',
                    displayField: 'nombre',
                    triggerAction: 'all',
                    lazyRender: true,
                    mode: 'remote',
                    pageSize: 20,
                    queryDelay: 200,
                    listWidth:280,
                    minChars: 2,
                    tpl: '<tpl for="."><div class="x-combo-list-item"><p>{codigo}</p><strong>{nombre}</strong> </div></tpl>'
                },
                type: 'ComboBox',
                id_grupo: 0,
                form: true
            },
            {
                    config:{
                        name : 'id_gestion',
                        origen : 'GESTION',
                        fieldLabel : 'Gestion',
                        allowBlank : false
                     },
                    type : 'ComboRec',
                    id_grupo : 0,
                    form : true
            },
            {
                config: {
                    name: 'id_planilla_aguinaldo',
                    fieldLabel: 'Planilla Aguinaldo',
                    typeAhead: false,
                    forceSelection: false,
                    hiddenName: 'id_planilla_aguinaldo',
                    hidden: true,
                    allowBlank: false,
                    emptyText: 'Planilla de Aguinaldos...',
                    store: new Ext.data.JsonStore({
                        url: '../../sis_planillas/control/Planilla/listarPlanilla',
                        id: 'id_planilla',
                        root: 'datos',
                        sortInfo: {
                            field: 'nro_planilla',
                            direction: 'ASC'
                        },
                        totalProperty: 'total',
                        fields: ['id_planilla', 'nombre_planilla', 'nro_planilla'],
                        // turn on remote sorting
                        remoteSort: true,
                        baseParams: {par_filtro: 'plani.nombre_planilla#plani.nro_planilla'}
                    }),
                    valueField: 'id_planilla',
                    displayField: 'nro_planilla',
                    triggerAction: 'all',
                    lazyRender: true,
                    mode: 'remote',
                    pageSize: 20,
                    queryDelay: 200,
                    listWidth:280,
                    minChars: 2,
                    tpl: new Ext.XTemplate([
                        '<tpl for=".">',
                        '<div class="x-combo-list-item">',
                        '<div class="awesomecombo-item {checked}">',
                        '<p><b>Nombre: {nombre_planilla}</b></p>',
                        '</div><p><b>Numero: </b> <span style="color: green;">{nro_planilla}</span></p>',
                        '</div></tpl>'
                    ]),
                    enableMultiSelect: false,
                    disabled: true
                },
                type: 'AwesomeCombo',
                id_grupo: 0,
                form: true
            },
            {
                config:{
                    name : 'id_periodo',
                    origen : 'PERIODO',
                    fieldLabel : 'Periodo',
                    allowBlank : true
                 },
                type : 'ComboRec',
                id_grupo : 0,
                form : true
           }
		],
		title : 'Generar Reporte',
		ActSave : '../../sis_planillas/control/PlanillaSigma/listarDiferenciasPlanillaSigma',
		topBar : true,
		botones : false,
		labelSubmit : 'Generar',
		tooltipSubmit : '<b>Generarl Excel</b>',
		constructor : function(config) {
			Phx.vista.DiferenciasPlanillaSigma.superclass.constructor.call(this, config);
			this.init();
			this.Cmp.id_tipo_planilla.on('select',function(c,r,i) {
				if (r.data.periodicidad == 'anual') {
					this.ocultarComponente(this.Cmp.id_periodo);
					this.Cmp.id_periodo.allowBlank = true;
					this.Cmp.id_periodo.reset();
					//this.mostrarComponente(this.Cmp.fecha_planilla);
					//this.Cmp.fecha_planilla.allowBlank = false;
				} else {
					this.mostrarComponente(this.Cmp.id_periodo);
					this.Cmp.id_periodo.allowBlank = false;
					//this.ocultarComponente(this.Cmp.fecha_planilla);
					//this.Cmp.fecha_planilla.allowBlank = true;
	
				}

				if(r.data.codigo == 'PLAGUIN'){
                    this.Cmp.id_planilla_aguinaldo.setVisible(true);
                    this.Cmp.id_planilla_aguinaldo.reset();
                    this.Cmp.id_planilla_aguinaldo.store.baseParams.id_tipo_planilla = r.data.id_tipo_planilla;
                    this.Cmp.id_planilla_aguinaldo.allowBlank = false;
                }else{
                    this.Cmp.id_planilla_aguinaldo.setVisible(false);
                    this.Cmp.id_planilla_aguinaldo.reset();
                    this.Cmp.id_planilla_aguinaldo.allowBlank = true;
                }
			},this);
			
			this.Cmp.id_gestion.on('select',function(c,r,i){
				this.Cmp.id_periodo.reset();
				this.Cmp.id_periodo.store.baseParams.id_gestion = r.data.id_gestion;
                this.Cmp.id_planilla_aguinaldo.enable();
                this.Cmp.id_planilla_aguinaldo.store.baseParams.id_gestion = r.data.id_gestion;
			},this);
			
			
		},
        onReset:function(){ 
            this.form.getForm().reset();
            this.Cmp.id_planilla_aguinaldo.disable();
        },
		clsSubmit : 'bprint',
		tipo:'reporte',
		fileUpload:false
})
</script>