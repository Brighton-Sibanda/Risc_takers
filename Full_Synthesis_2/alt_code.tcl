
read_hdl risc_takers_v3.v
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef
elaborate InstMem RegFile PipelinedCPU DataMem
current_design InstMem
read_sdc timefile.sdc
#syn_generic InstMem
#syn_map InstMem
#syn_opt InstMem
#report_area InstMem > imem_area.rpt
#write_hdl InstMem > imem_synth.v
#current_design InstMem
#report_timing  > imem_time.rpt
