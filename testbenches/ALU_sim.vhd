library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity test_alu is end test_alu;

architecture behavioral of test_alu is

component ALU port(rst : in std_logic; 
in1, in2: in std_logic_vector(15 downto 0);
alu_mode: in std_logic_vector(2 downto 0);
result: out std_logic_vector(15 downto 0); 
n_flag, z_flag, v_flag : out std_logic);
end component;

signal rst, n_flag, z_flag, v_flag : std_logic;
signal alu_mode: std_logic_vector(2 downto 0); 
signal in1, in2, result: std_logic_vector(15 downto 0); 


begin
u0 : ALU port map(
    rst => rst,
    in1 => in1,
    in2 => in2,
    alu_mode => alu_mode,
    result => result,
    n_flag => n_flag,
    z_flag => z_flag,
    v_flag => v_flag
);

process begin
rst <= '0';
alu_mode <= "000"; 
wait for 10 us;
rst <= '1';
wait for 10 us;
rst <= '0';

wait for 10 us; in1 <= X"0002"; in2 <= X"0003"; alu_mode <= "001";
wait for 10 us; in1 <= X"0008"; in2 <= X"0005"; alu_mode <= "010";
wait for 10 us; in1 <= X"0005"; in2 <= X"0006"; alu_mode <= "011";
wait for 10 us; in1 <= X"f000"; in2 <= X"f000"; alu_mode <= "011"; --get all zeros
wait for 10 us; in1 <= X"1111"; in2 <= X"1101"; alu_mode <= "100";
wait for 10 us; in1 <= X"000f"; in2 <= X"0002"; alu_mode <= "101";
wait for 10 us; in1 <= X"00f0"; in2 <= X"0004"; alu_mode <= "110";
wait for 10 us; in1 <= X"0000"; in2 <= X"0007"; alu_mode <= "111"; --z_flag==1
wait for 10us; in1 <= X"8002" ; in2 <= X"0004"; alu_mode <= "111"; --n_flag==1
wait for 10us; alu_mode <= "000";

end process;
end behavioral;



