<?php
/**
*@package pXP
*@file gen-ParamPlanilla.php
*@author  (franklin.espinoza)
*@date 26-08-2019 20:06:59
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParamPlanilla=Ext.extend(Phx.gridInterfaz,{

    fwidth: '28%',
    fheight: '70%',
	constructor:function(config){
		this.maestro = config.maestro;
		console.log('maestro',this.maestro);
    	//llama al constructor de la clase padre
		Phx.vista.ParamPlanilla.superclass.constructor.call(this,config);
		this.init();
		this.store.baseParams.id_tipo_planilla = this.maestro.id_tipo_planilla;
		this.load({params:{start:0, limit:this.tam_pag}})
	},

    onButtonNew: function(){
        Phx.vista.ParamPlanilla.superclass.onButtonNew.call(this);

        this.Cmp.id_tipo_planilla.setValue(this.maestro.id_tipo_planilla);
    },

    Grupos: [
        {
            layout: 'column',
            border: false,
            labelAlign: 'top',
            defaults: {
                border: false
            },

            items: [
                {
                    bodyStyle: 'padding-right:10px;',
                    items: [

                        {
                            xtype: 'fieldset',
                            title: '<b style="color: green;">PARAMETROS DEFINIDOS POR RRHH PARA PLANILLA<b>',
                            autoHeight: true,
                            items: [],
                            id_grupo: 0
                        }

                    ]
                }

            ]
        }
    ],

	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_param_planilla'
			},
			type:'Field',
			form:true 
		},

        {
            //configuracion del componente
            config:{
                labelSeparator:'',
                inputType:'hidden',
                name: 'id_tipo_planilla'
            },
            type:'Field',
            form:true
        },

        {
            config:{
                name: 'fecha_incremento',
                fieldLabel: 'Fecha Incremento',
                allowBlank: false,
                qtip: 'Esta fecha se tomara como base para afectaciones a aquellos funcionarios que no se aplicaron incremento en caso de finiquitos',
                //anchor: '80%',
                gwidth: 100,
                width: 177,
                format: 'd/m/Y',
                msgTarget: 'side',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
            type:'DateField',
            filters:{pfiltro:'parampla.fecha_incremento',type:'date'},
            id_grupo:0,
            grid:true,
            form:true
        },

		{
			config:{
				name: 'porcentaje_calculo',
				fieldLabel: 'Porcentaje Planilla',
				allowBlank: true,
				anchor: '80%',
				gwidth: 150,
				maxLength:100
			},
				type:'NumberField',
				filters:{pfiltro:'parampla.porcentaje_calculo',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:true
		},

        {
            config:{
                name: 'porcentaje_antiguedad',
                fieldLabel: 'Porcentaje Bono Antiguedad',
                allowBlank: true,
                anchor: '80%',
                gwidth: 150,
                maxLength:100
            },
            type:'NumberField',
            filters:{pfiltro:'parampla.porcentaje_antiguedad',type:'numeric'},
            id_grupo:1,
            grid:true,
            form:true
        },

		{
			config:{
				name: 'valor_promedio',
				fieldLabel: 'Valor Promedio',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:100
			},
				type:'NumberField',
				filters:{pfiltro:'parampla.valor_promedio',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'porcentaje_menor_promedio',
				fieldLabel: 'Porcentaje Menores Promedio',
				allowBlank: true,
				anchor: '80%',
				gwidth: 200,
				maxLength:100
			},
				type:'NumberField',
				filters:{pfiltro:'parampla.porcentaje_menor_promedio',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'porcentaje_mayor_promedio',
				fieldLabel: 'Pocentaje Mayores Promedio',
				allowBlank: true,
				anchor: '80%',
				gwidth: 200,
				maxLength:100
			},
				type:'NumberField',
				filters:{pfiltro:'parampla.porcentaje_mayor_promedio',type:'numeric'},
				id_grupo:1,
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
            filters:{pfiltro:'parampla.estado_reg',type:'string'},
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
				type:'Field',
				filters:{pfiltro:'usu1.cuenta',type:'string'},
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
				filters:{pfiltro:'parampla.fecha_reg',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'id_usuario_ai',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'parampla.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
				form:false
		},
		{
			config:{
				name: 'usuario_ai',
				fieldLabel: 'Funcionaro AI',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:300
			},
				type:'TextField',
				filters:{pfiltro:'parampla.usuario_ai',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
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
				type:'Field',
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
				filters:{pfiltro:'parampla.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Parametros Planilla',
	ActSave:'../../sis_planillas/control/ParamPlanilla/insertarParamPlanilla',
	ActDel:'../../sis_planillas/control/ParamPlanilla/eliminarParamPlanilla',
	ActList:'../../sis_planillas/control/ParamPlanilla/listarParamPlanilla',
	id_store:'id_param_planilla',
	fields: [
		{name:'id_param_planilla', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_tipo_planilla', type: 'numeric'},
		{name:'porcentaje_calculo', type: 'numeric'},
		{name:'valor_promedio', type: 'numeric'},
		{name:'porcentaje_menor_promedio', type: 'numeric'},
		{name:'porcentaje_mayor_promedio', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'fecha_incremento', type: 'date',dateFormat:'Y-m-d'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'porcentaje_antiguedad', type: 'numeric'},

	],
	sortInfo:{
		field: 'id_param_planilla',
		direction: 'ASC'
	},
	bdel:true,
	bsave:false,
    btest:false
	}
)
</script>
		
		