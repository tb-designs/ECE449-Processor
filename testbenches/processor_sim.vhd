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
--use IEEE.NUMERIC_STD.ALL;

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
        rst : in std_logic;
        in_port : in std_logic_vector(15 downto 0);
        out_port : out std_logic_vector(15 downto 0)
    );
end component;

-- Inputs
signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal in_port : std_logic_vector(15 downto 0) := (others => '0');

-- Outputs
signal out_port : std_logic_vector(15 downto 0) := (others => '0');

constant clk_period : time := 20 us;

begin
u0 : processor port map (
    clk => clk,
    rst => rst,
    in_port => in_port,
    out_port => out_port
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
    rst <= '1';
    in_port <= X"0000";
    wait for clk_period;
    rst <= '0';
    wait for clk_period/2;
    in_port <= X"0002";
    wait for 3.5*clk_period;
    in_port <= X"0003";
    wait for clk_period;
    in_port <= X"0001";
    wait for clk_period;
    in_port <= X"0005";
    wait for clk_period;
    in_port <= X"0000";
    wait for clk_period;
    in_port <= X"0001";
    wait for clk_period;
    in_port <= X"0005";
    wait for clk_period;
    in_port <= X"0000";
    wait;

end process;
    

end behavioral;
