library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--Wrapper around Xilinx RAM and ROM modules

entity mem_interface is
  Port ( inst_addr_in : in std_logic_vector (11 downto 0);
         data_addr_in : in std_logic_vector (11 downto 0);
         rst : in std_logic;
         inst_addr_ram : out std_logic_vector (11 downto 0);
         data_addr_ram : out std_logic_vector (11 downto 0);
         inst_addr_rom : out std_logic_vector (11 downto 0);
         inst_addr_io : out std_logic_vector (11 downto 0));
         
         
end mem_interface;

architecture Behavioral of mem_interface is

begin
process( inst_addr_in, data_addr_in, rst)
begin
--Reset Behaviour
    if (rst = '1') then
        inst_addr_ram <= (others => '0');
        data_addr_ram <= (others => '0');
        inst_addr_rom <= (others => '0');
        inst_addr_io <= (others => '0');
   elsif rst = '0' then
     --choice of output depends on memory address (mem mapped)
     --ROM: 0x0000 to 0x03E0
     --RAM: 0x0400 to 0x0800
     --InputPort:  0xFFF0
     --OutputPort: 0xFFF2

    -- Instruction Address Behaviour
     if inst_addr_in < X"0400" then
        --Then this is a ROM address
        inst_addr_rom <= inst_addr_in;
        
     elsif inst_addr_in >= X"0400" then
        --Then this is a RAM address
        inst_addr_ram <= inst_addr_in;
     elsif inst_addr_in = X"FFF0" or inst_addr_in = X"FFF2" then
        --Then this is one of the I/O ports
        inst_addr_io <= inst_addr_in;
     end if
     end if
     end if

    --Data Address Behaviour
    if data_addr_in >= X"0400" then
        --can only write to RAM
        data_addr_ram <= data_addr_in;
    elsif data_addr_in = X"FFF0" or data_addr_in = X"FFF2"
        ---io address
        inst_addr_io <= data_addr_in;
    end if
    end if
    
    
  end if
  end if   
  end Behavioral;