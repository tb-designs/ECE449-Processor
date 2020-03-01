library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MEM_WB is 
  port(
       mem_data_in     : in std_logic_vector (15 downto 0);
       alu_result_in   : in std_logic_vector (15 downto 0);
       instr_format_in : in std_logic_vector (2 downto 0);
       pc_addr_in      : in std_logic_vector (15 downto 0);
       opcode_in       : in std_logic_vector (6 downto 0);
       ra_addr_in      : in std_logic_vector (2 downto 0);
       wb_oper_in      : in std_logic;
       clk, rst        : in std_logic;
       wb_data_out     : out std_logic_vector (15 downto 0);
       ra_addr_out     : out std_logic_vector (2 downto 0);
       wb_oper_out     : out std_logic
  );

end MEM_WB;

architecture Behavioral of MEM_WB is

  --Signals(acting as our register)
  signal mem_wb : std_logic_vector (61 downto 0) := (others => '0');

  alias mem_data is mem_wb(61 downto 46);
  alias alu_result is mem_wb(45 downto 30);
  alias instr_format is mem_wb(29 downto 27);
  alias pc_addr is mem_wb(26 downto 11);
  alias opcode is mem_wb(10 downto 4);
  alias ra_addr is mem_wb(3 downto 1);
  alias wb_oper is mem_wb(0);

  begin
    process(clk,rst)
    begin
      --reset behaviour, all outputs to zero
      if rst = '1' then
          wb_data_out <= (others => '0');
          ra_addr_out <= (others => '0');
          wb_oper_out <= (others => '0');
      end if;

    
    --if the clock is falling we latch
    --if the clock is rising we gate
    if(clk='0' and clk'event) then
       --rising edge set output

        ra_addr_out <= ra_addr;
        wb_oper_out <= wb_oper;

      --data output depends on if ALU op or if a LOAD
      if opcode is "0010000" then
        --LOAD
        wb_data_out <= mem_data;
      else
        --NOT LOAD
        wb_data_out <= alu_result;  
      end if;
        
    elsif(clk='1' and clk'event) then
       --falling edge store input

        mem_wb <= mem_data_in&
                  alu_result_in&
                  instr_format_in&
                  pc_addr_in&
                  opcode_in&
                  ra_addr_in&
                  wb_oper_in;

    end if;
  end process;   
end Behavioral;