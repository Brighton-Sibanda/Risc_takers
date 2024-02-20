# Cadence Genus(TM) Synthesis Solution, Version 18.14-s037_1, built Mar 27 2019 12:19:21

# Date: Tue Feb 13 02:12:10 2024
# Host: hanlon.wot.ece.northwestern.edu (x86_64 w/Linux 4.18.0-513.11.1.el8_9.x86_64) (10cores*40cpus*2physical cpus*Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz 25600KB)
# OS:   Red Hat Enterprise Linux release 8.9 (Ootpa)

read_hdl behav_exec_unit_synth.v
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef
elaborate
read_sdc timefile.sdc
read_sdc timefile.sdc
read_sdc timefile.sdc
read_sdc timefile.sdc
read_sdc timefile.sdc
read_sdc timefile.sdc
syn_generic
syn_map
syn_opt
report_timing > results/timing_behav_exec_unit.rpt
report_area > results/area_behav_exec_unit.rpt
write_hdl > results/genus_behav_exec_unit.v
