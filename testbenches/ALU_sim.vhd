 
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity test_alu is end test_alu;

architecture behavioural of test_alu is

component ALU port(rst : in std_logic; 
in_1, in_2: in std_logic_vector(15 downto 0);
alu_mode: in std_logic_vector(2 downto 0);
result: out std_logic_vector(15 downto 0); 
n_flag, z_flag: out std_logic);
end component;

signal rst, clk,n_flag, z_flag: std_logic; 
signal alu_mode: std_logic_vector(2 downto 0); 
signal in_1, in_2, result: std_logic_vector(15 downto 0); 


begin
u0:ALU port map(rst, in_1, in_2, alu_mode, result, n_flag, z_flag);
process begin
clk <= '0'; wait for 10 us;
clk<='1'; wait for 10 us; 
end process;

process  begin
rst <= '0';
alu_mode <= "000"; 
wait until (clk='0' and clk'event); wait until (clk='1' and clk'event);
rst <= '1';
wait until (clk='1' and clk'event);
rst <= '0';

wait until (clk='1' and clk'event); in_1 <= X"0002"; in_2 <= X"0003"; alu_mode <= "001";
wait until (clk='1' and clk'event); in_1 <= X"0008"; in_2 <= X"0005"; alu_mode <= "010";
wait until (clk='1' and clk'event); in_1 <= X"0005"; in_2 <= X"0006"; alu_mode <= "011";
wait until (clk='1' and clk'event); in_1 <= X"f000"; in_2 <= X"f000"; alu_mode <= "011"; --get all zeros
wait until (clk='1' and clk'event); in_1 <= X"1111"; in_2 <= X"1101"; alu_mode <= "100";
wait until (clk='1' and clk'event); in_1 <= X"000f"; in_2 <= X"0002"; alu_mode <= "101";
wait until (clk='1' and clk'event); in_1 <= X"00f0"; in_2 <= X"0004"; alu_mode <= "110";
wait until (clk='1' and clk'event); in_1 <= X"0000"; in_2 <= X"0007"; alu_mode <= "111"; --z_flag==1
--wait until (clk='1' and clk'event); in_1 <= signed(-3); in_2 <= X"0004"; alu_mode <= "111";
wait until (clk='1' and clk'event); alu_mode <= "000";wait;

end process;
end behavioural;



