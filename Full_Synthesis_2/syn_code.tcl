
read_hdl risc_takers_v3.v
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef
elaborate InstMem RegFile PipelinedCPU DataMem
current_design InstMem
read_sdc timefile.sdc
syn_generic
syn_map
syn_opt
report_area InstMem > imem_area.rpt
write_hdl InstMem > imem_synth.v
report_timing -unconstrained  > imem_time.rpt
current_design RegFile
read_sdc timefile.sdc
syn_generic RegFile
syn_map RegFile
syn_opt RegFile
report_area RegFile > rfile_area.rpt
write_hdl RegFile > rfile_synth.v
report_timing -unconstrained  > rfile_time.rpt
current_design PipelinedCPU
read_sdc timefile.sdc
syn_generic PipelinedCPU
syn_map PipelinedCPU
syn_opt PipelinedCPU
report_area PipelinedCPU > pipe_area.rpt
write_hdl PipelinedCPU > pipe_synth.v
report_timing -unconstrained  > pipe_time.rpt
current_design DataMem
read_sdc timefile.sdc
syn_generic DataMem
syn_map DataMem
syn_opt DataMem
report_area DataMem > dmem_area.rpt
write_hdl DataMem > dmem_synth.v
report_timing -unconstrained   > dmem_time.rpt
