//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.9.03  Education (64-bit)
//Created Time: 2025-01-04 00:41:14
create_clock -name clc -period 37.037 -waveform {0 18.518} [get_ports {clk}]
set_false_path -from [get_regs {my_synchronizer_instance/pipeline_1_s0 my_synchronizer_instance/pipeline_0_s0}] 
set_false_path -from [get_ports {rst_n}] 
