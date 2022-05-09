<?php
/**
*@package pXP
*@file gen-Planilla.php
*@author  (admin)
*@date 22-01-2014 16:11:04
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.Planilla=Ext.extend(Phx.gridInterfaz,{
    fwidth: '60%',
    fheight: '65%',
	constructor:function(config){
		this.maestro=config.maestro;		
    	//llama al constructor de la clase padre
		Phx.vista.Planilla.superclass.constructor.call(this,config);
		this.init();
		this.iniciarEventos();
		this.store.baseParams.pes_estado = 'otro';  
		this.load({params:{start:0, limit:this.tam_pag}});
		 
		this.finCons = true;
		this.addButton('ant_estado',{grupo:[0],argument: {estado: 'anterior'},text:'Anterior',iconCls: 'batras',disabled:true,handler:this.antEstado,tooltip: '<b>Pasar al Anterior Estado</b>'});
        this.addButton('sig_estado',{grupo:[0],text:'Siguiente',iconCls: 'badelante',disabled:true,handler:this.sigEstado,tooltip: '<b>Pasar al Siguiente Estado</b>'});
		this.addButton('diagrama_gantt',{grupo:[0,1,2],text:'Gant',iconCls: 'bgantt',disabled:true,handler:diagramGantt,tooltip: '<b>Diagrama Gantt de proceso macro</b>'});
  
		this.addButton('btnChequeoDocumentosWf',
            {	grupo:[0,1,2],
                text: 'Documentos',
                iconCls: 'bchecklist',
                disabled: true,
                handler: this.loadCheckDocumentosPlanWf,
                tooltip: '<b>Documentos de la Solicitud</b><br/>Subir los documetos requeridos en la solicitud seleccionada.'
            }
        );
			
		this.addButton('btnHoras',
            {	grupo:[0,1,2],
                iconCls: 'bclock',
                text:'Horas',
                disabled: true,                               
                handler: this.onButtonHorasDetalle,
                tooltip: 'Detalle Horas Trabajadas'                
            }
        );
        
        this.addButton('btnColumnas',
            {	grupo:[0,1,2],
                iconCls: 'bcalculator',
                disabled: false,
                text:'Columnas',
                tooltip: 'Gestion de Columnas (solo es posible subir csv y editar columnas si el estado es calculo_columnas)',
                xtype: 'splitbutton',
                menu: [{
                    text: 'Detalle Columnas',
                    id: 'btnColumnasDetalle-' + this.idContenedor,
                    handler: this.onButtonColumnasDetalle,
                    tooltip: 'Detalle de Columnas por Empleado',
                    scope: this
                }, {
                    text: 'Subir Columnas desde CSV',
                    id: 'btnColumnasCsv-' + this.idContenedor,
                    handler: this.onButtonColumnasCsv,
                    tooltip: 'Subir Columnas desde archivo Csv',
                    scope: this
                }, {
                    text: 'Generar descuento cheque',
                    id: 'btnGenerarCheque-' + this.idContenedor,
                    handler: this.onButtonGenerarCheque,
                    tooltip: 'Generar descuento de cheque a partir de la diferencia entre la planilla Sigma y ERP',
                    scope: this
                }]
            }
        );
        
        this.addButton('btnPresupuestos',
            {	grupo:[0,1,2],
                iconCls: 'bstats',
                disabled: false,  
                text:'Presupuestos',
                tooltip: 'Gestion de Presupuestos',
                xtype: 'splitbutton',  
                menu: [{
                    text: 'Presupuesto por Empleado',
                    id: 'btnPresupuestoEmpleado-' + this.idContenedor,
                    handler: this.onButtonPresupuestoEmpleado,
                    tooltip: 'Detalle de Presupuestos por Empleado',
                    scope: this
                }, {
                    text: 'Presupuestos Consolidados',
                    id: 'btnPresupuestosCons-' + this.idContenedor,
                    handler: this.onButtonPresupuestosConsolidado,
                    tooltip: 'Presupuestos Consolidados por Columnas' ,
                    scope: this
                }]                              
            }
        );
        this.addButton('btnObligaciones',
            {	grupo:[0,1,2],
                iconCls: 'bmoney',
                text:'Obligaciones',
                disabled: true,                
                handler: this.onButtonObligacionesDetalle,
                tooltip: 'Detalle de Obligaciones'                
            }
        );
        this.addButton('param_varios', {
            text: 'Param. Excepcionales',
            iconCls: 'bfolder',
            disabled: true,
            handler: this.onParametroPlanilla,
            tooltip: 'Parametros Varios Planilla por Gestión'
        });
        function diagramGantt(){            
            var data=this.sm.getSelected().data.id_proceso_wf;
            Phx.CP.loadingShow();
            Ext.Ajax.request({
                url:'../../sis_workflow/control/ProcesoWf/diagramaGanttTramite',
                params:{'id_proceso_wf':data},
                success:this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });         
        } 
	},
    onParametroPlanilla: function(){
        var rec = {maestro: this.getSelectedData()};

        Phx.CP.loadWindows('../../../sis_planillas/vista/param_planilla/ParamPlanilla.php',
            'Parametros Varios Planilla x Gestión',
            {
                width:700,
                height:450
            },
            rec,
            this.idContenedor,
            'ParamPlanilla');
    },
    Grupos: [
        {
            layout: 'column',
            border: false,
            defaults: {
                border: false
            },
            //labelAlign: 'top',

            items: [
                {
                    bodyStyle: 'padding-right:10px;',
                    items: [

                        {
                            xtype: 'fieldset',
                            title: '<b style="color: green;">PLANILLA</b>',
                            autoHeight: true,
                            items: [],
                            id_grupo: 0
                        }
                    ]
                }
                ,
                {
                    //labelAlign: 'top',
                    bodyStyle: 'padding-right:10px;',
                    items: [
                        {
                            xtype: 'fieldset',
                            title: '<b style="color: red;">PRESUPUESTO (SIGMA)</b>',
                            autoHeight: true,
                            items: [],
                            id_grupo: 1
                        }
                    ]
                }
            ]
        }
    ],
	gruposBarraTareas:[{name:'otro',title:'<H1 align="center"><i class="fa fa-eye"></i> En Registro</h1>',grupo:0,height:0},
						{name:'comprobante_generado',title:'<H1 align="center"><i class="fa fa-eye"></i> En Contabilidad</h1>',grupo:1,height:0},
                       {name:'planilla_finalizada',title:'<H1 align="center"><i class="fa fa-eye"></i> Finalizadas</h1>',grupo:2,height:0}
                       
                       ],
    
    
    actualizarSegunTab: function(name, indice){
        if(this.finCons) {        	 
             this.store.baseParams.pes_estado = name;                           
             this.load({params:{start:0, limit:this.tam_pag}});
        }
    },
    beditGroups: [0],
    bdelGroups:  [0],
    bactGroups:  [0,1,2],
    btestGroups: [0],
    bexcelGroups: [0,1,2],
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_planilla'
			},
			type:'Field',
			form:true 
		},
		
		{
			config:{
				name: 'nro_planilla',
				fieldLabel: 'No Planilla',
				allowBlank: false,
				anchor: '80%',
				gwidth: 150,
				maxLength:100,
                renderer:function (value, p, record){return String.format('<div style="color:green;">{0}</div>', record.data['nro_planilla']);}
			},
				type:'TextField',
				filters:{pfiltro:'plani.nro_planilla',type:'string'},
				id_grupo:1,
				grid:true,
				form:false,
				bottom_filter : true
		},
		
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
				gdisplayField: 'nombre_planilla',
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 20,
				queryDelay: 200,
                width: 270,
				listWidth:270,
				minChars: 2,
				gwidth: 120,

                msgTarget: 'side',
				tpl: '<tpl for="."><div class="x-combo-list-item"><p>{codigo}</p><strong>{nombre}</strong> </div></tpl>'
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {
				pfiltro: 'tippla.nombre',
				type: 'string'
			},
			grid: true,
			form: true,
            bottom_filter : true
		},

        {
            config:{
                name: 'momento_planilla',
                fieldLabel: 'Momento',
                allowBlank: false,
                emptyText:'Momento...',
                typeAhead: true,
                triggerAction: 'all',
                lazyRender:true,
                mode: 'local',
                gwidth: 200,
                store:['normal','extraordinaria'],
                width: 270,
                listWidth:270,
                msgTarget: 'side'
            },
            type:'ComboBox',
            filters:{
                type: 'list',
                options: ['normal','extraordinaria'],
            },
            id_grupo:0,
            grid:true,
            form:true
        },

        {
            config:{
                name:'modalidad',
                fieldLabel:'Modalidad',
                allowBlank:false,
                emptyText:'Modalidad...',
                disabled: true,
                editable: false,
                hidden: true,
                typeAhead: true,
                triggerAction: 'all',
                lazyRender:true,
                mode: 'local',
                store:['administrativo','piloto'],
                width: 177,
                renderer:function (value, p, record){return String.format('<div style="color:orangered;">{0}</div>', record.data['modalidad']);}

            },
            type:'ComboBox',
            id_grupo:0,
            filters:{
                type: 'list',
                options:['administrativo','piloto']
            },
            grid:true,
            form:true
        },
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'plani.estado',type:'string'},
				id_grupo:1,
				grid:true,
				form:false,
				bottom_filter : true
		},
		
		{
   			config:{
   				name:'id_depto',
   				 hiddenName: 'id_depto',
   				 //url: '../../sis_parametros/control/Depto/listarDeptoFiltradoXUsuario',
	   				origen:'DEPTO',
	   				allowBlank:false,
	   				fieldLabel: 'Depto',
	   				gdisplayField:'desc_depto',//dibuja el campo extra de la consulta al hacer un inner join con orra tabla
                    width: 270,
                    listWidth:270,
   			        gwidth: 250,
                    msgTarget: 'side',
	   				baseParams:{tipo_filtro:'DEPTO_UO',estado:'activo',codigo_subsistema:'ORGA'},//parametros adicionales que se le pasan al store
	      			renderer:function (value, p, record){return String.format('{0}', record.data['nombre_depto']);}
   			},
   			//type:'TrigguerCombo',
   			type:'ComboRec',
   			id_grupo:0,
   			filters:{pfiltro:'depto.nombre',type:'string'},
   		    grid:true,
   			form:true
       	},		
		{
	   			config:{
	   				name : 'id_gestion',
	   				origen : 'GESTION',
	   				fieldLabel : 'Gestion',
	   				allowBlank : false,
	   				gdisplayField : 'gestion',//mapea al store del grid
	   				gwidth : 70,
                    width: 270,
                    listWidth:270,
                    msgTarget: 'side',
		   			renderer : function (value, p, record){return String.format('{0}', record.data['gestion']);}
	       	     },
	   			type : 'ComboRec',
	   			id_grupo : 0,
	   			filters : {	
			        pfiltro : 'ges.gestion',
					type : 'numeric'
				},
	   		   
	   			grid : true,
	   			form : true,
                bottom_filter : true
	   	},
		{
	   			config:{
	   				name : 'id_periodo',
	   				origen : 'PERIODO',
	   				fieldLabel : 'Mes Proceso',
	   				allowBlank : true,
                    disabled: true,
	   				gdisplayField : 'periodo',//mapea al store del grid
	   				gwidth : 70,
                    width: 270,
                    listWidth:270,
		   			renderer : function (value, p, record){return String.format('{0}', record.data['periodo']);}
	       	     },
	   			type : 'ComboRec',
	   			id_grupo : 0,
	   			filters : {
			        pfiltro : 'per.periodo',
					type : 'numeric'
				},

	   			grid : true,
	   			form : true,
                bottom_filter : true
	   	},
	   	{
			config:{
				name: 'fecha_planilla',
				fieldLabel: 'Fecha Planilla',
				allowBlank: false,
				qtip: 'Esta fecha se tomara como base para afectaciones contables y presupuestarias de esta planilla',
				//anchor: '80%',
				gwidth: 100,
                width: 177,
                format: 'd/m/Y',
                msgTarget: 'side',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
				type:'DateField',
				filters:{pfiltro:'plani.fecha_planilla',type:'date'},
				id_grupo:0,
				grid:true,
				form:true
		},

        {
            config:{
                name : 'periodo_pago',
                origen : 'PERIODO',
                fieldLabel : 'Periodo Pago',
                allowBlank : false,
                emptyText: 'Periodo Pago',
                gdisplayField : 'periodo',//mapea al store del grid
                gwidth : 100,

                disabled: true,
                renderer:function (value, p, record){
                    var dato='Sin Periodo';
                    dato = record.data['periodo_pago']=='1'?'Enero':dato;
                    dato = record.data['periodo_pago']=='2'?'Febrero':dato;
                    dato = record.data['periodo_pago']=='3'?'Marzo':dato;
                    dato = record.data['periodo_pago']=='4'?'Abril':dato;
                    dato = record.data['periodo_pago']=='5'?'Mayo':dato;
                    dato = record.data['periodo_pago']=='6'?'Junio':dato;
                    dato = record.data['periodo_pago']=='7'?'Julio':dato;
                    dato = record.data['periodo_pago']=='8'?'Agosto':dato;
                    dato = record.data['periodo_pago']=='9'?'Septiembre':dato;
                    dato = record.data['periodo_pago']=='10'?'Octubre':dato;
                    dato = record.data['periodo_pago']=='11'?'Noviembre':dato;
                    dato = record.data['periodo_pago']=='12'?'Diciembre':dato;
                    if  (dato=='Sin Periodo'){
                        return String.format('<div ext:qtip="Pago"><span style="color: red">{0}</span></div>', dato);
                    }else{
                        return String.format('<div ext:qtip="Pago"><span style="color: green">{0}</span></div>', dato);
                    }

                }
                //renderer : function (value, p, record){return String.format('{0}', );}
            },
            valueField: 'id_periodo',
            displayField: 'periodo',
            type : 'ComboRec',
            id_grupo : 1,
            filters : {
                pfiltro : 'per.periodo',
                type : 'numeric'
            },

            grid : true,
            form : true,
            bottom_filter : true
        },

        {
            config:{
                name: 'fecha_sigma',
                fieldLabel: 'Fecha Form C31.',
                allowBlank: true,
                qtip: 'Esta fecha se tomara como base para afectaciones contables y presupuestarias Sigma',
                //anchor: '80%',
                gwidth: 120,
                width: 177,
                format: 'd/m/Y',
                msgTarget: 'side',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
            type:'DateField',
            filters:{pfiltro:'plani.fecha_sigma',type:'date'},
            id_grupo:1,
            grid:true,
            form:true
        },
        
		{
   			config:{
       		    name:'id_uo',
       		    hiddenName: 'id_uo',
          		origen:'UO',
   				fieldLabel:'UO',
   				gdisplayField:'desc_uo',//mapea al store del grid
   				gwidth:100,
   				emptyText:'Dejar blanco para toda la empresa...',
   				//anchor: '80%',
                width: 270,
                listWidth:270,
   				baseParams: {nivel: 'si'},
   				allowBlank:true,
                renderer:function (value, p, record){return String.format('{0}', record.data['desc_uo']);}
       	     },
   			type:'ComboRec',
   			id_grupo:0,
   			filters:{	
		        pfiltro:'uo.codigo#uo.nombre_unidad',
				type:'string'
			},
   		     grid:true,
   			form:true
   	      },
   	      {
			config:{
				name: 'observaciones',
				fieldLabel: 'Observaciones',
				allowBlank: false,
				//anchor: '80%',
                width: 290,
				gwidth: 250
			},
				type:'TextArea',
				filters:{pfiltro:'plani.observaciones',type:'string'},
				id_grupo:0,
				grid:true,
				form:true
		},
		
		{
			config:{
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:10
			},
				type:'TextField',
				filters:{pfiltro:'plani.estado_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		{
			config:{
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'plani.fecha_reg',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'usu1.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false,
				bottom_filter : true
		},
		{
			config:{
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'usu2.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'plani.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Planilla',
	ActSave:'../../sis_planillas/control/Planilla/insertarPlanilla',
	ActDel:'../../sis_planillas/control/Planilla/eliminarPlanilla',
	ActList:'../../sis_planillas/control/Planilla/listarPlanilla',
	id_store:'id_planilla',
	fields: [
		{name:'id_planilla', type: 'numeric'},
		{name:'id_periodo', type: 'numeric'},
		{name:'id_depto', type: 'numeric'},
		{name:'nombre_depto', type: 'string'},
		{name:'id_gestion', type: 'numeric'},
		{name:'gestion', type: 'numeric'},
		{name:'periodo', type: 'numeric'},
		{name:'nombre_planilla', type: 'string'},
		{name:'calculo_horas', type: 'string'},
		{name:'plani_tiene_presupuestos', type: 'string'},
		{name:'plani_tiene_costos', type: 'string'},
		{name:'desc_uo', type: 'string'},
		{name:'id_uo', type: 'numeric'},
		{name:'id_tipo_planilla', type: 'numeric'},
		{name:'id_proceso_macro', type: 'numeric'},
		{name:'id_proceso_wf', type: 'numeric'},
		{name:'id_estado_wf', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'observaciones', type: 'string'},
		{name:'nro_planilla', type: 'string'},
		{name:'estado', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'fecha_planilla', type: 'date',dateFormat:'Y-m-d'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'periodo_pago', type: 'numeric'},
		{name:'fecha_sigma', type: 'date',dateFormat:'Y-m-d'},
        {name:'modalidad', type: 'string'},
        {name:'momento_planilla', type: 'string'}

	],
	sortInfo:{
		field: 'id_planilla',
		direction: 'DESC'
	},
	bdel:true,
	bsave:true,
	iniciarEventos : function() {
        var tipo_planilla = '';
		this.Cmp.id_tipo_planilla.on('select',function(c,r,i) {
		    tipo_planilla = r.data.codigo;
			if (r.data.periodicidad == 'anual') {
				this.ocultarComponente(this.Cmp.id_periodo);
				this.Cmp.id_periodo.allowBlank = true;
				this.Cmp.id_periodo.reset();
                //franklin.espinoza(26/9/2019) agregamos campo modalidad solo PLASUE
                if(r.data.codigo == 'PLAGUIN'){
                    this.mostrarComponente(this.Cmp.modalidad);
                    this.Cmp.modalidad.allowBlank = false;
                    this.Cmp.modalidad.reset();
                    this.Cmp.modalidad.modificado = true;
                    this.Cmp.modalidad.setDisabled(false);
                }else{
                    this.ocultarComponente(this.Cmp.modalidad);
                    this.Cmp.modalidad.allowBlank = true;
                    this.Cmp.modalidad.reset();
                    this.Cmp.modalidad.modificado = true;
                }

			} else {
				this.mostrarComponente(this.Cmp.id_periodo);
				this.Cmp.id_periodo.allowBlank = false;
                //franklin.espinoza(26/9/2019) agregamos campo modalidad solo PLASUE
                if(r.data.codigo == 'PLASUE' || r.data.codigo == 'PLASUE_RVP'){
                    this.mostrarComponente(this.Cmp.modalidad);
                    this.Cmp.modalidad.allowBlank = false;
                    this.Cmp.modalidad.reset();
                    this.Cmp.modalidad.modificado = true;
                    this.Cmp.modalidad.setDisabled(false);
                }else{
                    this.ocultarComponente(this.Cmp.modalidad);
                    this.Cmp.modalidad.allowBlank = true;
                    this.Cmp.modalidad.reset();
                    this.Cmp.modalidad.modificado = true;
                }
			}

            if(r.data.codigo == 'PLASUB'){
                this.Cmp.fecha_planilla.editable =  false;
                this.Cmp.fecha_planilla.disabled =  true;
                this.Cmp.fecha_planilla.readOnly =  true;
            }else{
                this.Cmp.fecha_planilla.editable =  true;
                this.Cmp.fecha_planilla.disabled =  false;
                this.Cmp.fecha_planilla.readOnly =  false;
            }
		},this);
		
		this.Cmp.id_gestion.on('select',function(c,r,i){
            this.Cmp.id_periodo.setDisabled(false);
			this.Cmp.id_periodo.reset();
			this.Cmp.id_periodo.store.baseParams.id_gestion = r.data.id_gestion;
            //this.Cmp.id_periodo.store.reload();
			this.Cmp.periodo_pago.setDisabled(false);
            this.Cmp.periodo_pago.reset();
            this.Cmp.periodo_pago.store.baseParams.id_gestion = r.data.id_gestion;
		},this);
        this.getComponente('id_periodo').on('select',function (c,r,i) {

            var fecha_actual = new Date();

            if(tipo_planilla == 'PLASUE'){
                let year =this.Cmp.id_gestion.getRawValue();
                let month = r.data.periodo;
                fecha_actual = new Date(year, month, 0);
            }else{
                fecha_actual.setDate(1);
                fecha_actual.setMonth(r.data.periodo-1);
            }
            this.getComponente('fecha_sigma').setMinValue(fecha_actual);
            this.getComponente('fecha_planilla').setValue(fecha_actual);
        }, this);
		
		
	},
	onButtonEdit : function () {

        var rec = this.getSelectedData();

        //franklin.espinoza(26/9/2019) agregamos campo modalidad solo PLASUE
        if(rec.nombre_planilla == 'PLASUE' || rec.nombre_planilla == 'PLASUE_RVP'){
            this.mostrarComponente(this.Cmp.modalidad);
            this.Cmp.modalidad.setDisabled(false);
            this.Cmp.modalidad.allowBlank = false;
        }else{
            this.ocultarComponente(this.Cmp.modalidad);
            this.Cmp.modalidad.allowBlank = true;
            this.Cmp.modalidad.reset();
            this.Cmp.modalidad.modificado = true;
        }

        this.Cmp.periodo_pago.setDisabled(false);
        this.Cmp.periodo_pago.store.baseParams.id_gestion = rec.id_gestion;
		this.ocultarComponente(this.Cmp.id_depto);
    	this.ocultarComponente(this.Cmp.id_tipo_planilla);
    	this.ocultarComponente(this.Cmp.id_uo);
    	this.ocultarComponente(this.Cmp.id_periodo);
    	this.ocultarComponente(this.Cmp.id_gestion); 
    	Phx.vista.Planilla.superclass.onButtonEdit.call(this);
    	
    },
    onButtonAjax : function (params){
    	var rec = this.sm.getSelected();	
    	Phx.CP.loadingShow();	
		Ext.Ajax.request({
				url:'../../sis_planillas/control/Planilla/ejecutarProcesoPlanilla',
				success:this.successDel,
				failure:this.conexionFailure,
				params:{'id_planilla':rec.data.id_planilla, 'accion':params.argument.accion},
				timeout:this.timeout,
				scope:this
			})
    	    	
    },
    onButtonHorasDetalle : function() {
    	var rec = {maestro: this.sm.getSelected().data};
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/horas_trabajadas/HorasTrabajadas.php',
                    'Horas Trabajadas por Empleado',
                    {
                        width:800,
                        height:'90%'
                    },
                    rec,
                    this.idContenedor,
                    'HorasTrabajadas');
    },
    onButtonColumnasDetalle : function() {
    	var rec = {maestro: this.sm.getSelected().data};
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/funcionario_planilla/FuncionarioPlanillaColumna.php',
                    'Detalle de Columnas por Empleado',
                    {
                        width:800,
                        height:'90%'
                    },
                    rec,
                    this.idContenedor,
                    'FuncionarioPlanillaColumna');
    },
    
    onButtonPresupuestoEmpleado : function() {
    	var rec = {maestro: this.sm.getSelected().data};
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/presupuesto_empleado/PresupuestoEmpleado.php',
                    'Apropiacion Presupuestaria por Empleado',
                    {
                        width:800,
                        height:'90%'
                    },
                    rec,
                    this.idContenedor,
                    'PresupuestoEmpleado');
    },
    
    onButtonPresupuestosConsolidado : function () {
    		var rec = {maestro: this.sm.getSelected().data};
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/consolidado/Consolidado.php',
                    'Consolidado Presupuestario',
                    {
                        width:800,
                        height:'90%'
                    },
                    rec,
                    this.idContenedor,
                    'Consolidado');
    },
    
    onButtonObligacionesDetalle : function () {
    		var rec = {maestro: this.sm.getSelected().data};
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/obligacion/Obligacion.php',
                    'Obligaciones',
                    {
                        width:800,
                        height:'90%'
                    },
                    rec,
                    this.idContenedor,
                    'Obligacion');
    },
    
    onButtonNew : function () {
    	this.mostrarComponente(this.Cmp.id_depto);
    	this.mostrarComponente(this.Cmp.id_tipo_planilla);
    	this.mostrarComponente(this.Cmp.id_uo);
    	this.mostrarComponente(this.Cmp.id_periodo);
    	this.mostrarComponente(this.Cmp.id_gestion);

        //franklin.espinoza(26/9/2019) agregamos campo modalidad solo PLASUE
        this.ocultarComponente(this.Cmp.modalidad);
        this.Cmp.modalidad.reset();
        this.Cmp.modalidad.modificado = true;
        this.Cmp.modalidad.setDisabled(true);

    	Phx.vista.Planilla.superclass.onButtonNew.call(this);
    	
    },
    onButtonColumnasCsv : function() {                   
        var rec=this.sm.getSelected();
        Phx.CP.loadWindows('../../../sis_planillas/vista/planilla/ColumnaCsv.php',
        'Subir valores para columna',
        {
            modal:true,
            width:450,
            height:200
        },rec.data,this.idContenedor,'ColumnaCsv')
    },
    onButtonGenerarCheque : function() {                   
        var rec=this.sm.getSelected();
	    Phx.CP.loadingShow();
	        
	        Ext.Ajax.request({
	            url:'../../sis_planillas/control/Planilla/generarDescuentoCheque',
	            params:{
	                    
	                id_planilla:  rec.data.id_planilla
	                },
	            success:this.successSave,
	            failure: this.conexionFailure,	            
	            timeout:this.timeout,
	            scope:this
	        });
	},
    preparaMenu:function()
    {	var rec = this.sm.getSelected();
        this.desactivarMenu();  
        Phx.vista.Planilla.superclass.preparaMenu.call(this);       
        //MANEJO DEL BOTON DE GESTION DE HORAS      
        if (rec.data.calculo_horas == 'si') {
        	this.getBoton('btnHoras').enable();
        }
        this.getBoton('btnColumnas').enable();
        if (rec.data.estado== 'calculo_columnas') {
        	this.getBoton('btnColumnas').menu.items.items[0].enable();
        	this.getBoton('btnColumnas').menu.items.items[1].enable(); 
        	this.getBoton('btnColumnas').menu.items.items[2].enable();       	
        } else {
        	this.getBoton('btnColumnas').menu.items.items[0].enable();
        	this.getBoton('btnColumnas').menu.items.items[1].disable();
        	this.getBoton('btnColumnas').menu.items.items[2].disable(); 
        }
        
        if (rec.data.estado == 'registro_funcionarios') {
	          this.getBoton('ant_estado').disable();
	          this.getBoton('sig_estado').enable();
                          
        } else if (rec.data.estado == 'comprobante_generado' ||
        	 rec.data.estado == 'planilla_finalizada') {
        	 this.getBoton('ant_estado').disable();
             this.getBoton('sig_estado').disable();
             this.getBoton('del').disable();
             
        } else if (rec.data.estado == 'obligaciones_generadas' ||
        	 rec.data.estado == 'comprobante_presupuestario_validado' ||
        	 rec.data.estado == 'comprobante_obligaciones') {
        	 this.getBoton('ant_estado').enable();
             this.getBoton('sig_estado').disable();
			 this.getBoton('del').disable(); 
        } else if(rec.data.estado == 'vbpoa' || rec.data.estado == 'suppresu' || rec.data.estado == 'vbpresupuestos'){
			this.getBoton('ant_estado').disable();
			this.getBoton('sig_estado').disable();
		} else {
        	 this.getBoton('ant_estado').enable();
             this.getBoton('sig_estado').enable();
        }

        
        this.getBoton('btnChequeoDocumentosWf').enable();       
         
        //MANEJO DEL BOTON DE GESTION DE PRESUPUESTOS
        
    	
    	this.getBoton('btnPresupuestos').enable();           
        this.getBoton('btnObligaciones').enable();         
        this.getBoton('diagrama_gantt').enable();
        this.getBoton('param_varios').enable();
    },
    liberaMenu:function()
    {	
        this.desactivarMenu();        
        Phx.vista.Planilla.superclass.liberaMenu.call(this);
        this.getBoton('param_varios').disable();
    },
    desactivarMenu:function() {
    	
    	this.getBoton('del').disable();    	
    	this.getBoton('btnHoras').disable();     	
        this.getBoton('btnColumnas').disable();        
        this.getBoton('btnPresupuestos').disable(); 
        this.getBoton('btnObligaciones').disable();
        this.getBoton('diagrama_gantt').disable();
        this.getBoton('ant_estado').disable();
        this.getBoton('sig_estado').disable();
        this.getBoton('btnChequeoDocumentosWf').disable();  
        this.getBoton('btnPresupuestos').disable(); 
        
    },
    south:{
		  url:'../../../sis_planillas/vista/funcionario_planilla/FuncionarioPlanilla.php',
		  title:'Funcionarios', 
		  height:'50%',
		  cls:'FuncionarioPlanilla'
	},    
  loadCheckDocumentosPlanWf:function() {
            var rec=this.sm.getSelected();
            rec.data.nombreVista = this.nombreVista;
            Phx.CP.loadWindows('../../../sis_workflow/vista/documento_wf/DocumentoWf.php',
                    'Chequear documento del WF',
                    {
                        width:'90%',
                        height:500
                    },
                    rec.data,
                    this.idContenedor,
                    'DocumentoWf'
        )
    },
    sigEstado:function(){                   
      var rec=this.sm.getSelected();
      this.objWizard = Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/FormEstadoWf.php',
                                'Estado de Wf',
                                {
                                    modal:true,
                                    width:700,
                                    height:450
                                }, {data:{
                                       id_estado_wf:rec.data.id_estado_wf,
                                       id_proceso_wf:rec.data.id_proceso_wf,
                                       fecha_ini:rec.data.fecha_tentativa,
                                       //url_verificacion:'../../sis_tesoreria/control/PlanPago/siguienteEstadoPlanPago'
                                       
                                       
                                    
                                    }}, this.idContenedor,'FormEstadoWf',
                                {
                                    config:[{
                                              event:'beforesave',
                                              delegate: this.onSaveWizard,
                                              
                                            }],
                                    
                                    scope:this
                                 });        
               
     },
     
    
     onSaveWizard:function(wizard,resp){
        Phx.CP.loadingShow();
        
        Ext.Ajax.request({
            url:'../../sis_planillas/control/Planilla/siguienteEstadoPlanilla',
            params:{
                    
                id_proceso_wf_act:  resp.id_proceso_wf_act,
                id_estado_wf_act:   resp.id_estado_wf_act,
                id_tipo_estado:     resp.id_tipo_estado,
                id_funcionario_wf:  resp.id_funcionario_wf,
                id_depto_wf:        resp.id_depto_wf,
                obs:                resp.obs,
                json_procesos:      Ext.util.JSON.encode(resp.procesos)
                },
            success:this.successWizard,
            failure: this.conexionFailure,
            argument:{wizard:wizard},
            timeout:this.timeout,
            scope:this
        });
    },
     
    successWizard:function(resp){
        Phx.CP.loadingHide();
        resp.argument.wizard.panel.destroy()
        this.reload();
     },
     
     antEstado:function(){
         var rec=this.sm.getSelected();
            Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/AntFormEstadoWf.php',
            'Estado de Wf',
            {
                modal:true,
                width:450,
                height:250
            }, {data:rec.data}, this.idContenedor,'AntFormEstadoWf',
            {
                config:[{
                          event:'beforesave',
                          delegate: this.onAntEstado,
                        }
                        ],
               scope:this
             })
   },
   
   onAntEstado:function(wizard,resp){
            Phx.CP.loadingShow(); 
            Ext.Ajax.request({ 
                // form:this.form.getForm().getEl(),
                url:'../../sis_planillas/control/Planilla/anteriorEstadoPlanilla',
                params:{
                        id_proceso_wf:resp.id_proceso_wf,
                        id_estado_wf:resp.id_estado_wf,  
                        obs:resp.obs
                 },
                argument:{wizard:wizard},  
                success:this.successEstadoSinc,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });
           
     },
     
   successEstadoSinc:function(resp){
        Phx.CP.loadingHide();
        resp.argument.wizard.panel.destroy()
        this.reload();
     },  
	
   }
)
</script>
		
		