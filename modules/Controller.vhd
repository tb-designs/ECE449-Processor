
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
    Port (clk : in std_logic;
          rst : in std_logic;
          --Inputs
          opcode_in  : in std_logic_vector (6 downto 0);
          --Format A Outputs
          alu_op     : out std_logic_vector (2 downto 0);
          instr_form : out std_logic_vector (2 downto 0);
          mem_opr    : out std_logic;
          wb_opr     : out std_logic;
          io_flag    : out std_logic
          );
end controller;

architecture Behavioral of controller is

    
  alias opcode is opcode_in(6 downto 0);

  --Decoding section
  begin
  --Format A Decoding
  case opcode is 
   when "0000001" =>
        --ADD
        instr_form <= "001"; --A1
        alu_op <= "001";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "0000010" =>
        --SUB
        instr_form <= "001"; --A1
        alu_op <= "010";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "0000011" =>
        --MUL
        instr_form <= "001"; --A1
        alu_op <= "011";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "0000100" =>
        --NAND
        instr_form <= "001"; --A1
        alu_op <= "100";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "0000101" =>
        --SHL
        instr_form <= "010"; --A2
        alu_op <= "101";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "0000110" =>
        --SHR
        instr_form <= "010"; --A2
        alu_op <= "110";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "0000111" =>
        --TEST
        instr_form <= "011"; --A3
        alu_op <= "111";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "00100000" =>
        --OUT
        instr_form <= "011"; --A3
        alu_op <= "000";
        io_flag <= '1';
        mem_opr <= '0';
        wb_opr  <= '0';
   when "00100001" =>
        --IN
        instr_form <= "011"; --A3
        alu_op <= "000";
        io_flag <= '1';
        mem_opr <= '0';
        wb_opr  <= '0';
   when others =>
        --NOP
        instr_form <= "000" --A0
        alu_op <= "000";
        io_flag <= '0';
        mem_opr <= '0';
        wb_opr  <= '0';
   end case;
 
  process(rst)
  begin
  --Reset behaviour
  if rst='1' then
    alu_op <= "000";
    instr_form <= "000";
    mem_opr <= '0';
    wb_opr  <= '0';
    io_flag <= '0';
  end if;
  end process

    --TODO



end Behavioral
