# ================================================ #
# ================== Start_Step ================== #
# ================================================ #
open_block /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/script/counter.dlib:counter_setup.design

copy_block -from_block counter.dlib:counter_setup.design -to_block counter_floorpaln

current_block counter_floorpaln.design

# ================================================ #
# ================= First Step =================== #
# ================================================ #

# -- Metal layers Directions 
set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal 
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction vertical

# -- Metal Layers Offest 
set_attribute [get_layers {M1}] track_offset 0.03 
set_attribute [get_layers {M2}] track_offset 0.04

# -- For power Layers 
set_ignored_layers -max_routing_layer M8 


# -- site def attribute 
set Name_unit [get_site_defs]
set_attribute [get_site_defs $Name_unit] is_default true
set_attribute [get_site_defs  $Name_unit] symmetry {Y}



# ================================================ #
# ================== Second Step ================= #
# ================================================ #
# -- Initialize_Floor_planning 
initialize_floorplan -core_utilization .6 -shape R -orientation N -core_offset {3}  -flip_first_row false -side_ratio {10 10}

# ================================================ #
# ================= Third Step =================== #
# ================================================ #
# -- Muliple Power Domains (if UPF File existing) 
#load_upf file.upf
#commit_upf 

# ================================================ #
# ================= Fourth Step ================== #
# ================================================ #
set_block_pin_constraints -self -allowed_layers {M3} -pin_spacing 1 -sides {1 2} -corner_keepout_num_tracks 1
place_pins -ports [get_ports -filter {direction == in }] 

set_block_pin_constraints -self -allowed_layers {M4}  -pin_spacing 1 -sides {3 4} -corner_keepout_num_tracks 1
place_pins -ports [get_ports -filter {direction == out }] 


# ================================================ #
# ================= Fifth Step =================== #
# ================================================ #
# --- Placement Blockage  

create_placement_blockage -boundary {{3 3} {5  5}} -name B1 -type hard

create_placement_blockage -boundary {{5  3} {7 5}} -name B2 -type partial -blocked_percentage 40 

create_placement_blockage -boundary {{7 3} {9 5}}  -name B3 -type soft

# ================================================ #
# ================ Seventh Step ================== #
# ================================================ #
# -- in this library don't exist tapcells sothat insert Dcaps only for get it 
#get_lib_cell saed90nm_max/DC*
create_tap_cells -lib_cell saed90nm_max/DCAP  -pattern stagger -distance 15
get_cells tap*
remove_cell tap*

create_tap_cells -lib_cell saed90nm_max/DCAP  -pattern every_row -distance 10
get_cells tap*
remove_cell tap*

create_tap_cells -lib_cell saed90nm_max/DCAP  -pattern  every_other_row -distance 10
get_cells tap*
remove_cell tap*

# ================================================ #
# ================== Reports ===================== #
# ================================================ #
report_ports [all_inputs] > ../report_fp/input_port.rpt
report_ports [all_outputs] > ../report_fp/output_port.rpt
report_cell  > ../report_fp/cells.rpt
report_nets  > ../report_fp/nets.rpt
report_qor   > ../report_fp/qor.rpt
report_timing > ../report_fp/timing.rpt 
report_timing -delay max -max_paths 2 > ../report_fp/two_critical_path_setup.rpt
report_utilization > ../report_fp/utilization.rpt
get_placement_blockages > ../report_fp/Blockage.rpt
# ================================================ #
# =================== End_Step =================== #
# ================================================ #
write_def ../output_fp/counter.def
write_verilog -include {all} ../output_fp/counter.v
write_sdc -output ../output_fp/counter.sdc

save_block ; # NDM database  



