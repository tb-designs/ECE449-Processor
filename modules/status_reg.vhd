----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2020 02:17:38 PM
-- Design Name: 
-- Module Name: status_reg - Behavioral
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

entity status_reg is
    Port ( n_flag_in : in STD_LOGIC;
           z_flag_in : in STD_LOGIC;
           br_flag_in : in STD_LOGIC;
           clear_test_flags : in std_logic;
           n_flag_out : out std_logic;
           z_flag_out : out std_logic;
           br_flag_out : out std_logic
           );
end status_reg;

architecture Behavioral of status_reg is

begin


end Behavioral;
