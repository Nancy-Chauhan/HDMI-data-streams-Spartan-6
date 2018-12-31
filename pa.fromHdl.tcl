
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name HDMI-Color-Bar -dir "/home/nancy/Desktop/HDMI-Color-Bar/planAhead_run_1" -part xc6slx45csg324-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "/home/nancy/Desktop/xapp495/dvi_demo/ucf/vtc_demo.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {DRAM16XN.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {encode.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {convert_30to15_fifo.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {timing.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {synchro.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {serdes_n_to_1.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {hdclrbar.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {dvi_encoder.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {debnce.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {dcmspi.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {vtc_demo.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top vtc_demo $srcset
add_files [list {/home/nancy/Desktop/xapp495/dvi_demo/ucf/vtc_demo.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx45csg324-3
