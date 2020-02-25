----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 04:02:50 PM
-- Design Name: 
-- Module Name: pc - Behavioral
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

entity pc is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           addr_in : in std_logic_vector(15 downto 0);
           addr_out : out std_logic_vector(15 downto 0)  
          );
end pc;

architecture Behavioral of pc is

    --Signals
    signal current_addr : std_logic_vector(15 downto 0) := (others => '0');

    begin
    process(clk)
    begin
        if rst='1' then
            --Reset to base address
            current_addr <= X"0000";
            addr_out <= X"0000";
        end if;
    
        if(clk='0' and clk'event) then
            --Rising edge, set outputs
            addr_out <= current_addr;
        elsif (clk='1' and clk'event) then
            --Falling Edge, store inputs
            current_addr <= addr_in;
        end if;
        
        
        
    end process;
end Behavioral;
