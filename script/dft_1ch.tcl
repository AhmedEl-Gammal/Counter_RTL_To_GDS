# ----- Setup_file ----- # 

# --- Define Search path & Libraries ---- # 
set_app_var search_path "/home/ICer/Downloads/Lib/synopsys/models"


#set_app_var target_library "saed90nm_max_hth_lvt.db"
set_app_var target_library "saed90nm_max.db" ; # Good PNR Flow 
set_app_var link_library "* $target_library"

#. If you want to replace the entire design module that consists of leaf cells, you 
# should use the remove_design command to remove the module and then read the Verilog netlist description of that module into memor
remove_design -all


# ---- Read_files ---- #
# --Netlist 
#read_verilog ../../syn/output/counter.v
read_ddc ../../syn/output/counter.ddc
# --Constraits 
read_sdc ../../syn/output/counter.sdc

# --- Return Top module --- #  
current_design 

# ---- Linking ---- # 
link

# ----  Test Mode ---- #  
# another type lssd ,clocked_scan
set_scan_configuration -style multiplexed_flip_flop
# ---- Checks Constraints ---- # 
check_design

# ---- Modify Design ---- #
create_port -direction in Scan_In
create_port -direction out Scan_Out
create_port -direction in Scan_En

# ---- Test Prtocol  ---- #
set_dft_signal -view spec  -type ScanDataIn  -port Scan_In
set_dft_signal -view spec  -type ScanDataOut -port Scan_Out
set_dft_signal -view spec  -type ScanEnable  -port Scan_En -active 1 
set_dft_signal -view exist -type ScanClock   -port clk     -timing {45 55} 
set_dft_signal -view exist -type Reset       -port rst_n   -active 0

# ---- Scan Config ---- #	
# -- N.of scan chains 
set_scan_configuration -chain_count 1

# ---- Create Test Protocol ---- #
create_test_protocol


# ---- Constraints ---- #	 
source ../cons/dft_cons.tcl  

# ---- Linking ---- # 
link

# To prevent uniquification of your design, enter the command
set_dft_insertion_configuration -preserve_design_name true  -synthesis_optimization none

# ---- Optimization ---- #
# compile_ultra -scan 
compile -scan -incremental 

# ---- Checks Constraints ---- # 
check_design
# ---- Drc_checking ---- # 
dft_drc
# ---- Preview ---- #  
preview_dft -show all
# ---- Scan_stitching ---- # 
insert_dft
# ---- Drc_checking ---- # 
dft_drc 
dft_drc  > ../report_dft/drc_reprot_ch1.rpt

# ----- Reports ---- # 

dft_drc -coverage_estimate > ../report_dft/rpt_dft_1ch.drc_coverage
report_area > ../report_dft/dft_area_1ch.rpt
report_timing > ../report_dft/dft_timing_1ch.rpt
report_qor > ../report_dft/dft_qor_1ch.rpt
report_constraint -all_violators  > ../report_dft/dft_Violations_1ch.rpt
report_scan_path -chain all > ../report_dft/scan_chains_1ch.rpt

# ------- Report All Signals 
report_dft_signal -view exist > ../report_dft/dft_exist_sig_1ch.rpt
report_dft_signal -view spec > ../report_dft/dft_spec_sig_1ch.rpt

# ---- Netlist output (.v and .ddc  ) ---- #
write -format ddc  -hierarchy -output ../output/counter_dft_compiled_1ch.ddc
write -format verilog  -hierarchy -output ../output/counter_dft_compiled_1ch.v
write_test_model -output ../output/counter_1ch.ctlddc
write_scan_def  -output ../output/counter_scan.def
# ---- SPF_File (STIL Protcol File) ---- # 
write_test_protocol -out ../output/counter_dft_1ch.spf

# ---- SDF_File (Standard Delay Format) ---- # 
write_sdf  ../output/counter_dft_1ch.sdf


start_gui


