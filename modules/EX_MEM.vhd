library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity EX_MEM is 
  port(alu_result     : in std_logic_vector (15 downto 0);
       instr_form_in  : in std_logic_vector (2 downto 0);
       opcode_in      : in std_logic_vector (6 downto 0);
       PC_addr_in     : in std_logic_vector (15 downto 0);
       dest_data_in   : in std_logic_vector (15 downto 0);
       src_data_in    : in std_logic_vector (15 downto 0);
       ra_addr_in     : in std_logic_vector (2 downto 0);
       mem_oper_in    : in std_logic;
       wb_oper_in     : in std_logic;
       clk,rst        : in std_logic;
       alu_result_out : out std_logic_vector (15 downto 0);
       PC_addr_out    : out std_logic_vector (15 downto 0);
       mem_addr_out   : out std_logic_vector (15 downto 0);
       wr_data_out    : out std_logic_vector (15 downto 0);
       opcode_out     : out std_logic_vector (6 downto 0);
       instr_form_out : out std_logic_vector (2 downto 0);
       ra_addr_out    : out std_logic_vector (2 downto 0);
       mem_oper_out   : out std_logic;
       wb_oper_out    : out std_logic
  );

end EX_MEM;

architecture Behavioral of EX_MEM is

  --Signal (acting as our storage)
  signal ex_mem : std_logic_vector (78 downto 0) := (others => '0');
  
  --Alias
  alias alu_res    is ex_mem(78 downto 63);
  alias instr_form is ex_mem(62 downto 60);
  alias opcode     is ex_mem(59 downto 53);
  alias pc_addr    is ex_mem(52 downto 37);
  alias dest_data  is ex_mem(36 downto 21);
  alias src_data   is ex_mem(20 downto 5);
  alias ra_addr    is ex_mem(4 downto 2);
  alias mem_opr    is ex_mem(1);
  alias wb_opr     is ex_mem(0);
  
  begin
    process(clk,rst)
    begin
      --reset behaviour, all outputs to zero
      if rst = '1' then
          alu_result_out <= (others => '0');
          PC_addr_out <= (others => '0');
          mem_addr_out <= (others => '0');
          wr_data_out <= (others => '0');
          instr_form_out <= (others => '0');
          ra_addr_out <= (others => '0');
          mem_oper_out <= (others => '0');
          wb_oper_out <= (others => '0');
      end if;

    --if the clock is falling we latch
    --if the clock is rising we gate 
    if(clk='0' and clk'event) then
      --rising edge set output

      --pass-through values
      alu_result_out <= alu_res;
      instr_form_out <= instr_form;
      opcode_out <= opcode;
      PC_addr_out <= pc_addr;
      ra_addr_out <= ra_addr;
      mem_opr_out <= mem_opr;
      wb_opr_out <= wb_opr;

      --Data memory outputs depend on if LOAD or STORE instruction
      if opcode is "0010000" then
        --LOAD
        src_data <= dest_data_in;
        dest_data <= src_data_in;

      elsif opcode is "0010001" then
        --STORE
        dest_data <= dest_data_in;
        src_data <= src_data_in;
      else
        --Other instructions do no access Data memory
        --TODO consider sending a default value that the memory interface would recognize
        dest_data <= (others => '0');
        src_data <= (others => '0');

      end if;
      
    elsif(clk='1' and clk'event) then
        --falling edge store input
        ex_mem <= alu_result&
              instr_form_in&
              opcode_in&
              PC_addr_in&
              dest_data_in&
              src_data_in&
              ra_addr_in&
              mem_oper_in&
              wb_oper_in;
                  
    end if;
    end process;

  end Behavioral;