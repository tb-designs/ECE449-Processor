library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity EX_MEM is 
  port(instr_in       : in std_logic_vector (15 downto 0);
       alu_result     : in std_logic_vector (15 downto 0);
       instr_form_in  : in std_logic_vector (2 downto 0);
       ra_addr_in     : in std_logic_vector (2 downto 0);
       mem_oper_in    : in std_logic;
       wb_oper_in     : in std_logic;
       clk            : in std_logic;
       instr_out      : out std_logic_vector (15 downto 0);
       alu_result_out : out std_logic_vector (15 downto 0);
       instr_form_out : out std_logic_vector (2 downto 0);
       ra_addr_out    : out std_logic_vector (2 downto 0);
       mem_oper_out   : out std_logic;
       wb_oper_out    : out std_logic
  );

end EX_MEM;

architecture Behavioral of EX_MEM is

  --Signals(acting as our register)
  signal ex_mem : std_logic_vector (39 downto 0) := (others => '0');
  
  --Alias
  alias instr      is ex_mem(39 downto 24);
  alias alu_res    is ex_mem(23 downto 8);
  alias instr_form is ex_mem(7 downto 5);
  alias ra_addr    is ex_mem(4 downto 2);
  alias mem_opr    is ex_mem(1);
  alias wb_opr     is ex_mem(0);
  
begin
    process(clk)
    begin
    --if the clock is falling we latch
    --if the clock is rising we gate 

     if(clk='0' and clk'event) then
        --rising edge set output
        instr_out <= instr;
        alu_result_out <= alu_res;
        instr_form_out <= instr_form;
        ra_addr_out <= ra_addr;
        mem_oper_out <= mem_opr;
        wb_oper_out <= wb_opr;
        
     elsif(clk='1' and clk'event) then
        --falling edge store input
        ex_mem <= instr_in&
               alu_result&
               instr_form_in&
               ra_addr_in&
               mem_oper_in&
               wb_oper_in&
                  

     end if
     end if
     end process

  end Behavioral;