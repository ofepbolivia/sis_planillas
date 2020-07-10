<?php
/**
*@package pXP
*@file gen-SistemaDist.php
*@author  (fprudencio)
*@date 20-09-2011 10:22:05
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.FuncionarioPlanilla = {
    require:'../../../sis_organigrama/vista/funcionario/Funcionario.php',
	requireclase:'Phx.vista.funcionario',
	title:'Funcionario',
	nombreVista: 'FuncionarioPlanilla',
	bedit:false,
    bnew:false,
    bdel:false,
	constructor: function(config) {
	    
	    
        Phx.vista.FuncionarioPlanilla.superclass.constructor.call(this,config);
        this.addButton('btnAfp',
        {
            text: 'AFP',
            grupo: [0,1],
            iconCls: 'blist',
            disabled: true,
            handler: this.onBtnAfp,
            tooltip: 'Asignación de AFP'
        });
        
        this.addButton('btnBonoDesc',
        {
            text: 'Bono/Descuento',
            iconCls: 'blist',
            disabled: true,
            handler: this.onBtnBonoDesc,
            tooltip: 'Asignación de Bonos o Descuentos por Empleado'
        });

        this.addButton('btn_oi',
            {
                text: 'Otros Ingresos Funcionario',
                iconCls: 'bpagar',
                grupo: [0,1],
                disabled: true,
                handler: this.onBtnOtrosIngresosFuncionario,
                tooltip: 'Detalle Otros ingresos x Funcionario'
            });
        this.addButton('btn_oi_pla',
            {
                text: 'Otros Ingresos Planilla',
                iconCls: 'bpagar',
                grupo: [0,1,2],
                disabled: false,
                handler: this.onBtnOtrosIngresosPlanilla,
                tooltip: 'Detalle Otros ingresos x Planilla'
            });
   },

    onBtnOtrosIngresosFuncionario: function(){
        var rec = {maestro: this.getSelectedData()};

        Phx.CP.loadWindows('../../../sis_planillas/vista/funcionario/OtrosIngresos.php',
            'Otros Ingresos Funcionario',
            {
                width:700,
                height:450
            },
            rec,
            this.idContenedor,
            'OtrosIngresos'
        );
    },

    onBtnOtrosIngresosPlanilla: function(){
        var rec = {maestro: this.getSelectedData()};

        Phx.CP.loadWindows('../../../sis_planillas/vista/funcionario/OtrosIngresosPlanilla.php',
            'Otros Ingresos Planilla',
            {
                width:700,
                height:450
            },
            rec,
            this.idContenedor,
            'OtrosIngresosPlanilla'
        );
    },

   onBtnAfp: function(){
			var rec = {maestro: this.sm.getSelected().data};
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/funcionario_afp/FuncionarioAfp.php',
                    'AFP',
                    {
                        width:700,
                        height:450
                    },
                    rec,
                    this.idContenedor,
                    'FuncionarioAfp');
	},
	onBtnBonoDesc: function(){
			var rec = {maestro: this.sm.getSelected().data}; 
						      
            Phx.CP.loadWindows('../../../sis_planillas/vista/descuento_bono/DescuentoBono.php',
                    'Descuento/Bono',
                    {
                        width:700,
                        height:450
                    },
                    rec,
                    this.idContenedor,
                    'DescuentoBono');
	},
	preparaMenu:function()
    {	
        this.getBoton('btnAfp').enable();
        this.getBoton('btnBonoDesc').enable();
        this.getBoton('btn_oi').enable();
        Phx.vista.FuncionarioPlanilla.superclass.preparaMenu.call(this);
    },
    liberaMenu:function()
    {	
        this.getBoton('btnAfp').disable();
        this.getBoton('btnBonoDesc').disable();
        this.getBoton('btn_oi').disable();
        Phx.vista.FuncionarioPlanilla.superclass.liberaMenu.call(this);
    },

    tabsouth:[
        {
            url:'../../../sis_planillas/vista/funcionario/HistoricoAsignacion.php',
            title:'Historico Asignación',
            height:'50%',
            cls:'HistoricoAsignacion'
        }/*,
        {
            url:'../../../sis_organigrama/vista/uo_funcionario_ope/UoFuncionarioOpe.php',
            title:'Asignaciones Operativas',
            qtip: 'Cuando el funcionario funcionalmente tiene otra dependencia diferente a la jerárquica',
            height:'50%',
            cls:'UoFuncionarioOpe'
        }*/

    ],
    sortInfo:{
        field: 'PERSON.nombre_completo2',
        direction: 'ASC'
    }
};
</script>
