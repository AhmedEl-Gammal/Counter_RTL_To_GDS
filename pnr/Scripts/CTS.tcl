# ================================================ #
# ================== Start_Step ================== #
# ================================================ #
sh rm ./counter.dlib/counter_placement/design.ndm.lock

open_block /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/script/counter.dlib:counter_placement.design

copy_block -from_block counter.dlib:counter_placement.design -to_block counter_cts

current_block counter_cts.design

start_gui

# ================================================ #
# =================== Pre-CTS ==================== #
# ================================================ # 
# --- Check design placment ,congestion .. 
check_design -checks pre_clock_tree_stage
report_clock_qor -type structure

# --- Reset all option and configration for skew and latency 
remove_clock_tree_options -all -target_skew -target_latency 
# --- Clock sources  
report_clocks 


# ================================================ #
# ================= Target Skew ================== #
# ================================================ # 
set_clock_tree_options -target_skew 0.2 -corners [all_corners] 


# ================================================ #
# ================ Target Latency ================ #
# ================================================ # 
set_clock_tree_options -clocks clk -target_latency 1.4

#Report 
report_clock_tree_options  

# ================================================ #
# ====================== NDR ===================== #
# ================================================ #
set CTS_NDR_MIN_ROUTING_LAYER "M4"
set CTS_NDR_MAX_ROUTING_LAYER "M5"
set CTS_LEAF_NDR_MIN_ROUTING_LAYER "M1"
set CTS_LEAF_NDR_MAX_ROUTING_LAYER "M2"
set CTS_NDR_RULE_NAME "cts_w2_s2_vlg"

# defines non-default routing rules in the design.
create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule  -taper_distance 0.4  -driver_taper_distance 0.4  -widths {M3 0.16 M4 0.32 M5 0.32} -spacings {M3 0.16 M4 0.32 M5 0.32}
                
# assign non-default routing rules to specific nets
set_clock_routing_rules -rules $CTS_NDR_RULE_NAME -min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER -max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER

# over all Rules 		
report_routing_rules -verbose

# Special Clock net all Rules 
report_clock_routing_rules

#Sink pins will not follows NDRs ,stop pins of register files 
set_clock_routing_rules -net_type sink -default_rule -min_routing_layer M1 -max_routing_layer M2

# ================================================ #
# ====================== DRC ===================== #
# ================================================ #
report_ports -verbose [get_ports *clk*]
set_driving_cell -scenarios [all_scenarios] -lib_cell NBUFFX4 [get_ports *clk*]

# ================================================ #
# ====================== CRP ===================== #
# ================================================ # 
# --- To reduce On-Chip Variation (OCV) effects, clock trees try to share as many buffers as possible. 
set_app_options -name time.remove_clock_reconvergence_pessimism -value true
report_clock_settings

# ================================================ #
# ====================== Opt ===================== #
# ================================================ # 

#clock_opt -from build_clock -to build_clock
#check_pg_drc 

#clock_opt -from build_clock -to route_clock
#check_pg_drc 

#clock_opt -from route_clock -to final_opto
#check_pg_drc 

clock_opt  -from build_clock -to final_opto
check_pg_drc 
# ================================================ #
# =================== Reports ==================== #
# ================================================ #

report_routing_rules -verbose >  ../report_cts/cts_routing_rules.rpt
report_clock_routing_rules >  ../report_cts/cts_clock_routing_rules.rpt
report_ports -verbose [get_ports *clk*] >  ../report_cts/cts_ports.rpt
report_clock_settings >  ../report_cts/cts_clk_setting.rpt
report_utilization > ../report_cts/utilization.rpt
check_pg_drc  > ../report_cts/drc_final.rpt
report_design > ../report_cts/design.rpt
report_cell   > ../report_cts/cells.rpt
report_qor    > ../report_cts/qor.rpt
report_timing > ../report_cts/timing.rpt


# ================================================ #
# =================== End_Step =================== #
# ================================================ #
write_def ../output_cts/counter.def
write_verilog -include {all} ../output_cts/counter.v
save_block -as counter_cts counter.dlib:counter_cts.design
