onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /dds_top_tb/dut/PH_NUM_ACC_WIDTH
add wave -noupdate -radix unsigned /dds_top_tb/dut/PH_NUM_DELTA
add wave -noupdate -radix unsigned /dds_top_tb/dut/ROM_WIDTH
add wave -noupdate -radix unsigned /dds_top_tb/dut/ROM_ADDR_WIDTH
add wave -noupdate -radix unsigned /dds_top_tb/dut/K
add wave -noupdate -radix unsigned /dds_top_tb/dut/K_WIDTH
add wave -noupdate -radix unsigned /dds_top_tb/dut/PHASE_ERROR_WIDTH
add wave -noupdate /dds_top_tb/dut/clk
add wave -noupdate /dds_top_tb/dut/ce
add wave -noupdate /dds_top_tb/dut/rst
add wave -noupdate -radix decimal /dds_top_tb/dut/minus_sin
add wave -noupdate /dds_top_tb/dut/cos
add wave -noupdate /dds_top_tb/dut/phase_num_acc
add wave -noupdate /dds_top_tb/dut/addr
add wave -noupdate /dds_top_tb/dut/rom_minus_sin_value
add wave -noupdate /dds_top_tb/dut/rom_cos_value
add wave -noupdate /dds_top_tb/dut/acc_num_error_div_16
add wave -noupdate /dds_top_tb/dut/w_phase_error
add wave -noupdate /dds_top_tb/dut/r_phase_error
add wave -noupdate -color Cyan -itemcolor Cyan /dds_top_tb/dut/phase_error_full
add wave -noupdate /dds_top_tb/dut/rounded_phase_error
add wave -noupdate -color Cyan -itemcolor Cyan /dds_top_tb/dut/s_rounded_phase_error
add wave -noupdate /dds_top_tb/dut/minus_sin_error
add wave -noupdate /dds_top_tb/dut/d_rom_minus_sin_value
add wave -noupdate -color Gold -itemcolor Gold /dds_top_tb/dut/corr_d_rom_minus_sin_value
add wave -noupdate /dds_top_tb/dut/corr_minus_sin_error
add wave -noupdate -color Cyan -itemcolor Cyan -subitemconfig {{/dds_top_tb/dut/corr_minus_sin[35]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[34]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[33]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[32]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[31]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[30]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[29]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[28]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[27]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[26]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[25]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[24]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[23]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[22]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[21]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[20]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[19]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[18]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[17]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[16]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[15]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[14]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[13]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[12]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[11]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[10]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[9]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[8]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[7]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[6]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[5]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[4]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[3]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[2]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[1]} {-color Cyan -itemcolor Cyan} {/dds_top_tb/dut/corr_minus_sin[0]} {-color Cyan -itemcolor Cyan}} /dds_top_tb/dut/corr_minus_sin
add wave -noupdate -color Gold -itemcolor Gold /dds_top_tb/dut/s_sq_rounded_phase_error_div_2
add wave -noupdate -color Cyan -itemcolor Cyan /dds_top_tb/dut/d_corr_minus_sin
add wave -noupdate -color Violet -itemcolor Violet /dds_top_tb/dut/wide_d_corr_minus_sin
add wave -noupdate -color Gold -itemcolor Gold /dds_top_tb/dut/minus_sin_error_2nd_term_div_2
add wave -noupdate -color Violet -itemcolor Violet /dds_top_tb/dut/minus_sin_error_2nd_term
add wave -noupdate -color Cyan -itemcolor Cyan /dds_top_tb/dut/corr2_minus_sin
add wave -noupdate /dds_top_tb/dut/sel_minus_sin
add wave -noupdate /dds_top_tb/dut/r_minus_sin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {113973 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
configure wave -valuecolwidth 140
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {54318 ps} {233151 ps}
