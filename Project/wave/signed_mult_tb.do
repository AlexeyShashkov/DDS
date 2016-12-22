onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /signed_mult_tb/dut/N
add wave -noupdate /signed_mult_tb/dut/clk
add wave -noupdate /signed_mult_tb/dut/ce
add wave -noupdate /signed_mult_tb/dut/rst
add wave -noupdate -radix decimal /signed_mult_tb/dut/a
add wave -noupdate -radix decimal /signed_mult_tb/dut/b
add wave -noupdate -radix decimal /signed_mult_tb/dut/a_mult_b
add wave -noupdate -radix decimal /signed_mult_tb/dut/w_a_mult_b
add wave -noupdate -radix decimal /signed_mult_tb/dut/r_a_mult_b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {393167 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {420 ns}
