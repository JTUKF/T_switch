iverilog -g2005-sv -o runtime .\tb_top.sv ..\rtl\tswitch.v
vvp -n runtime -lxt2
gtkwave waveform.vcd&