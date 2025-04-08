# ------------------------------------------------ #
# ----------------- Ring Approch ----------------- #
# ------------------------------------------------ #
# ================================================ #
# ================== Start_Step ================== #
# ================================================ #
sh rm ./counter.dlib/counter_floorpaln/design.ndm.lock

open_block /home/ICer/Desktop/Intake45_Elgammal/Counter/pnr/script/counter.dlib:counter_floorpaln.design

copy_block -from_block counter.dlib:counter_floorpaln.design -to_block counter_powerplan1

current_block counter_powerplan1.design

start_gui
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
create_port -port_type power  -direction in VDD

# --- Creation VDD and VSS nets for Network {PDN} 
create_net -power VDD 
create_net -ground VSS

connect_net -net VDD [get_ports VDD]
connect_net -net VSS [get_ports VSS]

# --- Connect pins of cells and submodules  to rails   
# hierarchical [include top module + sub modules]
connect_pg_net -net VDD [get_pins -hierarchical */VDD]
connect_pg_net -net VSS [get_pins -hierarchical */VSS]

# To auto connect for nets 
set_app_option -name plan.pgroute.auto_connect_pg_net -value true


# ================================================ #
# ================= Third Step =================== #
# ================================================ #
# // - Create patterns , Define strategie,Compile stra  

# ---- Create Rings Structure  {Direction , Width , Space }
create_pg_ring_pattern ring_pattern -horizontal_layer M9 -horizontal_width {3} -horizontal_spacing {1} \
									-vertical_layer M8   -vertical_width   {3} -vertical_spacing {1} 
# ---- Define Stratgie for design Rings VDD
set_pg_strategy core_ring_VDD -design_boundary -pattern {{pattern: ring_pattern}{nets: {VDD}}{offset: {0.5 0.5}}} -extension {{stop: design_boundary_and_generate_pin}}
compile_pg -strategies core_ring_VDD

# Stratgie for design Rings VSS
set_pg_strategy core_ring_VSS -design_boundary -pattern {{pattern: ring_pattern}{nets: {VSS}}{offset: {5 5}}} -extension {{stop: design_boundary}}
compile_pg -strategies core_ring_VSS

# ================================================ #
# ================= Fourth Step ================== #
# ================================================ #
# ---- Create rails {Layer , Width}
create_pg_std_cell_conn_pattern std_cell_rail -layers {M2} -rail_width 0.2

# ---- Define Strategie 
set_pg_strategy rails_M1 -core -pattern {{name: std_cell_rail} {nets: VDD VSS} }   
compile_pg -strategies rails_M1   


# ================================================ #
# ================= Fifth Step =================== #
# ================================================ #
# --- Offest : the center line of the first wire to the boundary
# --- pitch  : the pitch of the wires in this layer {centre to centre}.
# --- space  : the spacing between wires in this layer {edge to edge} . 
# --- trim   : the trim option for wires in this layer.
# ---- Create Straps/Strips  
# --- Define structure pattern
create_pg_mesh_pattern straps_VDD -layers {{{vertical_layer: M8}   {width: 2} {spacing: 2} {pitch: 10} {offset: 1} {trim:false}}\
										   {{horizontal_layer: M9} {width: 2} {spacing: 2} {pitch: 10} {offset: 1} {trim: false}}}

# --- Define Strategie 
set_pg_strategy mesh_VDD1 -pattern {{pattern: straps_VDD} {nets: {VDD}}} -core -extension {{stop: outermost_ring}}

# --- Compiling 
compile_pg -strategies mesh_VDD1


create_pg_mesh_pattern straps_VSS -layers {{{vertical_layer: M8}   {width: 2} {spacing: 2} {pitch: 10} {offset: 7.5} {trim:false}} \
										   {{horizontal_layer: M9} {width: 2} {spacing: 2} {pitch: 10} {offset: 7.5} {trim: false}}}
										   
set_pg_strategy mesh_VSS1 -pattern {{pattern: straps_VSS} {nets: {VSS}}} -core -extension {{stop: outermost_ring}}
compile_pg -strategies mesh_VSS1




# ================================================ #
# ================= Sixth Step =================== #
# ================================================ #
# ---- Mesh For ports 
create_pg_mesh_pattern M9_VDD -layers {{horizontal_layer: M9} {width: 0.5} {pitch: 30} {spacing: 1} {offset: 1.5}}
set_pg_strategy ring_pg_M9_VDD -design_boundary -pattern {{name: M9_VDD } {nets: VDD }} -extension {{stop: design_boundary_and_generate_pin}}
compile_pg -strategies ring_pg_M9_VDD

# ---- Port placed VSS
create_pg_mesh_pattern M9_VSS -layers {{horizontal_layer: M9} {width:  0.5} {pitch: 30} {spacing: 1} {offset: 17 }}
set_pg_strategy ring_pg_M9_VSS -design_boundary -pattern {{name: M9_VSS } {nets: VSS }} -extension {{stop: design_boundary_and_generate_pin}}
compile_pg -strategies ring_pg_M9_VSS

# ================================================ #
# ================ Seventh Step ================== #
# ================================================ #
# --- Verify routing of PG nets satisfies technology design rules
check_pg_drc
# --- Connectivity check for PG networks, standard cell PG pins, PG pads, and block terminals 
check_pg_connectivity 
# --- Check Missing Vias in the PG Network
check_pg_missing_vias 

# ================================================ #
# ================================================ #
# ================== Reports ===================== #
# ================================================ #

check_pg_drc  > ../report_pp/pg_drc.rpt
check_pg_connectivity > ../report_pp/pg_connectivity.rpt
analyze_power_plan -report_track_utilization_only > ../report_pp/track_utilization.rpt
report_utilization > ../report_pp/utilization.rpt
report_qor > ../report_pp/qor.rpt  ; #optional
report_timing > ../report_pp/timing.rpt ; #optional 

# ================================================ #
# =================== End_Step =================== #
# ================================================ #
write_def ../output_pp/counter.def
write_verilog -include {all} ../output_pp/counter.v
write_sdc -output ../output_pp/counter.sdc 
save_block -as counter_powerplan1 counter.dlib:counter_powerplan1.design
