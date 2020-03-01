----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2020 02:12:40 PM
-- Design Name: 
-- Module Name: if_id_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity if_id_sim is
--  Port ( );
end if_id_sim;

architecture Behavioral of if_id_sim is
component if_id port(
        instr_in     : in std_logic_vector (15 downto 0); --next instruction to latch
        PC_addr_in   : in std_logic_vector (15 downto 0);
        clk          : in std_logic;
        rst          : in std_logic;
        PC_addr_out  : out std_logic_vector (15 downto 0);
        op_code      : out std_logic_vector (6 downto 0);
        instr_format : out std_logic_vector (2 downto 0);
        reg1_addr    : out std_logic_vector (2 downto 0); --To Reg File
        reg2_addr    : out std_logic_vector (2 downto 0); --To Reg File
        op_pass      : out std_logic_vector (8 downto 0)  --Pass through operand (c1 OR ra OR disp1 OR disps OR imm)
        );
end component;

signal instr_in,PC_addr_in,PC_addr_out : std_logic_vector (15 downto 0);
signal opcode : std_logic_vector(6 downto 0);
signal op_pass : std_logic_vector (8 downto 0);
signal instr_format, reg1_addr, reg2_addr : std_logic_vector (2 downto 0);
signal clk,rst : std_logic;


begin
ifid0 : if_id port map(
    instr_in => instr_in,
    PC_addr_in => pc_addr_in,
    PC_addr_out => pc_addr_out,
    clk => clk,
    rst => rst,
    op_code => opcode,
    instr_format => instr_format,
    reg1_addr => reg1_addr,
    reg2_addr => reg2_addr,
    op_pass => op_pass    
);

clock : process
begin
clk <= '0'; wait for 10 us;
clk <= '1'; wait for 10 us;
end process;

if_id_sim : process
begin
rst <= '1';
wait until rising_edge(clk);
rst <= '0';
wait until rising_edge(clk);
instr_in <= X"4280"; -- IN r2
wait until rising_edge(clk);
instr_in <= X"02D1"; --ADD 
wait until rising_edge(clk);
instr_in <= X"0AC2"; --SHift
wait until rising_edge(clk);
wait;
end process;

end Behavioral;
