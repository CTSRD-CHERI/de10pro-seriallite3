# SWM: Serial Lite III advanced clocking scheme requires the following (from the ug_slite3_streaming.pdf manual):
# This needs to be in the projet QSF file, not the SDC file!
# set_instance_assignment -name GLOBAL_SIGNAL OFF -to *seriallite_iii_streaming*clock_gen:sink_clock_gen|dp_sync:coreclkin_reset_sync|dp_sync_regstage:dp_sync_stage_2*o*
