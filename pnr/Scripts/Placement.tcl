# ================================================ #
# ================== Start_Step ================== #
# ================================================ #
sh rm ./counter.dlib/counter_powerplan1/design.ndm.lock

open_block /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/script/counter.dlib:counter_powerplan1.design

copy_block -from_block counter.dlib:counter_powerplan1.design -to_block counter_placement

current_block counter_placement.design

start_gui

# ================================================ #
# ================= def file read ================ #
# ================================================ # 
read_def ../../dft/output/counter_scan.def
check_design -checks pre_placement_stage

# ================================================ #
# ============== Detailed Placement ============== #
# ================================================ #

# --- Detailed Placement divided to { Coarse placment , legalized placement  } 

# -- Performs coarse {approximate locations for cells, Cells overlap,No logic optimization }
# --- buffering_aware_timing_driven :  model that estimates the effects of buffering long nets and high fanout nets later in the flow.
#create_placement    -effort high  -timing_driven -buffering_aware_timing_driven -congestion -congestion_effort  medium   -incremental
create_placement    -effort high  -congestion -congestion_effort  high   -incremental

# --- Legalized placement each  illegal cell will be legal location 
legalize_placement  -incremental 
check_pg_drc  > ../report_pl/drc_legalized.rpt

# ================================================ #
# ================= Spare cells  ================= #
# ================================================ #
# --- Get library cells to insert as spare cells 
get_lib_cell saed90nm_max/NA*
get_lib_cell saed90nm_max/IN*
# --- add spare cells without legalized 
add_spare_cells -num_cells {NAND2X0 2 INVX0  2}  -cell_name SpareCell -random_distribution -input_pin_connect_type tie_low

# --- Spread spare cells by randmization 
spread_spare_cells -cells [get_cells Spare*] -random_distribution

# --- legalized Sparecells 
place_eco_cells -cells [get_cells Spare*] -legalize_only

# ================================================ #
# ============ Placement Optimization ============ #
# ================================================ #
# --- initial_place, initial_drc, initial_opto, final_place, and final_opto.

place_opt -from initial_place -to final_opto
check_pg_drc > ../report_pl/drc_final_opto.rpt
# --- congestion is found to be a problem after placement and optimization It can improve 
refine_opt
check_pg_drc > ../report_pl/drc_refine_opto.rpt



# ================================================ #
# ================= Congestion =================== #
# ================================================ #
# ---- Creates the congestion map without creating  global  route  segments 
route_global  -congestion_map_only true  -effort_level high
report_congestion > ../report_pl/congestion.rpt


# ================================================ #
# =================== Reports ==================== #
# ================================================ #
check_legality -verbose  > ../report_pl/legality.rpt
report_utilization > ../report_pl/utilization.rpt
check_pg_drc  > ../report_pl/drc_final.rpt
report_design > ../report_pl/design.rpt
report_cell   > ../report_pl/cells.rpt
report_qor    > ../report_pl/qor.rpt
report_timing > ../report_pl/timing.rpt


# ================================================ #
# =================== End_Step =================== #
# ================================================ #
write_def ../output_pl/counter.def
write_verilog -include {all} ../output_pl/counter.v
save_block -as counter_placement counter.dlib:counter_placement.design

