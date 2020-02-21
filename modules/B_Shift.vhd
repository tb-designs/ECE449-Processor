library ieee;
use ieee.std_logic_1164.all;

entity bshift is -- barrel shifter, 16-bit
	port(left : in std_logic; -- 1 for left shift, 0 for right
	     shift : in std_logic_vector(3 downto 0); -- shift count, max 15
	     input : in std_logic_vector(15 downto 0);
	     output : out std_logic_vector(15 downto 0));
end entity bshift;

architecture behavior of bshift is

begin -- behavior
process(left,shift)
variable x,y,z : std_logic_vector(15 downto 0);
variable c0,c1,c2,c3 : std_logic_vector(1 downto 0); -- ctrl variables for each stage
begin --process
	c0 := shift(0) & left;
	c1 := shift(1) & left;
	c2 := shift(2) & left;
	c3 := shift(3) & left;

	case c3 is
		when "00"|"01" => x := input;
		when "10" => x := "00000000" & input(15 downto 8); -- shift 8b right
		when "11" => x := input(7 downto 0) & "00000000"; -- shift 8b left
		when others => null;
	end case;
	case c2 is
		when "00"|"01" => y := x;
		when "10" => y := "0000" & x(15 downto 4); -- shift 4b right
		when "11" => y := x(11 downto 0) & "0000"; -- shift 4b left
		when others => null;
	end case;
	case c1 is
		when "00"|"01" => z := y;
		when "10" => z := "00" & y(15 downto 2); -- shift 2b right
		when "11" => z := y(13 downto 0) & "00"; -- shift 2b left
		when others => null;
	end case;
	case c0 is
		when "00"|"01" => output <= z;
		when "10" => output <= '0' & z(14 downto 0); -- shift 1b right
		when "11" => output <= z(14 downto 0) & '0'; -- shift 1b left
		when others => null;
	end case;
end process;
end behavior;
