# ================================================ #
# ================== Start_Step ================== #
# ================================================ #
sh rm ./counter.dlib/counter_cts/design.ndm.lock

open_block /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/script/counter.dlib:counter_cts.design

copy_block -from_block counter.dlib:counter_cts.design -to_block counter_route

current_block counter_route.design

start_gui

# ================================================ #
# =================== Pre-Route ================== #
# ================================================ # 
#  check for any issues that might cause problems during routing
report_qor -summary
check_design -checks pre_route_stage
#check_design -checks {pre_route_stage mv_design routability} 
set_ignored_layer -max M9 -min M1
#antenna rules 
source /home/ICer/Downloads/Lib/process/astro/tech/saed90nm_1p9m_antenna.tcl

# ================================================ #
# ================== Global Route ================ #
# ================================================ # 

route_global
check_pg_drc
check_routes -report_all_open_nets true 
# ================================================ #
# ================= Track Assign ================= #
# ================================================ # 
route_track

check_pg_drc
check_routes -report_all_open_nets true
# ================================================ #
# =============== Detailed Route ================= #
# ================================================ # 
route_detail

check_pg_drc
check_routes -report_all_open_nets true
# ================================================ #
# ============== Optimized Route ================= #
# ================================================ # 
route_opt
check_routes -report_all_open_nets true
check_pg_drc

# ================================================ #
# ================= Decap-Cells ================== #
# ================================================ #
# ????????????????????
# ================================================ #
# =================== Filler ===================== #
# ================================================ #
#get_lib_cell saed90nm_max/SHF*
set FillerCells " saed90nm_max/SHFILL1 saed90nm_max/SHFILL2 saed90nm_max/SHFILL3  "

create_stdcell_fillers -lib_cells $FillerCells

connect_pg_net -automatic
check_routes -report_all_open_nets true
check_pg_drc
remove_stdcell_fillers_with_violation

check_legality

# ================================================ #
# =================== Reports ==================== #
# ================================================ #
report_cell > ../report_route/Routing_cells.rpt
report_qor  > ../report_route/Routing_qor.rpt
report_timing -max_paths 10 > ../report_route/Routing_timing.rpt
report_timing -delay min -max_paths 10 > ../report_route/Routing_timing_hold.rpt
check_legality -verbose > ../report_route/Routing_legalization.rpt
report_utilization > ../report_route/Routing_legalization.rpt
report_routing_rules -verbose > ../report_route/Routing_routing_rules.rpt
report_clock_routing_rules > ../report_route/Routing_Clock_routing_rules.rpt
report_ports -verbose [get_ports *clk*] > ../report_route/Routing_ports.rpt
report_clock_settings > ../report_route/Routing_clk_setting.rpt

# ================================================ #
# =================== End_Step =================== #
# ================================================ #

write_verilog  -include {all} ../output_route/couter_route.v
write_sdc -output  ../output_route/couter_sdc.sdc
write_parasitics -format SPEF -output ../output_route/couter_spef.spef
write_def ../output_route/couter_def.def

# ------ GDS Output ------ #
set GDS_MAP_FILE /home/ICer/Downloads/Lib/Technology_Kit/milkyway/saed90nm.gdsout.map
set STD_CELL_GDS /home/ICer/Downloads/Lib/layout/saed90nm.gds
#There is error in gds file 
write_gds -view design -lib_cell_view frame -output_pin all -fill include -exclude_empty_block -long_names -layer_map "$GDS_MAP_FILE" -keep_data_type -merge_files "$STD_CELL_GDS" ../output_route/counter.gds

save_block -as counter_route counter.dlib:counter_route.design
