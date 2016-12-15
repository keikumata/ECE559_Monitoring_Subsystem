set_global_assignment -entity "fiftyToTenPLL" -library "lib_fiftyToTenPLL" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "fiftyToTenPLL" -library "lib_fiftyToTenPLL" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "fiftyToTenPLL" -library "lib_fiftyToTenPLL" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fiftyToTenPLL" -name SPD_FILE [file join $::quartus(sip_path) "fiftyToTenPLL.spd"]

set_global_assignment -library "lib_fiftyToTenPLL" -name MISC_FILE [file join $::quartus(sip_path) "fiftyToTenPLL_sim/fiftyToTenPLL.vho"]
