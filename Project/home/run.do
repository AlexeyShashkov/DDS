
vlog -vopt -sv +incdir+E:/Dropbox/Work/DDS/Project/home/src {E:\Dropbox\Work\DDS\Project\home\src\config.sv}
vlog -vopt -sv +incdir+E:/Dropbox/Work/DDS/Project/home/src {E:\Dropbox\Work\DDS\Project\home\src\dds_top.sv}
vlog -vopt -sv +incdir+E:/Dropbox/Work/DDS/Project/home/src E:/Dropbox/Work/DDS/Project/home/src/dds_top_tb.sv

vsim -debugDB -gui -voptargs=+acc work.dds_top_tb

run -all
