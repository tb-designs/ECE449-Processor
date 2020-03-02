----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2020 04:45:21 PM
-- Design Name: 
-- Module Name: mem_int_sim - behavioral
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

entity mem_sim is
end mem_sim;

architecture behavioral of mem_sim is

component mem_interface port(
    addr1,addr2 : in std_logic_vector (15 downto 0); -- addr1 is r/w, addr2 is r only
    wr_data : in std_logic_vector(15 downto 0);
    clk,rst : in std_logic;
    wr_en : in std_logic_vector(1 downto 0);
  	r1_data,r2_data : out std_logic_vector(15 downto 0);
  	err : out std_logic;
    in_port : in std_logic_vector(15 downto 0);
    out_port : out std_logic_vector(15 downto 0));
end component;

signal addr1,addr2 : std_logic_vector (15 downto 0);
signal wr_data : std_logic_vector(15 downto 0);
signal clk,rst : std_logic;
signal wr_en : std_logic_vector(1 downto 0);
signal r1_data,r2_data : std_logic_vector(15 downto 0);
signal in_port,out_port : std_logic_vector(15 downto 0);

begin
mem : mem_interface port map(
    addr1 => addr1,
    addr2 => addr2,
    wr_data => wr_data,
    clk => clk,
    rst => rst,
    wr_en => wr_en,
    r1_data => r1_data,
    r2_data => r2_data,
    err => open,
    in_port => in_port,
    out_port => out_port);

clock : process
begin
clk <= '0'; wait for 10 us;
clk <= '1'; wait for 10 us;
end process;

mem_sim : process
begin
rst <= '1';
wait until (clk='1' and clk'event);
rst <= '0';
wait until (clk='1' and clk'event);
addr1 <= X"0400"; addr2 <= X"0000"; wr_en <= "11"; wr_data <= X"3434";
wait until (clk='1' and clk'event);
addr1 <= X"0400"; addr2 <= X"0002"; wr_en <= "00";
wait until (clk='1' and clk'event);
addr1 <= X"0702"; addr2 <= X"0400"; wr_en <= "11"; wr_data <= X"1515";
wait until (clk='1' and clk'event);
addr1 <= X"0406"; addr2 <= X"0702"; wr_data <= X"FF22";
wait until (clk='1' and clk'event);
addr1 <= X"0400"; addr2 <= X"0406"; wr_en <= "00"; in_port <= X"4444";
wait until (clk='1' and clk'event);
addr1 <= X"FFF0"; addr2 <= X"0200";
wait until (clk='1' and clk'event);
addr1 <= X"FFF2"; addr2 <= X"0300"; wr_en <= "11"; wr_data <= X"8889";
wait until (clk='1' and clk'event);
addr1 <= X"0702"; addr2 <= X"0702"; wr_en <= "00";
wait until (clk='1' and clk'event);
rst <= '1';
wait;
end process;

end behavioral;
