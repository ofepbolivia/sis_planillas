<?php
/**
 *@package pXP
 *@file    SolModPresupuesto.php
 *@author  Rensi Arteaga Copari
 *@date    30-01-2014
 *@description permites subir archivos a la tabla de documento_sol
 */
header("content-type: text/javascript; charset=UTF-8");
?>

<script>
    Phx.vista.formUploadCodigos=Ext.extend(Phx.frmInterfaz,{
        ActSave:'../../sis_planillas/control/Reporte/uploadCsvCodigosRCIVA',

        constructor:function(config){

            this.maestro = config;
            Phx.vista.formUploadCodigos.superclass.constructor.call(this,config);
            this.init();

            //var rec = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData();
        },

        Atributos:[
            {
                config:{
                    fieldLabel: "Documento (archivo csv separado por ;)",
                    gwidth: 130,
                    inputType:'file',
                    name: 'archivo',
                    labelStyle: 'color:red;font-weight:bold;',
                    buttonText: '',
                    maxLength:150,
                    width:400
                    //anchor:'100%'
                },
                type:'Field',
                form:true,
                id_grupo:0
            }
        ],
        title:'Archivo Codigos RC-IVA',
        fileUpload:true,
        fields: [
            {name:'id_solicitud', type: 'numeric'},
            {name:'lista_correos', type: 'varchar'}
        ],

        onSubmit:function(o){
            /*this.Cmp.id_solicitud.setValue(this.maestro.id_solicitud);

            if(this.Cmp.lista_correos.getValue()==''){
                Ext.Msg.show({
                    title: 'Información',
                    msg: '<b>Estimado usuario no ha elegido ningun proveedor,  para enviar el documento de detalle de su cotización, seleccion por lo menos un proveedor.</b>',
                    buttons: Ext.Msg.OK,
                    width: 512,
                    icon: Ext.Msg.INFO
                });
            }else{*/

                //Phx.CP.getPagina(this.idContenedorPadre).reload();

                Phx.vista.formUploadCodigos.superclass.onSubmit.call(this,o);

            //}
        },

        successSave:function(resp){
            Phx.CP.loadingHide();
            //Phx.CP.getPagina(this.idContenedorPadre).reload();
            this.close();
            //console.log('tigre',Phx.CP.getPagina(this.idContenedorPadre));
            //Phx.CP.getPagina(this.idContenedorPadre).sigEstado();
        },
        Grupos: [
            {
                layout: 'column',
                border: false,
                labelAlign: 'top',
                labelWidth: 150,

                defaults: {
                    border: false
                },

                items: [
                    {
                        bodyStyle: 'padding-right:10px;',
                        items: [
                            {
                                xtype: 'fieldset',
                                title: '',
                                autoHeight: true,
                                items: [],
                                id_grupo: 0
                            }
                        ]
                    }
                ]
            }
        ]
    });
</script>