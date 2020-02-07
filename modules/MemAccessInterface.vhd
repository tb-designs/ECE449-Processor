library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Wrapper around Xilinx RAM and ROM modules

entity mem_interface is
  Port ( r_addr_in : in std_logic_vector (11 downto 0);
         wr_addr_in : in std_logic_vector (11 downto 0);
         wr_data_in : in std_logic_vector (15 downto 0);
         r_data_in : in std_logic_vector (15 downto 0);
         wr_data_IO : out std_logic_vector (15 downto 0);
         wr_addr_out : out std_logic_vector (11 downto 0);
         wr_data_out : out std_logic_vector (15 downto 0);
         r_addr_RAM : out std_logic_vector (11 downto 0);
         r_addr_ROM : out std_logic_vector (11 downto 0);
         r_data_out : out std_logic_vector (15 downto 0));
         
end mem_interface;

architecture Behavioral of mem_interface is



  end Behavioral;