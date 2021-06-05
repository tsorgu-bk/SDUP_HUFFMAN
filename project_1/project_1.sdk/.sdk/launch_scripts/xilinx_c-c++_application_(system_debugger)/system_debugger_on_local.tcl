connect -url tcp:127.0.0.1:3121
source F:/MAGISTERKA_S1/SDUP/PROJEKT_HUFFMAN_V2/project_1/project_1.sdk/huffman_coder_acc_wrapper_hw_platform_0/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Zed 210248531164"} -index 0
loadhw -hw F:/MAGISTERKA_S1/SDUP/PROJEKT_HUFFMAN_V2/project_1/project_1.sdk/huffman_coder_acc_wrapper_hw_platform_0/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Zed 210248531164"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248531164"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248531164"} -index 0
dow F:/MAGISTERKA_S1/SDUP/PROJEKT_HUFFMAN_V2/project_1/project_1.sdk/huffman_demo/Debug/huffman_demo.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zed 210248531164"} -index 0
con
