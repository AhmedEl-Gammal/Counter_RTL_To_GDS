# ----------------- Second Approch ----------------- #

# ================================================ #
# ================== Start_Step ================== #
# ================================================ #
sh rm ./counter.dlib/counter_floorpaln/design.ndm.lock

open_block /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/script/counter.dlib:counter_floorpaln.design

copy_block -from_block counter.dlib:counter_floorpaln.design -to_block counter_powerplan2

current_block counter_powerplan2.design


# ================================================ #
# ================= First Step =================== #
# ================================================ #
# --- disable ignored layers used to  used it through Power planning 
report_ignored_layers
remove_ignored_layers -all -max_routing_layer -min_routing_layer
report_ignored_layers


# ================================================ #
# ================= Second Step ================== #
# ================================================ #
# --- Creation Power and GND Ports 
create_port -port_type ground -direction in VSS

create_port -port_type power -direction in VDD

# --- Creation VDD and VSS nets for Network {PDN} 
create_net -power VDD

create_net -ground VSS

# --- Connect ports and pins to nets 

connect_pg_net -net VDD [get_port VDD]

connect_pg_net -net VSS [get_port VSS]

connect_pg_net -net VDD [get_pins -hierarchical */VDD]

connect_pg_net -net VSS [get_pins -hierarchical */VSS]


# ================================================ #
# ================= Third Step =================== #
# ================================================ #
# --- Create Rails 

create_pg_std_cell_conn_pattern rail_pattern -layers M1 -rail_width 0.15

set_pg_strategy M1_rails -core -pattern {{name: rail_pattern} nets: VDD VSS}

compile_pg -strategies M1_rails

# ================================================ #
# ================= Fourth Step ================== #
# ================================================ #

# ---- Multiple of straps to avoid IR drop  high routing resources
create_pg_mesh_pattern M4toM7 -layers {{{vertical_layer: M4} {spacing: minimum} {pitch: 2.2} {width: 0.22} {offset: 0.6}}\
										{{vertical_layer: M6} {spacing: minimum} {pitch: 2.4} {width:0.24} {offset: 0.6}} \
										{{horizontal_layer: M5} {spacing: minimum} {pitch: 2.6} {width:0.26} {offset: 0.6}} \ 
										{{horizontal_layer: M7} {spacing: minimum} {pitch: 3} {width:0.5} {offset: 0.6}}}

set_pg_strategy pg_mesh -core -pattern {{name: M4toM7 } {nets: VDD VSS }} -extension {{stop: outermost_ring} {layers: M4}}

compile_pg -strategies pg_mesh


# ================================================ #
# ================= Fifth Step =================== #
# ================================================ #
# --- Work with straps as rings burt not prefred 
create_pg_mesh_pattern M9 -layers {{horizontal_layer: M9} {width: 1.0} {pitch: 7} {spacing: minimum} {offset: 0.9}}
set_pg_strategy ring_pg_M9 -design_boundary -pattern {{name: M9 } {nets: VDD VSS }} -extension {{stop: design_boundary_and_generate_pin}}
compile_pg -strategies ring_pg_M9

# ---- 
create_pg_mesh_pattern M8 -layers {{vertical_layer: M8 } {width: 1.0} {pitch: 7} {spacing: minimum} {offset: 1.4}}
set_pg_strategy ring_pg_M8 -design_boundary -pattern {{name: M8 } {nets: VDD VSS }} -extension {{stop: 1} {layers: M9}}
compile_pg -strategies ring_pg_M8


# ================================================ #
# ================= Sixth Step =================== #
# ================================================ #
check_pg_drc
check_pg_connectivity 
check_pg_missing_vias

# ================================================ #
# ================================================ #
# ================== Reports ===================== #
# ================================================ #

check_pg_drc  > ../report_pp/pg_drc2.rpt
check_pg_connectivity >../report_pp/pg_connectivity2.rpt
analyze_power_plan -report_track_utilization_only > ../report_pp/track_utilization2.rpt
report_utilization >../report_pp/utilization2.rpt
report_qor > ../report_pp/qor2.rpt  ; #optional
report_timing > ../report_pp/timing2.rpt ; #optional 

# ================================================ #
# =================== End_Step =================== #
# ================================================ #
write_def ../output_pp/counter2.def
write_verilog -include {all} ../output_pp/counter2.v
write_sdc -output ../output_pp/counter.sdc 
save_block -as counter_powerplan2 counter.dlib:counter_powerplan2.design
