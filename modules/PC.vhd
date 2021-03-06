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
    port (
        clk : in std_logic;
        rst : in std_logic;
        pc_in : in std_logic_vector(15 downto 0);
        pc_out : out std_logic_vector(15 downto 0)  
    );
end pc;

architecture behavioral of pc is

signal next_pc : std_logic_vector (15 downto 0) := (others => '0');

begin
process(clk, rst, pc_in)
begin
    if (rst= '1') then
        --Reset to base address
        pc_out <= (others => '0');
    end if;
    
    
    next_pc <= pc_in;
    
    if rising_edge(clk) then
        pc_out <= next_pc;
    end if;
    
end process;

end behavioral;
