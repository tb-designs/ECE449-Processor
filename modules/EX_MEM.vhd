library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity EX_MEM is 
  port(instr_in : in std_logic_vector (15 downto 0);
       alu_result : in std_logic_vector (15 downto 0);
       mem_oper : in std_logic;
       wb_oper  : in std_logic;
       clk : in std_logic;
       alu_result_out : out std_logic_vector (15 downto 0);
       mem_oper_out : out std_logic;
       wb_oper_out : out std_logic;
       instr_out : out std_logic_vector (15 downto 0)
       --possible memory address output?
  );

end EX_MEM;

architecture Behavioral of EX_MEM is

  --Signals(acting as our register)
  signal ex_mem : std_logic_vector (33 downto 0) := (others => '0');
  
begin
    process(clk)
    begin
    --if the clock is falling we latch
    --if the clock is rising we gate 

     if(clk='0' and clk'event) then
        --rising edge set output
        instr_out <= ex_mem(33 downto 18);
        alu_result_out <= ex_mem(17 downto 2);
        mem_oper_out <= ex_mem(1);
        wb_oper_out <= ex_mem(0);
        
     elsif(clk='1' and clk'event) then
        --falling edge store input
        ex_mem <= instr_in &
                  alu_result &
                  mem_oper &
                  wb_oper;
                  

     end if
     end if
     end process

  end Behavioral;