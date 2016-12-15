set_global_assignment -entity "alteraPLL" -library "lib_alteraPLL" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "alteraPLL" -library "lib_alteraPLL" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "alteraPLL" -library "lib_alteraPLL" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_alteraPLL" -name SPD_FILE [file join $::quartus(sip_path) "alteraPLL.spd"]

set_global_assignment -library "lib_alteraPLL" -name MISC_FILE [file join $::quartus(sip_path) "alteraPLL_sim/alteraPLL.vo"]
