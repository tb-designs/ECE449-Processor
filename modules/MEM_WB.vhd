library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MEM_WB is 
  port(
       instr_in : in std_logic_vector (15 downto 0);
       mem_data : in std_logic_vector (15 downto 0);
       alu_result : in std_logic_vector (15 downto 0);
       wb_oper : in std_logic;
       clk : in std_logic;
       instr_out : out std_logic_vector (15 downto 0);
       mem_data_out : out std_logic_vector (15 downto 0);
       alu_result_out : out std_logic_vector (15 downto 0);
       wb_oper_out : out std_logic
  );

end MEM_WB;

architecture Behavioral of MEM_WB is

  --Signals(acting as our register)
  signal mem_wb : std_logic_vector (48 downto 0) := (others => '0');

  begin
    process(clk)
    begin
    --if the clock is falling we latch
    --if the clock is rising we gate
    
    if(clk='0' and clk'event) then
       --rising edge set output
        instr_out <= mem_wb(48 downto 33);
        mem_data_out <= mem_wb(32 downto 17);
        alu_result_out <= mem_wb(16 downto 1);
        wb_oper_out <= mem_wb(0);
        
    elsif(clk='1' and clk'event) then
       --falling edge store input
        mem_wb <= instr_in &
                  mem_data &
                  alu_result &
                  wb_oper;

    end if
    end if
       
      



  end Behavioral;