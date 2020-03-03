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
    Port ( n_flag_in : in std_logic;
           z_flag_in : in std_logic;
           br_flag_in : in std_logic;
           clear_test_flags : in std_logic;
           n_flag_out : out std_logic;
           z_flag_out : out std_logic;
           br_flag_out : out std_logic
           );
end status_reg;

architecture Behavioral of status_reg is

--Type containing all flags needed (so far)
type status_reg is record
    n_flag : std_logic;
    z_flag : std_logic;
    br_flag: std_logic;
end record status_reg; 

constant STATUS_REG_INIT : status_reg := (n_flag => '0',
                                          z_flag => '0',
                                          br_flag => '0'
                                          );

--Signals
signal stat_reg_sig : status_reg := STATUS_REG_INIT;

begin

--Clear Behaviour
process(clear_test_flags)
begin

    if clear_test_flags = '1' then
        stat_reg_sig.n_flag <= '0';
        stat_reg_sig.z_flag <= '0';
        stat_reg_sig.br_flag <= '0';
    end if;

end process;

    --store flags here
    stat_reg_sig.n_flag  <= '1' when n_flag_in = '1'; --no else, want these to be sticky until the clear
    stat_reg_sig.z_flag  <= '1' when z_flag_in = '1';
    stat_reg_sig.br_flag <= '1' when br_flag_in = '1';
    
    --Output
    n_flag_out <= stat_reg_sig.n_flag;
    z_flag_out <= stat_reg_sig.z_flag;
    br_flag_out <= stat_reg_sig.br_flag;


end Behavioral;
