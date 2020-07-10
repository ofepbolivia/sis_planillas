<?php
/**
 *@package pXP
 *@file Funcionario.php
 *@author KPLIAN (admin)
 *@date 14-02-2011
 *@description  Vista para registrar los datos de un funcionario
 */

header("content-type: text/javascript; charset=UTF-8");
?>

<style type="text/css" rel="stylesheet">
    .x-selectable,
    .x-selectable * {
        -moz-user-select: text !important;
        -khtml-user-select: text !important;
        -webkit-user-select: text !important;
    }

    .x-grid-row td,
    .x-grid-summary-row td,
    .x-grid-cell-text,
    .x-grid-hd-text,
    .x-grid-hd,
    .x-grid-row,

    .x-grid-row,
    .x-grid-cell,
    .x-unselectable
    {
        -moz-user-select: text !important;
        -khtml-user-select: text !important;
        -webkit-user-select: text !important;
    }
</style>

<script>
    Phx.vista.OtrosIngresosCategoria=Ext.extend(Phx.gridInterfaz,{
        viewConfig: {
            stripeRows: false,
            getRowClass: function(record) {
                return "x-selectable";
            }
        },

        gruposBarraTareas: [
            {name:  'adm', title: '<h1 style="text-align:center; color:#4682B4;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> ADMINISTRACIÓN</h1>',grupo: 0, height: 0} ,
            {name: 'ope', title: '<h1 style="text-align: center; color: #586E7E ;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> OPERACIÓN</h1>', grupo: 1, height: 1},
            {name: 'com', title: '<h1 style="text-align: center; color: #00B167;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> COMERCIAL</h1>', grupo: 2, height: 1},
            {name: 'eve', title: '<h1 style="text-align: center; color: #B066BB;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> EVENTUALES</h1>', grupo: 3, height: 1},
            {name: 'esp', title: '<h1 style="text-align: center; color: #FFAD3A;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> ESPECIALES</h1>', grupo: 4, height: 1},
            {name: 'bajas', title: '<h1 style="text-align: center; color: #FF8F85;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> RETIRADOS</h1>', grupo: 5, height: 1},
            {name: 'externo', title: '<h1 style="text-align: center; color: #34495E;"><i class="fa fa-user fa-2x" aria-hidden="true"></i> EXTERNOS</h1>', grupo: 6, height: 1}
        ],

        constructor: function(config) {


            Phx.vista.OtrosIngresosCategoria.superclass.constructor.call(this,config);
            this.maestro = config;

            this.label_gestion = new Ext.form.Label({
                name: 'label_gestion',
                grupo: [0,1,2,3,4,5,6],
                fieldLabel: 'Gestión',
                text: ' Gestión:',
                //style: {color: 'green', font_size: '12pt'},
                readOnly:true,
                anchor: '150%',
                gwidth: 150,
                format: 'd/m/Y',
                hidden : false,
                style: 'font-size: 170%; font-weight: bold; background-image: none;color: #CD6155;'
            });
            this.gestion = new Ext.form.ComboBox({
                name: 'gestion',
                fieldLabel: 'Gestion',
                allowBlank: true,
                emptyText:'...........',
                blankText: 'Año',
                grupo: [0,1,2,3,4,5,6],
                store:new Ext.data.JsonStore(
                    {
                        url: '../../sis_parametros/control/Gestion/listarGestion',
                        id: 'id_gestion',
                        root: 'datos',
                        sortInfo:{
                            field: 'gestion',
                            direction: 'DESC'
                        },
                        totalProperty: 'total',
                        fields: ['id_gestion','gestion'],
                        // turn on remote sorting
                        remoteSort: true,
                        baseParams:{par_filtro:'gestion'}
                    }),
                valueField: 'id_gestion',
                triggerAction: 'all',
                displayField: 'gestion',
                hiddenName: 'id_gestion',
                mode:'remote',
                pageSize:50,
                queryDelay:500,
                listWidth:'100',
                hidden:false,
                width:100,
                resizable:true
            });

            this.label_periodo = new Ext.form.Label({
                name: 'label_periodo',
                grupo: [0,1,2,3,4,5],
                fieldLabel: 'Fecha Fin',
                text: ' Periodo:',
                //style: {color: 'red', font_size: '12pt'},
                readOnly:true,
                anchor: '150%',
                gwidth: 150,
                format: 'd/m/Y',
                hidden : false,
                style: 'font-size: 170%; font-weight: bold; background-image: none; color: #CD6155;'
            });

            this.periodo = new Ext.form.ComboBox({
                fieldLabel: 'Periodo',
                allowBlank: false,
                blankText: 'Mes',
                emptyText: '...........',
                grupo: [0,1,2,3,4,5,6],
                msgTarget:'side',
                store: new Ext.data.JsonStore(
                    {
                        url: '../../sis_parametros/control/Periodo/listarPeriodo',
                        id: 'id_periodo',
                        root: 'datos',
                        sortInfo: {
                            field: 'periodo',
                            direction: 'ASC'
                        },
                        totalProperty: 'total',
                        fields: ['id_periodo', 'periodo', 'id_gestion', 'literal'],
                        // turn on remote sorting
                        remoteSort: true,
                        baseParams: {par_filtro: 'gestion'}
                    }),
                valueField: 'periodo',
                triggerAction: 'all',
                displayField: 'periodo',
                hiddenName: 'id_periodo',
                mode: 'remote',
                pageSize: 50,
                queryDelay: 500,
                listWidth: '100',
                width: 100,
                resizable:true
            });

            this.tbar.addField(this.label_gestion);
            this.tbar.addField(this.gestion);
            this.tbar.addField(this.label_periodo);
            this.tbar.addField(this.periodo);

            this.addButton('btn_rep_oi',
                {
                    text: 'Reporte Otros Ingresos',
                    iconCls: 'bpagar',
                    style: 'color : #00B167; ',
                    grupo: [0,1,2,3,4,5,6],
                    disabled: false,
                    handler: this.onBtnRepOtrosIngresosPlanilla,
                    tooltip: 'Reporte Otros ingresos x Categoria'
                });

            this.iniciarEventos();
            this.init();
        },

        onBtnRepOtrosIngresosPlanilla: function(){
            Phx.CP.loadingShow();
            //var data = this.getSelectedData();
            var gestion = this.gestion.getRawValue();
            var periodo = this.periodo.getValue();

            Ext.Ajax.request({
                url:'../../sis_planillas/control/Planilla/reporteOtrosIngresos',
                params:{'gestion':gestion, 'periodo':periodo},
                success:this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });

        },

        iniciarEventos: function(){

            this.gestion.store.load({params:{start:0, limit:this.tam_pag}, scope:this, callback: function (param,op,suc) {
                    this.gestion.setValue(param[0].data.id_gestion);
                    this.gestion.collapse();
                    this.periodo.focus(false,  5);
                    this.periodo.store.baseParams.id_gestion = this.gestion.getValue();
                    this.periodo.store.reload();
                }});

            this.gestion.on('select', function (combo,rec,index) {
                this.periodo.store.baseParams.id_gestion = this.gestion.getValue();
                this.periodo.store.reload();
                if(this.periodo.getValue() != ''){

                    this.store.baseParams.gestion = this.gestion.getRawValue();
                    this.store.baseParams.periodo = this.periodo.getValue();
                    this.store.baseParams.categoria = this.tabtbar.getActiveTab().name;

                    this.load({params: {start: 0, limit: 50}});
                }
            },this);

            this.periodo.on('select', function (combo,rec,index) {

                this.store.baseParams.gestion = this.gestion.getRawValue();
                this.store.baseParams.periodo = this.periodo.getValue();
                this.store.baseParams.categoria = this.tabtbar.getActiveTab().name;

                this.load({params: {start: 0, limit: 50}});
            },this);
        },

        actualizarSegunTab: function(name, indice){

            this.store.baseParams.categoria = name;
            this.store.baseParams.gestion = this.gestion.getRawValue();
            this.store.baseParams.periodo = this.periodo.getValue();

            if(this.periodo.getValue() != '' && this.gestion.getValue() != '') {
                this.load({params: {start: 0, limit: 50}});
            }
        },


        bactGroups:[0,1,2,3,4,5,6],
        btestGroups:[null],
        bexcelGroups:[0,1,2,3,4,5,6],

        cmbGestion: new Ext.form.ComboBox({
            fieldLabel: 'Gestion',
            allowBlank: false,
            emptyText: 'Gestión...',
            blankText: 'Año',
            grupo: [0,1],
            msgTarget: 'side',
            store: new Ext.data.JsonStore(
                {
                    url: '../../sis_parametros/control/Gestion/listarGestion',
                    id: 'id_gestion',
                    root: 'datos',
                    sortInfo: {
                        field: 'gestion',
                        direction: 'DESC'
                    },
                    totalProperty: 'total',
                    fields: ['id_gestion', 'gestion'],
                    // turn on remote sorting
                    remoteSort: true,
                    baseParams: {par_filtro: 'gestion'}
                }),
            valueField: 'id_gestion',
            triggerAction: 'all',
            displayField: 'gestion',
            hiddenName: 'id_gestion',
            mode: 'remote',
            pageSize: 50,
            queryDelay: 500,
            listWidth: '180',
            width: 80
        }),
        cmbPeriodo: new Ext.form.ComboBox({
            fieldLabel: 'Periodo',
            allowBlank: false,
            blankText: 'Mes',
            emptyText: 'Periodo...',
            grupo: [0,1],
            msgTarget: 'side',
            store: new Ext.data.JsonStore(
                {
                    url: '../../sis_parametros/control/Periodo/listarPeriodo',
                    id: 'id_periodo',
                    root: 'datos',
                    sortInfo: {
                        field: 'periodo',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_periodo', 'periodo', 'id_gestion', 'literal'],
                    // turn on remote sorting
                    remoteSort: true,
                    baseParams: {par_filtro: 'gestion'}
                }),
            valueField: 'id_periodo',
            triggerAction: 'all',
            displayField: 'literal',
            hiddenName: 'id_periodo',
            mode: 'remote',
            pageSize: 50,
            disabled: true,
            queryDelay: 500,
            listWidth: '280',
            width: 100
        }),

        capturaFiltros: function (combo, record, index) {
            if (this.validarFiltros()) {
                this.store.baseParams.id_gestion = this.cmbGestion.getValue();
                this.store.baseParams.id_periodo = this.cmbPeriodo.getValue();
                this.store.baseParams.id_funcionario =  this.maestro.maestro.id_funcionario;
                this.load({params: {start: 0, limit: this.tam_pag}});
            }
        },

        validarFiltros: function () {
            if (this.cmbGestion.validate() && this.cmbPeriodo.validate()) {
                //this.desbloquearOrdenamientoGrid();
                return true;
            }
            else {
                //this.bloquearOrdenamientoGrid();
                return false;
            }
        },


        Atributos:[
            {
                // configuracion del componente
                config:{
                    labelSeparator:'',
                    inputType:'hidden',
                    name: 'id_funcionario'
                },
                type:'Field',
                form:true

            },

            {
                config:{
                    fieldLabel: "CI",
                    gwidth: 250,
                    name: 'ci',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #1A5276; font-weight: bold;font-size: 12px;">{0}</div>', value);
                    }
                },
                type:'TextField',
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    name:'id_persona',
                    origen:'PERSONA',
                    tinit:true,
                    allowBlank: true,
                    fieldLabel:'Apellidos y Nombres',
                    gdisplayField:'desc_person',//mapea al store del grid
                    anchor: '100%',
                    gwidth:250,
                    store: new Ext.data.JsonStore({
                        url: '../../sis_seguridad/control/Persona/listarPersona',
                        id: 'id_persona',
                        root: 'datos',
                        sortInfo:{
                            field: 'nombre_completo1',
                            direction: 'ASC'
                        },
                        totalProperty: 'total',
                        fields: ['id_persona','nombre_completo1','ci','tipo_documento','num_documento','expedicion','nombre','ap_paterno','ap_materno',
                            'correo','celular1','telefono1','telefono2','celular2',{name:'fecha_nacimiento', type: 'date', dateFormat:'Y-m-d'},
                            'genero','direccion','id_lugar', 'estado_civil', 'discapacitado', 'carnet_discapacitado','nacionalidad', 'nombre_lugar'],
                        // turn on remote sorting
                        remoteSort: true,
                        baseParams: {par_filtro:'p.nombre_completo1#p.ci', es_funcionario:'si'}
                    }),
                    renderer:function (value, p, record){return String.format('<b style="color: #1A5276; font-size: 12px;">{0}</b>', record.data['desc_person']);},
                    tpl: new Ext.XTemplate([
                        '<tpl for=".">',
                        '<div class="x-combo-list-item">',
                        '<div class="awesomecombo-item {checked}">',
                        '<p><b>{nombre_completo1}</b></p>',
                        '</div><p><b>CI:</b> <span style="color: green;">{ci} {expedicion}</span></p>',
                        '</div></tpl>'
                    ]),
                },
                type:'ComboRec',
                id_grupo:1,
                bottom_filter : true,
                filters:{
                    pfiltro:'vf.desc_funcionario2',
                    type:'string'
                },

                grid:true,
                form:false
            },
            {
                config:{
                    fieldLabel: "Cargo",
                    gwidth: 100,
                    name: 'cargo',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #A04000; font-weight: bold;font-size: 12px;">{0}</div>', value);
                    }
                },
                type:'TextField',
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    fieldLabel: "Contrato",
                    gwidth: 70,
                    name: 'contrato',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #A04000; font-weight: bold;font-size: 12px;">{0}</div>', value);
                    }
                },
                type:'TextField',
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Estado",
                    gwidth: 50,
                    name: 'estado',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #A04000; font-weight: bold;font-size: 12px;">{0}</div>', value);
                    }
                },
                type:'TextField',
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "C31",
                    gwidth: 50,
                    name: 'c31',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #A04000; font-weight: bold;font-size: 12px;">{0}</div>', value);
                    }
                },
                type:'TextField',
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            /*{
                config:{
                    fieldLabel: "Foto",
                    gwidth: 110,
                    inputType:'file',
                    name: 'foto',
                    //allowBlank:true,
                    buttonText: '',
                    maxLength:150,
                    anchor:'100%',
                    renderer:function (value, p, record){
                        if(record.data.nombre_archivo != '' || record.data.extension!='')
                            return String.format('{0}', "<div style='text-align:center'><img src = './../../../uploaded_files/sis_parametros/Archivo/" + record.data.nombre_archivo + "."+record.data.extension+"' align='center' width='70' height='70'/></div>");
                        else
                            return String.format('{0}', "<div style='text-align:center'><img src = '../../../lib/imagenes/NoPerfilImage.jpg' align='center' width='70' height='70'/></div>");
                    },
                    buttonCfg: {
                        iconCls: 'upload-icon'
                    }
                },
                type:'Field',
                sortable:false,
                id_grupo:1,
                grid:true,
                form:false
            },*/
            {
                config:{
                    fieldLabel: "Refrigerio",
                    gwidth: 150,
                    name: 'refrigerio',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E; font-weight: bold; font-size: 14px;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                filters:{pfiltro:'ref.monto',type:'string'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Viatico ADM",
                    gwidth: 150,
                    name: 'viatico_adm',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E; font-weight: bold; font-size: 14px;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                filters:{pfiltro:'vad.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Viatico AMP",
                    gwidth: 150,
                    name: 'viatico_amp',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E ; font-weight: bold;font-size: 14px;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                filters:{pfiltro:'vam.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Viatico OPE",
                    gwidth: 150,
                    name: 'viatico_ope',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E; font-weight: bold;font-size: 14px;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                filters:{pfiltro:'vop.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Total Viatico",
                    gwidth: 150,
                    name: 'total_viatico',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E; font-weight: bold;font-size: 14px;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    fieldLabel: "Prima",
                    gwidth: 150,
                    name: 'prima',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E; font-weight: bold;font-size: 14px;">{0}</div>', value);

                    }
                },
                type:'NumberField',
                filters:{pfiltro:'vop.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },
            {
                config:{
                    fieldLabel: "Retroactivo",
                    gwidth: 150,
                    name: 'retroactivo',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    decimalPrecision: 2,
                    renderer: function (value, p, record){
                        return String.format('<div style="color: #586E7E; font-weight: bold;font-size: 14px;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                filters:{pfiltro:'vop.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },
            /*,
            {
                config:{
                    fieldLabel: "Fecha/Pago",
                    gwidth: 100,
                    name: 'fecha_pago',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    format:'d/m/Y',
                    anchor:'100%',
                    renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
                },
                type:'DateField',
                filters:{type:'date'},
                id_grupo:1,
                grid:true,
                form:false
            }*/
        ],

        arrayDefaultColumHidden:[
            'cargo','contrato','estado','c31'
        ],
        tam_pag: 50,
        title:'Otros Ingresos',
        ActList:'../../sis_planillas/control/Reporte/listarOtrosIngresosCategoria',
        id_store:'id_funcionario',
        fields: [

            {name:'id_persona'},
            {name:'id_funcionario'},
            {name:'desc_person', type: 'string'},

            {name:'refrigerio', type: 'numeric'},
            {name:'viatico_adm', type: 'numeric'},
            {name:'viatico_amp', type: 'numeric'},
            {name:'viatico_ope', type: 'numeric'},
            {name:'total_viatico', type: 'numeric'},
            {name:'ci', type: 'string'},
            {name:'cargo', type: 'string'},
            {name:'contrato', type: 'string'},
            {name:'estado', type: 'string'},
            {name:'c31', type: 'string'},
            {name:'prima', type: 'numeric'},
            {name:'retroactivo', type: 'numeric'},
        ],
        sortInfo:{
            field: 'vf.desc_funcionario2',
            direction: 'asc'
        },
        bedit:false,
        bnew:false,
        bdel:false,
        bsave:false,
        fwidth: '90%',
        fheight: '95%'
    });
</script>