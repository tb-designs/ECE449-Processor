----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 04:14:29 PM
-- Design Name: 
-- Module Name: output_reg - Behavioral
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

entity output_reg is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           result_in : in STD_LOGIC_VECTOR (15 downto 0);
           result_out : out STD_LOGIC_VECTOR (15 downto 0));
end output_reg;

architecture Behavioral of output_reg is
    --Signals
signal result : std_logic_vector(15 downto 0) := (others => '0');

begin
process(clk)
begin
    if rst='1' then
        --Reset to base address
        result <= X"0000";
    end if;

    if(clk='0' and clk'event) then
        --Rising edge, set outputs
        result_out <= result;
    elsif (clk='1' and clk'event) then
        --Falling Edge, store inputs
        result <= result_in;
    end if;
    
end process;
end Behavioral;
