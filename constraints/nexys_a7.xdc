## ============================================================
##  Xilinx Vivado Constraints File
##  Target : Nexys A7-100T (Artix-7)
##  Project: MMU Design using Verilog HDL
##
##  SWITCHES  SW[7:0]  → virtual_addr[7:0]   (lower 8 bits)
##  SW15       →  access_type  (0=READ, 1=WRITE)
##  SW14       →  enable
##
##  LEDs  LD[7:0]  → physical_addr[7:0]   (lower 8 bits)
##  LD8        →  trans_valid
##  LD9        →  page_fault
##  LD10       →  prot_fault
## ============================================================

## --- Clock (100 MHz on-board oscillator) ---
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## --- Reset (BTN0 – active-low wired to rst_n) ---
set_property PACKAGE_PIN C12 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## --- Switches: virtual address [7:0] ---
set_property PACKAGE_PIN J15 [get_ports {virtual_addr[0]}]
set_property PACKAGE_PIN L16 [get_ports {virtual_addr[1]}]
set_property PACKAGE_PIN M13 [get_ports {virtual_addr[2]}]
set_property PACKAGE_PIN R15 [get_ports {virtual_addr[3]}]
set_property PACKAGE_PIN R17 [get_ports {virtual_addr[4]}]
set_property PACKAGE_PIN T18 [get_ports {virtual_addr[5]}]
set_property PACKAGE_PIN U18 [get_ports {virtual_addr[6]}]
set_property PACKAGE_PIN R13 [get_ports {virtual_addr[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {virtual_addr[*]}]

## --- Upper address bits tied to 0 for 8-bit switch input ---
## (In real FPGA: use top 8 switches for VA[15:8])

## --- access_type (SW15) ---
set_property PACKAGE_PIN V10 [get_ports access_type]
set_property IOSTANDARD LVCMOS33 [get_ports access_type]

## --- enable (SW14) ---
set_property PACKAGE_PIN U11 [get_ports enable]
set_property IOSTANDARD LVCMOS33 [get_ports enable]

## --- LEDs: physical address [7:0] ---
set_property PACKAGE_PIN H17 [get_ports {physical_addr[0]}]
set_property PACKAGE_PIN K15 [get_ports {physical_addr[1]}]
set_property PACKAGE_PIN J13 [get_ports {physical_addr[2]}]
set_property PACKAGE_PIN N14 [get_ports {physical_addr[3]}]
set_property PACKAGE_PIN R18 [get_ports {physical_addr[4]}]
set_property PACKAGE_PIN V17 [get_ports {physical_addr[5]}]
set_property PACKAGE_PIN U17 [get_ports {physical_addr[6]}]
set_property PACKAGE_PIN U16 [get_ports {physical_addr[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {physical_addr[*]}]

## --- Status LEDs ---
set_property PACKAGE_PIN V16 [get_ports trans_valid]
set_property PACKAGE_PIN T15 [get_ports page_fault]
set_property PACKAGE_PIN U14 [get_ports prot_fault]
set_property IOSTANDARD LVCMOS33 [get_ports trans_valid]
set_property IOSTANDARD LVCMOS33 [get_ports page_fault]
set_property IOSTANDARD LVCMOS33 [get_ports prot_fault]
