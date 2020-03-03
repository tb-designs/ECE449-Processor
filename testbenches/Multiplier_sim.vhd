library ieee;
use ieee.std_logic_1164.all;

entity tb_dadda_mult is
end tb_dadda_mult;

architecture behavioral of tb_dadda_mult is

	component dadda_mult
		port( A,B : in std_logic_vector(15 downto 0);
		      prod : out std_logic_vector(31 downto 0));
	end component;

	signal A,B : std_logic_vector(15 downto 0);
	signal prod : std_logic_vector(31 downto 0);

	signal clk : std_logic := '0';
	constant clk_period : time := 10 us;

begin -- behavioral
	mult : dadda_mult port map(
		A => A,
		B => B,
		prod => prod);

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	mult_process : process
	begin
	    wait until clk'event and clk = '1';
		A <= X"0004";
		B <= X"0005";
		wait until clk'event and clk = '1';
        A <= X"0016";
        B <= X"0008";
        wait until clk'event and clk = '1';
        A <= X"00A9";
        B <= X"003F";
		wait until clk'event and clk = '1';
		A <= X"FFFF";
		B <= X"0002";
		wait until clk'event and clk = '1';
		A <= X"2222";
		B <= X"C4C4";
		wait until clk'event and clk = '1';
        A <= X"1234";
        B <= X"ABCD";
        wait until clk'event and clk = '1';
        A <= X"0892";
        B <= X"0052";
        wait until clk'event and clk = '1';
        A <= X"D90E";
        B <= X"A311";
        wait until clk'event and clk = '1';
        A <= X"DDDD";
        B <= X"ADDD";
        wait until clk'event and clk = '1';
        A <= X"FFFF";
        B <= X"FFFF";
		wait;
	end process;
end;
