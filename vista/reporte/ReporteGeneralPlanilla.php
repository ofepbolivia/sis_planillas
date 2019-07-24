<?php
/**
 *@package pXP
 *@file    ReporteGlobalAF.php
 *@author  Franklin Espinoza Alvarez
 *@date    23-01-2018
 *@description Archivo con la interfaz para generación de reporte
 */
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
    Phx.vista.ReporteGeneralPlanilla = Ext.extend(Phx.frmInterfaz, {


        constructor : function(config) {
            Phx.vista.ReporteGeneralPlanilla.superclass.constructor.call(this, config);

            this.addButton('rciva',
                {
                    grupo:[0],
                    text:'Subir Codigos RC-IVA',
                    iconCls: 'bupload',
                    disabled:false,
                    handler:this.onFormUpload,
                    tooltip: '<b>Cargar archivo con codigos RC-IVA</b>'
                }
            );
            this.init();
            this.iniciarEventos();
        },

        iniciarEventos : function(){
          this.Cmp.configuracion_reporte.on('select', function (cmb, rec, index) { console.log('tipo', rec.data.tipo);
            if(rec.data.tipo == 'contacto'){
                this.Cmp.oficina.setVisible(true);

                this.Cmp.id_periodo.setVisible(false);
                this.Cmp.id_periodo.reset();
                this.Cmp.id_periodo.modificado = true;

                this.Cmp.id_gestion.setVisible(false);
                this.Cmp.id_gestion.reset();
                this.Cmp.id_gestion.modificado = true;

            }else if(rec.data.tipo == 'rc_iva'){
                this.Cmp.id_gestion.setVisible(true);
                this.Cmp.id_periodo.setVisible(true);

                this.Cmp.oficina.setVisible(false);
                this.Cmp.oficina.reset();
                this.Cmp.oficina.modificado = true;
            }else{
                this.Cmp.oficina.setVisible(false);
                this.Cmp.oficina.reset();
                this.Cmp.oficina.modificado = true;

                this.Cmp.id_gestion.setVisible(false);
                this.Cmp.id_gestion.reset();
                this.Cmp.id_gestion.modificado = true;

                this.Cmp.id_periodo.setVisible(false);
                this.Cmp.id_periodo.reset();
                this.Cmp.id_periodo.modificado = true;
            }
          }, this);

        this.Cmp.id_gestion.on('select',function(c,r,i){
            this.Cmp.id_periodo.reset();
            this.Cmp.id_periodo.store.baseParams.id_gestion = r.data.id_gestion;
        },this);

        },
        onFormUpload: function(){

            this.objWizard = Phx.CP.loadWindows('../../../sis_planillas/vista/reporte/formUploadCodigos.php',
                'Subir Archivo Codigos',
                {
                    modal: true,
                    width: 450,
                    height: 150,
                    resizable:false,
                    maximizable:false
                },
                {
                    data: {
                        aux: ''
                    }
                },
                this.idContenedor,
                'formUploadCodigos'
            );
        },


        Atributos : [

            {
                config : {
                    name : 'configuracion_reporte',
                    fieldLabel : 'Tipo Reporte',
                    allowBlank : false,
                    triggerAction : 'all',
                    lazyRender : true,
                    mode : 'local',
                    store : new Ext.data.ArrayStore({
                        fields : ['tipo', 'valor'],
                        data : [
                            ['contacto', 'Datos de Contacto'],
                            ['programatica', 'Categoria Programatica'],
                            ['aguinaldo', 'Planilla Aguinaldo'],
                            ['rc_iva', 'Planilla RC-IVA']
                        ]
                    }),
                    anchor : '70%',
                    valueField : 'tipo',
                    displayField : 'valor'
                },
                type : 'ComboBox',
                id_grupo : 0,
                form : true
            },
            {
                config:{
                    name : 'id_gestion',
                    origen : 'GESTION',
                    fieldLabel : 'Gestion',
                    allowBlank : false,
                    hidden: true
                },
                type : 'ComboRec',
                id_grupo : 0,
                form : true
            },
            {
                config:{
                    name : 'id_periodo',
                    origen : 'PERIODO',
                    fieldLabel : 'Periodo',
                    allowBlank : true,
                    hidden: true
                },
                type : 'ComboRec',
                id_grupo : 0,
                form : true
            },

            {
                config : {
                    name : 'oficina',
                    fieldLabel : 'Estación',
                    allowBlank : true,
                    emptyText : 'Estación...',
                    hidden: true,
                    store: new Ext.data.JsonStore({
                        url: '../../sis_parametros/control/Lugar/listarLugar',
                        id: 'id_lugar',
                        root: 'datos',
                        fields: ['id_lugar','codigo','nombre'],
                        totalProperty: 'total',
                        sortInfo: {
                            field: 'codigo',
                            direction: 'ASC'
                        },
                        baseParams:{par_filtro:'lug.codigo#lug.nombre', es_regional: 'si', _adicionar:'si'}
                    }),
                    tpl: new Ext.XTemplate([
                        '<tpl for=".">',
                        '<div class="x-combo-list-item">',
                        '<div class="awesomecombo-item {checked}">',
                        '<p><b>Código: {codigo}</b></p>',
                        '</div><p><b>Nombre: </b> <span style="color: green;">{nombre}</span></p>',
                        '</div></tpl>'
                    ]),
                    valueField: 'id_lugar',
                    displayField: 'nombre',
                    forceSelection: false,
                    typeAhead: false,
                    triggerAction: 'all',
                    lazyRender: true,
                    mode: 'remote',
                    pageSize: 15,
                    queryDelay: 1000,
                    minChars: 2,
                    width : 408,
                    enableMultiSelect: true
                },

                type : 'AwesomeCombo',
                id_grupo : 0,
                grid : true,
                form : true
            }

        ],
        title : 'Reporte RRHH BoA',
        ActSave : '../../sis_planillas/control/Reporte/reporteGeneralPlanilla',

        topBar : true,
        botones : false,
        labelSubmit : 'Imprimir',
        tooltipSubmit : '<b>Estimado usuario</b><br>Eliga los campos necesario e imprima su reporte.',
        //fileUpload:false,
        onSubmit:function(o){
            Phx.vista.ReporteGeneralPlanilla.superclass.onSubmit.call(this,o);
        },

        tipo : 'reporte',
        clsSubmit : 'bprint',

        Grupos : [{
            layout : 'column',
            labelAlign: 'top',
            border : false,
            autoScroll: true,
            items : [
                {
                    columnWidth: .5,
                    border: false,
                    //split: true,
                    layout: 'anchor',
                    autoScroll: true,
                    autoHeight: true,
                    collapseFirst : false,
                    collapsible: false,
                    anchor: '100%',
                    items:[
                        {
                            anchor: '100%',
                            bodyStyle: 'padding-right:5px;',
                            autoHeight: true,
                            border: false,
                            items:[
                                {
                                    xtype: 'fieldset',
                                    layout: 'form',
                                    border: true,
                                    title: 'Eliga un tipo de Reporte',
                                    //bodyStyle: 'padding: 5px 10px 10px 10px;',

                                    items: [],
                                    id_grupo: 0
                                }
                            ]
                        }
                    ]
                }
            ]
        }]
    });
</script>