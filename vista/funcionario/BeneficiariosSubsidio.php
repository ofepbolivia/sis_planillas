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
    Phx.vista.BeneficiariosSubsidio=Ext.extend(Phx.gridInterfaz,{
        viewConfig: {
            stripeRows: false,
            getRowClass: function(record) {
                return "x-selectable";
            }
        },
        constructor: function(config) {


            Phx.vista.BeneficiariosSubsidio.superclass.constructor.call(this,config);
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


            this.iniciarEventos();
            this.init();
        },
        bactGroups:[0,1],
        bexcelGroups:[0,1],

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

                    this.load({params: {start: 0, limit: 50}});
                }
            },this);

            this.periodo.on('select', function (combo,rec,index) {

                this.store.baseParams.gestion = this.gestion.getRawValue();
                this.store.baseParams.periodo = this.periodo.getValue();

                this.load({params: {start: 0, limit: 50}});
            },this);

        },

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

            {
                config:{
                    fieldLabel: "Concepto",
                    gwidth: 250,
                    name: 'nombre',
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
                //filters:{pfiltro:'toi.sistema_fuente',type:'string'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Monto Beneficio",
                    gwidth: 100,
                    name: 'valor_por_cuota',
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
                //filters:{pfiltro:'toi.monto',type:'numeric'},
                bottom_filter : true,
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Fecha Inicio",
                    gwidth: 200,
                    name: 'fecha_ini',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    format:'d/m/Y',
                    anchor:'100%',
                    renderer:function (value,p,record){return String.format('<div style="color: green; font-weight: bold;">{0}</div>', value);}
                },
                type:'TextField',
                //filters:{type:'date'},
                id_grupo:1,
                grid:true,
                form:false
            },

            {
                config:{
                    fieldLabel: "Fecha Fin",
                    gwidth: 200,
                    name: 'fecha_fin',
                    allowBlank:true,
                    maxLength:100,
                    minLength:1,
                    format:'d/m/Y',
                    anchor:'100%',
                    renderer:function (value,p,record){return String.format('<div style="color: green; font-weight: bold;">{0}</div>', value);}
                },
                type:'TextField',
                //filters:{type:'date'},
                id_grupo:1,
                grid:true,
                form:false
            }


        ],
        tam_pag: 50,
        title:'Otros Ingresos',
        ActList:'../../sis_planillas/control/FuncionarioPlanilla/listarBeneficiariosSubsidio',
        id_store:'id_otros_ingresos',
        fields: [
            {name:'id_funcionario'},
            {name:'id_persona'},
            {name:'desc_person', type: 'string'},
            {name:'nombre', type: 'string'},
            {name:'valor_por_cuota', type: 'string'},
            {name:'fecha_ini', type: 'string'},
            {name:'fecha_fin', type: 'string'}
        ],
        sortInfo:{
            field: 'desc_person',
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
