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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
	Port ( in_1 : in STD_LOGIC_VECTOR (15 downto 0);
               in_2 : in STD_LOGIC_VECTOR (15 downto 0);
               alu_mode : in STD_LOGIC_VECTOR (2 downto 0);
               rst : in STD_LOGIC;
               result : out STD_LOGIC_VECTOR (15 downto 0);
               z_flag : out STD_LOGIC;
               n_flag : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

-- Components
component dadda_mult is
	Port ( A : in std_logic_vector(15 downto 0);
	       B : in std_logic_vector(15 downto 0);
	       prod : out std_logic_vector(31 downto 0));
end component;

-- Functions

--to_int, used to determine amount of shift needed
function to_int(sig : std_logic_vector) return integer is
    variable num : integer := 0;
begin
    for i in sig'range loop
        if sig(i) = '1' then
            num := num*2+1;
        else
            num := num*2;
        end if;
    end loop;
    return num;
end function to_int;

--Signals
signal add_buf : std_logic_vector(16 downto 0);
signal mult_buf : std_logic_vector(31 downto 0);

begin
process(in_1, in_2, alu_mode, rst)
begin
    	--Reset Behaviour
	if (rst = '1') then
      		result_buf <= (others => '0'); 
      		z_flag <= '0'; 
      		n_flag <= '0'; 
    	elsif rst = '0' then
         	case alu_mode(2 downto 0) is
         		--NOP
         		when "000" => NULL;
         		--ADD
         		when "001" => 
            			add_buf <= in_1 + in_2;
            			-- Overflow detection
            			if (result_buf(16) = '1') then
                			z_flag <= '1'; 
                			n_flag <= '1';
            			end if;
            			result <= add_buf;
            
         		--SUB
         		when "010" =>
            			result <= in_1 - in_2;
         		--MUL
         		when "011" =>
	    			multiplier : dadda_mult port map(in_1,in_2,mult_buf);
	    			-- mult_buf <= in_1*in_2;
            			--Temp solution
            			if (mult_buf(16) = '1') then
                			z_flag <= '1'; 
                			n_flag <= '1';
            			end if;
            			result <= mult_buf(15 downto 0);

         		--NAND
         		when "100" =>
            			result <= in_1 NAND in_2;
            
         		--SHL
         		when "101" =>
            			result_buf <= in_1( 15 - to_int(in_2) downto 0) & ((to_int(in_2)-1) downto 0 => '0');
         
         		--SHR
         		when "110" => 
            			result_buf <= ((to_int(in_2)-1) downto 0 => '0') & in_1(15 downto to_int(in_2));
         
         		--TEST
         		when "111" => 
            			if (in_1(15 downto 0) < X"0") then 
                			n_flag <= '1';
            			elsif (in_1(15 downto 0) = X"0") then
                			z_flag <= '1';
            			end if;
         		when others => NULL;
 	 	end case;
	end if;
end process;
end Behavioral;
