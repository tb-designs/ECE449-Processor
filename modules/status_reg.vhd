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
    port (clk, rst : in std_logic;
          n_flag_in : in std_logic;
          z_flag_in : in std_logic;
          br_flag_in : in std_logic;
          clear_test_flags : in std_logic;
          n_flag_out : out std_logic;
          z_flag_out : out std_logic;
          br_flag_out : out std_logic
          );
end status_reg;

architecture Behavioral of status_reg is

begin
    process(clk, rst, clear_test_flags)
    begin
        -- Reset Behaviour
        if (rst = '1') then
            n_flag_out <= '0';
            z_flag_out <= '0';
            br_flag_out <= '0';
        end if;
    
        if (clk = '1' and clk'event) then
           if clear_test_flags = '1' then
               n_flag_out <= '0';
               z_flag_out <= '0';
               br_flag_out <= '0';
           end if;
           if (n_flag_in = '1') then
               n_flag_out <= '1';
           end if;
           if (z_flag_in = '1') then
               z_flag_out <= '1';
           end if;
           if (br_flag_in = '1') then
               br_flag_out <= '1';
           end if;           
        end if;
    end process;

end Behavioral;
