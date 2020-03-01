library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pc_incr is 
  port( prev_addr : in std_logic_vector (15 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        new_addr  : out std_logic_vector (15 downto 0)
      );

end pc_incr;

architecture Behavioral of pc_incr is

    --Signals
    signal result : std_logic_vector(15 downto 0);

    begin
    --asynchronus Arithmetic stage (increment address by 4)
    result <= prev_addr + "0000000000000100";
    
    
    process(clk,rst)
    begin
        --Reset behaviour
        if rst='1' then
            result <= (others => '0');
        end if;
    
        if(clk='0' and clk'event) then
            --Rising Edge, set output
            new_addr <= result;
        elsif (clk='1' and clk'event) then
            --Falling edge, latch input
            result <= prev_addr;
        end if;            
        
    end process;
  end Behavioral;