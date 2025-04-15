#100MHz
set_property PACKAGE_PIN R4 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name clk -period 10.000 [get_ports clk]

#KEY5
set_property PACKAGE_PIN J22 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

#SW8
set_property PACKAGE_PIN M1 [get_ports mem2uart]
set_property IOSTANDARD LVCMOS33 [get_ports mem2uart]


#LED1
set_property PACKAGE_PIN V2 [get_ports recv_done]
set_property IOSTANDARD LVCMOS33 [get_ports recv_done]

#LED8
set_property PACKAGE_PIN AB2 [get_ports send_done]
set_property IOSTANDARD LVCMOS33 [get_ports send_done]


#UART
set_property PACKAGE_PIN B20 [get_ports Rx_Serial]
set_property PACKAGE_PIN A20 [get_ports Tx_Serial]

set_property IOSTANDARD LVCMOS33 [get_ports Rx_Serial]
set_property IOSTANDARD LVCMOS33 [get_ports Tx_Serial]
