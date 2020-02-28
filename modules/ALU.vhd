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
	Port ( in1 : in STD_LOGIC_VECTOR (15 downto 0);
               in2 : in STD_LOGIC_VECTOR (15 downto 0);
               alu_mode : in STD_LOGIC_VECTOR (2 downto 0);
               rst : in STD_LOGIC;
               result : out STD_LOGIC_VECTOR (15 downto 0);
               z_flag : out STD_LOGIC;
               n_flag : out STD_LOGIC);
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
signal left_buf,right_buf : std_logic_vector(15 downto 0);

begin
	result <= (others => '0') when (rst = '1') else
		  -- NOP
		  NULL when (alu_mode = "000") else
		  -- ADD
		  std_logic_vector(signed(in1) + signed(in2)) when (alu_mode = "001") else
		  -- SUB
		  std_logic_vector(signed(in1) - signed(in2)) when (alu_mode = "010") else
		  -- MUL
		  slice_slv(signed(in1) * signed(in2),15,0) when (alu_mode = "011") else
		  -- NAND
		  in1 nand in2 when (alu_mode = "100") else
		  -- SHL
		  left_buf when (alu_mode = "101") else
		  -- SHR
		  right_buf when (alu_mode = "110") else
		  -- default
		  (others => '0');

	z_flag <= '0' when (rst = '1') or ((alu_mode = "111") and (signed(in1) /= 0)) else
		  '1' when (alu_mode = "111") and (signed(in1) = 0);

	n_flag <= '0' when (rst = '1') or ((alu_mode = "111") and (signed(in1) >= 0)) else
		  '1' when (alu_mode = "111") and (signed(in1) < 0);

	mult : dadda_mult port map(in1,in2,mult_buf);
	shleft : bshift port map('1',in2(3 downto 0),in1,left_buf);
	shright : bshift port map('0',in2(3 downto 0),in1,right_buf);

end behavioral;
