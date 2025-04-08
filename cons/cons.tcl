# ---- Budget Clock --- # 
create_clock -name clk -period 2 -waveform {0 1} [get_ports clk]
set_clock_uncertainty 0.60 [get_clocks]


# ---- Model external ---- #
set_output_delay -max 0.50 -clock [get_clocks clk] [all_outputs]


#Maximum Area
set_max_area    150


# ---- Exceptions --- #
set_false_path -hold -from [remove_from_collection [all_inputs] [get_ports clk]]
set_false_path -hold -to [all_outputs]


