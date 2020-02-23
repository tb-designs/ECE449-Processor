library ieee;
use ieee.std_logic_1164.all;

entity tb_bshift is
end tb_bshift;

architecture behavioral of tb_bshift is
	component bshift is
		port(left : in std_logic; -- 1 for left shift, 0 for right
	     	     shift : in std_logic_vector(3 downto 0);
	     	     input : in std_logic_vector(15 downto 0);
	    	     output : out std_logic_vector(15 downto 0));
end component;

	signal left : std_logic;
	signal shift : std_logic_vector(3 downto 0);
	signal input,output : std_logic_vector(15 downto 0);

	signal clk : std_logic := '0';
	constant clk_period : time := 10 us;

begin -- behavioral
	shifter : bshift port map(
		left => left,
		shift => shift,
		input => input,
		output => output);

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	shift_process : process
	begin
		left <= '1';
		shift <= X"2";
		input <= X"FFFF";
		wait until clk'event and clk = '1';
		left <= '0';
		shift <= X"4";
		input <= X"88F0";
		wait until clk'event and clk = '1';
		left <= '1';
		shift <= X"8";
		input <= X"4A40";	
		wait until clk'event and clk = '1';
		left <= '0';
		shift <= X"F";
		input <= X"FFFF";
		wait;
	end process;
end;

