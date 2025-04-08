# ---- Budget Clock --- # 
create_clock -name clk -period 100 [get_ports clk] -waveform {0 50}
set_case_analysis 1 [get_ports Scan_En]

# ---- Model external ---- #
set_input_delay 25 Scan_In -clock clk
set_input_delay 15 Scan_En -clock clk

# Output delays
set_output_delay -clock clk 15 [get_ports [all_outputs] ]

