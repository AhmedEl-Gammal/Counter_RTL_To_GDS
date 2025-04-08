# ---- Budget Clock --- # 
create_clock -name clk -period 100 [get_ports clk] -waveform {0 50}
set_case_analysis 1 [get_ports Scan_En]

# ---- Model external ---- #
for {set i 0} {$i < 4 } {incr i} {
set_input_delay 10 Scan_In_{$i} -clock clk
}

set_output_delay -clock clk 15 [get_ports [all_outputs] ]
set_input_delay 15 Scan_En -clock clk

