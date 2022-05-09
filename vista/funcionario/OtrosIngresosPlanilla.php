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
    Phx.vista.OtrosIngresosPlanilla=Ext.extend(Phx.gridInterfaz,{
        viewConfig: {
            stripeRows: false,
            getRowClass: function(record) {
                return "x-selectable";
            }
        },
        constructor: function(config) {


            Phx.vista.OtrosIngresosPlanilla.superclass.constructor.call(this,config);
            this.maestro = config;

            this.current_date = new Date();
            this.etiqueta_ini = new Ext.form.Label({
                name: 'etiqueta_ini',
                grupo: [0,1],
                fieldLabel: 'Fecha Inicio:',
                text: 'Fecha Inicio:',
                //style: {color: 'green', font_size: '12pt'},
                readOnly:true,
                anchor: '150%',
                gwidth: 150,
                format: 'd/m/Y',
                hidden : false,
                style: 'font-size: 170%; font-weight: bold; background-image: none;color: green;'
            });
            this.fecha_ini = new Ext.form.DateField({
                name: 'fecha_ini',
                grupo: [0,1],
                fieldLabel: 'Fecha',
                allowBlank: false,
                anchor: '60%',
                gwidth: 100,
                format: 'd/m/Y',
                hidden : false,
                disabled:false
            });

            this.etiqueta_fin = new Ext.form.Label({
                name: 'etiqueta_fin',
                grupo: [0,1],
                fieldLabel: 'Fecha Fin',
                text: 'Fecha Fin:',
                //style: {color: 'red', font_size: '12pt'},
                readOnly:true,
                anchor: '150%',
                gwidth: 150,
                format: 'd/m/Y',
                hidden : false,
                style: 'font-size: 170%; font-weight: bold; background-image: none; color: red;'
            });

            this.fecha_fin = new Ext.form.DateField({
                name: 'fecha_fin',
                grupo: [0,1],
                fieldLabel: 'Fecha',
                allowBlank: false,
                anchor: '60%',
                gwidth: 100,
                format: 'd/m/Y',
                hidden : false,
                disabled:false
            });

            this.fecha_ini.setValue(new Date(this.current_date.getFullYear(),this.current_date.getMonth(),1));
            this.fecha_fin.setValue(new Date(this.current_date.getFullYear(),this.current_date.getMonth()+1,0));

            this.tbar.addField(this.etiqueta_ini);
            this.tbar.addField(this.fecha_ini);
            this.tbar.addField(this.etiqueta_fin);
            this.tbar.addField(this.fecha_fin);
            this.addButton('btn_rep_oi',
                {
                    text: 'Reporte Otros Ingresos',
                    iconCls: 'bpagar',
                    grupo: [0,1,2],
                    disabled: false,
                    handler: this.onBtnRepOtrosIngresosPlanilla,
                    tooltip: 'Reporte Otros ingresos x Planilla'
                });
            this.iniciarEventos();
            this.init();
        },

        onBtnRepOtrosIngresosPlanilla: function(){
            Phx.CP.loadingShow();
            //var data = this.getSelectedData();
            var fecha_ini = this.fecha_ini.getValue();
            var fecha_fin = this.fecha_fin.getValue();

            Ext.Ajax.request({
                url:'../../sis_planillas/control/Planilla/reporteOtrosIngresos',
                params:{'fecha_ini':fecha_ini, 'fecha_fin':fecha_fin},
                success:this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });

        },

        iniciarEventos: function(){

            this.store.baseParams.fecha_ini = this.fecha_ini.getValue();
            this.store.baseParams.fecha_fin = this.fecha_fin.getValue();
            this.load({params: {start: 0, limit: 50}});

            this.fecha_fin.on('select', function (combo,rec,index) {
                this.store.baseParams.fecha_ini = this.fecha_ini.getValue();
                this.store.baseParams.fecha_fin = this.fecha_fin.getValue();
                this.load({params: {start: 0, limit: 50}});
            },this);
        },

        bactGroups:[0,1],
        bexcelGroups:[0,1],

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
                    name: 'id_otros_ingresos'
                },
                type:'Field',
                form:true

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
                    renderer:function (value, p, record){return String.format('<b style="color: orangered">{0}</b>', record.data['desc_person']);},
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
                    pfiltro:'person.nombre_completo2',
                    type:'string'
                },

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
                    fieldLabel: "Concepto",
                    gwidth: 200,
                    name: 'sistema_fuente',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: green; font-weight: bold;">{0}</div>', value);
                    }
                },
                type:'TextField',
                filters:{pfiltro:'toi.sistema_fuente',type:'string'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Monto/Pagado",
                    gwidth: 100,
                    name: 'monto',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    anchor:'100%',
                    disabled: true,
                    style: 'color: blue; background-color: orange;',
                    renderer: function (value, p, record){
                        return String.format('<div style="color: green; font-weight: bold;">{0}</div>', value);
                    }
                },
                type:'NumberField',
                filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

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
            }


        ],
        tam_pag: 50,
        title:'Otros Ingresos',
        ActList:'../../sis_planillas/control/Planilla/listarOtrosIngresos',
        id_store:'id_otros_ingresos',
        fields: [
            {name:'id_funcionario'},
            {name:'id_persona'},
            {name:'estado_reg', type: 'string'},
            {name:'fecha_reg', type: 'date', dateFormat:'Y-m-d'},
            {name:'id_usuario_reg', type: 'numeric'},
            {name:'fecha_mod', type: 'date', dateFormat:'Y-m-d'},
            {name:'id_usuario_mod', type: 'numeric'},
            {name:'usr_reg', type: 'string'},
            {name:'usr_mod', type: 'string'},

            {name:'nombre_archivo', type: 'string'},
            {name:'extension', type: 'string'},
            {name:'desc_person', type: 'string'},
            {name:'sistema_fuente', type: 'string'},
            {name:'monto', type: 'numeric'},
            {name:'fecha_pago', type: 'date', dateFormat:'Y-m-d'},
            {name:'id_otros_ingresos'},
        ],
        sortInfo:{
            field: 'toi.sistema_fuente',
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
