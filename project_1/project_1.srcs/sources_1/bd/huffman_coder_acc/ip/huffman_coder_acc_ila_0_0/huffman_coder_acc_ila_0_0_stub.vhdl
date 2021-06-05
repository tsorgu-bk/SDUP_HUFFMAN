-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Tue Jun  1 19:01:03 2021
-- Host        : DESKTOP-J4MTDV6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               f:/MAGISTERKA_S1/SDUP/PROJEKT_HUFFMAN_V2/project_1/project_1.srcs/sources_1/bd/huffman_coder_acc/ip/huffman_coder_acc_ila_0_0/huffman_coder_acc_ila_0_0_stub.vhdl
-- Design      : huffman_coder_acc_ila_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity huffman_coder_acc_ila_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe1 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe5 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe7 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe8 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe9 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe10 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe11 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe12 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe13 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    probe14 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe15 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe16 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe17 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    probe18 : in STD_LOGIC_VECTOR ( 2 downto 0 )
  );

end huffman_coder_acc_ila_0_0;

architecture stub of huffman_coder_acc_ila_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[0:0],probe1[3:0],probe2[1:0],probe3[0:0],probe4[0:0],probe5[3:0],probe6[0:0],probe7[0:0],probe8[0:0],probe9[0:0],probe10[31:0],probe11[0:0],probe12[0:0],probe13[1:0],probe14[31:0],probe15[3:0],probe16[0:0],probe17[2:0],probe18[2:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2018.3";
begin
end;
