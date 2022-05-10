
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/AXIS_Split_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Group
  set Buffering_Mode [ipgui::add_group $IPINST -name "Buffering Mode" -display_name {Buffers}]
  set_property tooltip {Buffers} ${Buffering_Mode}
  ipgui::add_param $IPINST -name "BUFFER_MODE" -parent ${Buffering_Mode} -widget comboBox

  #Adding Group
  set Data_Widths [ipgui::add_group $IPINST -name "Data Widths"]
  ipgui::add_param $IPINST -name "C_S_AXIS_TDATA_WIDTH" -parent ${Data_Widths}
  ipgui::add_param $IPINST -name "C_M_AXIS_TDATA_WIDTH" -parent ${Data_Widths}
  ipgui::add_static_text $IPINST -name "Info" -parent ${Data_Widths} -text {Slave width interface should be multiple of two, or the IP may not 
work properly}

  #Adding Group
  set Transmission_Data_Order [ipgui::add_group $IPINST -name "Transmission Data Order"]
  set MSH_FIRST [ipgui::add_param $IPINST -name "MSH_FIRST" -parent ${Transmission_Data_Order}]
  set_property tooltip {Sends most significant half first} ${MSH_FIRST}

  #Adding Group
  set Optional_Signals [ipgui::add_group $IPINST -name "Optional Signals"]
  ipgui::add_param $IPINST -name "ENABLE_TLAST" -parent ${Optional_Signals}
  ipgui::add_param $IPINST -name "ENABLE_TSTRB" -parent ${Optional_Signals}
  ipgui::add_static_text $IPINST -name "Tstrb diffrence" -parent ${Optional_Signals} -text {If Tstrb is enabled, slave width interface should be multiple of 16, 
or the IP may not work properly}


}

proc update_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
	
	set C_M_AXIS_TDATA_WIDTH ${PARAM_VALUE.C_M_AXIS_TDATA_WIDTH}
	set C_S_AXIS_TDATA_WIDTH ${PARAM_VALUE.C_S_AXIS_TDATA_WIDTH}
	set values(C_S_AXIS_TDATA_WIDTH) [get_property value $C_S_AXIS_TDATA_WIDTH]
	set_property value [gen_USERPARAMETER_C_M_AXIS_TDATA_WIDTH_VALUE $values(C_S_AXIS_TDATA_WIDTH)] $C_M_AXIS_TDATA_WIDTH
}

proc validate_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.BUFFER_MODE { PARAM_VALUE.BUFFER_MODE } {
	# Procedure called to update BUFFER_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUFFER_MODE { PARAM_VALUE.BUFFER_MODE } {
	# Procedure called to validate BUFFER_MODE
	return true
}

proc update_PARAM_VALUE.ENABLE_TLAST { PARAM_VALUE.ENABLE_TLAST } {
	# Procedure called to update ENABLE_TLAST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_TLAST { PARAM_VALUE.ENABLE_TLAST } {
	# Procedure called to validate ENABLE_TLAST
	return true
}

proc update_PARAM_VALUE.ENABLE_TSTRB { PARAM_VALUE.ENABLE_TSTRB } {
	# Procedure called to update ENABLE_TSTRB when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ENABLE_TSTRB { PARAM_VALUE.ENABLE_TSTRB } {
	# Procedure called to validate ENABLE_TSTRB
	return true
}

proc update_PARAM_VALUE.MSH_FIRST { PARAM_VALUE.MSH_FIRST } {
	# Procedure called to update MSH_FIRST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MSH_FIRST { PARAM_VALUE.MSH_FIRST } {
	# Procedure called to validate MSH_FIRST
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S_AXIS_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH PARAM_VALUE.C_S_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BUFFER_MODE { MODELPARAM_VALUE.BUFFER_MODE PARAM_VALUE.BUFFER_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUFFER_MODE}] ${MODELPARAM_VALUE.BUFFER_MODE}
}

proc update_MODELPARAM_VALUE.MSH_FIRST { MODELPARAM_VALUE.MSH_FIRST PARAM_VALUE.MSH_FIRST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MSH_FIRST}] ${MODELPARAM_VALUE.MSH_FIRST}
}

proc update_MODELPARAM_VALUE.ENABLE_TSTRB { MODELPARAM_VALUE.ENABLE_TSTRB PARAM_VALUE.ENABLE_TSTRB } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_TSTRB}] ${MODELPARAM_VALUE.ENABLE_TSTRB}
}

proc update_MODELPARAM_VALUE.ENABLE_TLAST { MODELPARAM_VALUE.ENABLE_TLAST PARAM_VALUE.ENABLE_TLAST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ENABLE_TLAST}] ${MODELPARAM_VALUE.ENABLE_TLAST}
}

