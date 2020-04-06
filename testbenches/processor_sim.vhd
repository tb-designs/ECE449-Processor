----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2020 11:55:29 AM
-- Design Name: 
-- Module Name: processor_sim - Behavioral
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
use ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor_sim is
end processor_sim;

architecture behavioral of processor_sim is

component processor
    port (
        clk : in std_logic;
        sw_in : in std_logic_vector(1 downto 0);
        an_out : out std_logic_vector(3 downto 0);
        sseg_out : out std_logic_vector(6 downto 0);
        in_port : in std_logic_vector(9 downto 0);
        out_port : out std_logic
    );
end component;

-- Inputs
signal clk : std_logic := '0';
signal sw_in : std_logic_vector(1 downto 0) := (others => '0');
signal in_port : std_logic_vector(9 downto 0) := (others => '0');

-- Outputs
signal out_port : std_logic := '0';
signal an_out : std_logic_vector(3 downto 0):= (others => '0');
signal sseg_out : std_logic_vector(6 downto 0):= (others => '0');

constant clk_period : time := 20 us;

begin
u0 : processor port map (
    clk => clk,
    sw_in => sw_in,
    in_port => in_port,
    out_port => out_port,
    an_out => an_out,
    sseg_out => sseg_out
);

-- clk process
clk_process : process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- stimulation process
stim_process : process
begin
    sw_in <= "10";
    in_port <= "0000000101";
    wait for 2*clk_period;
    sw_in <= "00";
    wait for 2*clk_period;
    sw_in <= "00";
    wait for 2*clk_period;
    sw_in <= "00";
    wait;

end process;
    

end behavioral;
