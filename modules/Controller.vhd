----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:48 02/21/2017 
-- Design Name: 
-- Module Name:    controlUnit_file - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
    Port (	clk : IN STD_LOGIC;
            rst : in std_logic;
        --Inputs
        instr : in std_logic_vector (15 downto 0);
        --Format A Outputs
        ra_addr : out std_logic_vector (2 downto 0);
        rb_addr : out std_logic_vector (2 downto 0);
        rc_addr : out std_logic_vector (2 downto 0);
        alu_op  : out std_logic_vector (2 downto 0);
        mem_opr : out std_logic;
        wb_opr  : out std_logic;
        io_flag : out std_logic --used to put IN in ra or ra in OUT
        );
end controller;

architecture Behavioral of controller is

  --Create aliases for easier coding
  alias opcode is instr(15 downto 9); --All
  alias ra_op  is instr (8 downto 6); --A1, A2, A3
  alias rb_op  is instr (5 downto 3); --A1
  alias rc_op  is instr (2 downto 0); --A1
  alias c1_op  is instr (3 downto 0); --A2

  --Decoding section
  begin
  --Format A Decoding
  alu_op <=
	  "001" when opcode = "0000001" else	-- ADD
	  "010" when opcode = "0000010" else	-- SUB
	  "011" when opcode = "0000011" else	-- MUL
	  "100" when opcode = "0000100" else	-- NAND
	  "101" when opcode = "0000101" else	-- SHL
	  "110" when opcode = "0000110" else	-- SHR
	  "111" when opcode = "0000111" else	-- TEST
	  "000";										          -- NOP

  --Look at flag AND op-code to determine input vs output
  io_flag <=
    "1" when opcode = "00100000" else --OUT
    "1" when opcode = "00100001" else --IN
    "0";

   
  process(clk,rst,instr)
  begin
    case opcode is
      --ADD
      when "0000001" =>







end Behavioral