
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity control_sim is end control_sim;

architecture behavioral of control_sim is

component controller port(
          clk : in std_logic;
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

end component;

--Signals
signal clk,rst,mem_opr,wb_opr,io_flag : std_logic;
signal opcode_in : std_logic_vector(6 downto 0);
signal alu_op, instr_form : std_logic_vector(2 downto 0);

begin
u0: controller port map(
    clk => clk,
    rst => rst,
    mem_opr => mem_opr, 
    wb_opr => wb_opr,
    io_flag => io_flag,
    instr_form => instr_form,
    opcode_in => opcode_in,
    alu_op => alu_op
);

process
begin

--reset behaviour
rst <= '0';
opcode_in <= "0000000"; --Send NOP
wait for 10 us;
rst <= '1';
wait for 5 us;
rst <= '0';

--testing Format A opcode behaviour
wait for 10 us; opcode_in <= "0000001"; --Send ADD
wait for 10 us; opcode_in <= "0000010"; --Send SUB
wait for 10 us; opcode_in <= "0000011"; --Send MUL
wait for 10 us; opcode_in <= "0000100"; --Send NAND 
wait for 10 us; opcode_in <= "0000101"; --Send SHL
wait for 10 us; opcode_in <= "0000110"; --Send SHR
wait for 10 us; opcode_in <= "0000111"; --Send TEST
wait for 10 us; opcode_in <= "0100000"; --Send OUT
wait for 10 us; opcode_in <= "0100001"; --Send IN
wait for 10 us; opcode_in <= "0000000"; --Back to NOP






end process;

end behavioral;
