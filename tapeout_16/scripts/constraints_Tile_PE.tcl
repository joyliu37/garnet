create_clock -name clk -period 2.3 [get_ports clk]
#create_generated_clock -name clk_out -source [get_ports clk] -multiply_by 1 [get_ports clk_out]
set_input_delay -max 0 -clock clk [all_inputs]
set_output_delay -max 0 -clock clk [all_outputs]
set_input_delay -min 0 -clock clk [all_inputs]
set_output_delay -min 0 -clock clk [all_outputs]

set_input_transition 0.05 [all_inputs]

set_false_path -from [get_ports tile_id*]  -to [all_outputs]
set_false_path -from [get_pins -hier *inst_*] -to [all_outputs]

set_attribute ungroup_ok false [get_cells *]
#set_attribute ungroup_ok true [get_cells -hier PE*]

# set loads on pass through signals
set_load 0.02 [get_ports config_out*]
set_load 0.02 [get_ports stall_out*]
set_load 0.02 [get_ports reset_out*]
set_load 0.02 [get_ports clk_out*]