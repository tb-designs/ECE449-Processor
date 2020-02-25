library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MEM_WB is 
  port(
  --Might need to add instruction format input/output later
       instr_in       : in std_logic_vector (15 downto 0);
       mem_data_in    : in std_logic_vector (15 downto 0);
       alu_result_in  : in std_logic_vector (15 downto 0);
       ra_addr_in     : in std_logic_vector (2 downto 0);
       wb_oper_in     : in std_logic;
       clk            : in std_logic;
       instr_out      : out std_logic_vector (15 downto 0);
       mem_data_out   : out std_logic_vector (15 downto 0);
       alu_result_out : out std_logic_vector (15 downto 0);
       ra_addr_out    : out std_logic_vector (2 downto 0);
       wb_oper_out    : out std_logic
  );

end MEM_WB;

architecture Behavioral of MEM_WB is

  --Signals
  signal mem_wb : std_logic_vector (51 downto 0) := (others => '0');

  --Alias
  alias instr is mem_wb(51 downto 36);
  alias mem_data is mem_wb(35 downto 20);
  alias alu_res is mem_wb(19 downto 4);
  alias ra_addr is mem_wb(3 downto 1);
  alias wb_oper is mem_wb(0);


  begin
    process(clk)
    begin
    --if the clock is falling we latch
    --if the clock is rising we gate
    
    if(clk='0' and clk'event) then
       --rising edge set output
        instr_out <= instr;
        mem_data_out <= mem_data;
        alu_result_out <= alu_res;
        wb_oper_out <= wb_oper;
        
    elsif(clk='1' and clk'event) then
       --falling edge store input
        mem_wb <= instr_in&
              mem_data_in&
              alu_result_in&
              ra_addr_in&
              wb_oper_in;

    end if
    end if
       
      



  end Behavioral;