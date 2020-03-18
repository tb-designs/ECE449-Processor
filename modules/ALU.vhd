----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/05/2020 04:14:55 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    port (
        in1 : in std_logic_vector (15 downto 0);
        in2 : in std_logic_vector (15 downto 0);
        alu_mode : in std_logic_vector (2 downto 0);
        rst : in std_logic;
        result : out std_logic_vector (15 downto 0);
        z_flag : out std_logic;
        n_flag : out std_logic;
        v_flag : out std_logic -- result overflow output
    );
end ALU;

architecture behavioral of ALU is

-- Functions
function slice_slv(x : signed; s, e : integer)
return std_logic_vector is
begin
	return std_logic_vector(x(s downto e));
end slice_slv;

-- Components
component dadda_mult is
	Port ( A : in std_logic_vector(15 downto 0);
	       B : in std_logic_vector(15 downto 0);
	       prod : out std_logic_vector(31 downto 0));
end component;

component bshift is
	Port ( left : in std_logic;
	       shift : in std_logic_vector(3 downto 0);
	       input : in std_logic_vector(15 downto 0);
	       output : out std_logic_vector(15 downto 0));
end component;

--Signals
signal mult_buf : std_logic_vector(31 downto 0);
signal out_buf : std_logic_vector(15 downto 0);
signal shift_dir : std_logic;

begin
	result <= (others => '0') when (rst = '1') else
		  -- ADD
		  std_logic_vector(signed(in1) + signed(in2)) when (alu_mode = "001") else
		  -- SUB
		  std_logic_vector(signed(in1) - signed(in2)) when (alu_mode = "010") else
		  -- MUL
		  mult_buf(15 downto 0) when (alu_mode = "011") else
		  -- NAND
		  in1 nand in2 when (alu_mode = "100") else
		  -- SHL and SHR
		  out_buf when (alu_mode = "101") or (alu_mode = "110") else
		  -- default
		  (others => '0');

	z_flag <= '0' when (rst = '1') or ((alu_mode = "111") and (signed(in1) /= 0)) else
		  '1' when (alu_mode = "111") and (signed(in1) = 0) else
		  '0';

	n_flag <= '0' when (rst = '1') or ((alu_mode = "111") and (signed(in1) >= 0)) else
		  '1' when (alu_mode = "111") and (signed(in1) < 0) else
		  '0';

	v_flag <= '1' when (alu_mode = "011") and (unsigned(mult_buf(31 downto 16)) > 0) else
		  '0' when (rst = '1') else
		  '0';

    shift_dir <= '0' when (alu_mode = "110") else '1';

	mult : dadda_mult port map (
	   A => in1,
	   B => in2,
	   prod => mult_buf
	);
	
	shifter : bshift port map (
	   left => shift_dir,
	   shift => in2(3 downto 0),
	   input => in1,
	   output => out_buf
    );

end behavioral;
