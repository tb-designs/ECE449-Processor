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
       dest_data      : out std_logic_vector (15 downto 0); --
       src_data       : out std_logic_vector (15 downto 0);
       opcode_out     : out std_logic_vector (6 downto 0);
       instr_form_out : out std_logic_vector (2 downto 0);
       ra_addr_out    : out std_logic_vector (2 downto 0);
       mem_oper_out   : out std_logic_vector (1 downto 0); --Mem interface requires vector
       wb_oper_out    : out std_logic
  );

end EX_MEM;

architecture Behavioral of EX_MEM is

--Type for easier modification
type ex_mem is record
    alu_res    : std_logic_vector (15 downto 0);
    instr_form : std_logic_vector (2 downto 0);
    opcode     : std_logic_vector (6 downto 0);
    pc_addr    : std_logic_vector (15 downto 0);
    dest_data  : std_logic_vector (15 downto 0);
    src_data   : std_logic_vector (15 downto 0);
    ra_addr    : std_logic_vector (2 downto 0);
    mem_opr    : std_logic;
    wb_opr     : std_logic;
end record ex_mem;

--Specify init value for the type
constant EX_MEM_INIT : ex_mem := (
    alu_res    => (others => '0'),
    instr_form => (others => '0'),
    opcode     => (others => '0'),
    pc_addr    => (others => '0'),
    dest_data  => (others => '0'),
    src_data   => (others => '0'),
    ra_addr    => (others => '0'),
    mem_opr    => '0',
    wb_opr     => '0'
    );


  --Signal (acting as our storage)
  signal ex_mem_sig : ex_mem := EX_MEM_INIT;
  
  begin
  
          --falling edge store input
  ex_mem_sig.alu_res    <= alu_result;
  ex_mem_sig.instr_form <= instr_form_in;
  ex_mem_sig.opcode     <= opcode_in;
  ex_mem_sig.pc_addr    <= pc_addr_in;
  ex_mem_sig.dest_data  <= dest_data_in;
  ex_mem_sig.src_data   <= src_data_in;
  ex_mem_sig.ra_addr    <= ra_addr_in;
  ex_mem_sig.mem_opr    <= mem_oper_in;
  ex_mem_sig.wb_opr     <= wb_oper_in;
            
  
    process(clk,rst)
    begin
      --reset behaviour, all outputs to zero
      if rst = '1' then
          alu_result_out <= (others => '0');
          PC_addr_out    <= (others => '0');
          dest_data      <= (others => '0');
          src_data       <= (others => '0');
          instr_form_out <= (others => '0');
          ra_addr_out    <= (others => '0');
          mem_oper_out   <= "00";
          wb_oper_out    <= '0';
      end if;

    --if the clock is falling we latch
    --if the clock is rising we gate 
    if(clk='1' and clk'event) then
      --rising edge set output

      --pass-through values
      alu_result_out <= ex_mem_sig.alu_res;
      instr_form_out <= ex_mem_sig.instr_form;
      opcode_out     <= ex_mem_sig.opcode;
      PC_addr_out    <= ex_mem_sig.pc_addr;
      ra_addr_out    <= ex_mem_sig.ra_addr;
      
      --quick fix for wb_oper needing to be 0-length vector
      if ex_mem_sig.mem_opr = '1' then
        mem_oper_out   <= "11";
      else
        mem_oper_out   <= "00";
      end if;
      
      wb_oper_out    <= ex_mem_sig.wb_opr;

      --Data memory outputs depend on if LOAD/IN or STORE/OUT instruction
      if ex_mem_sig.opcode = "0010000" then
        --LOAD
        src_data  <= ex_mem_sig.dest_data;
        dest_data <= ex_mem_sig.src_data;

      elsif ex_mem_sig.opcode = "0010001" then
        --STORE
        dest_data <= ex_mem_sig.dest_data;
        src_data  <= ex_mem_sig.src_data;
        
      elsif ex_mem_sig.opcode = "0100000" then
         --OUT
        dest_data <= ex_mem_sig.dest_data;
        src_data  <= ex_mem_sig.src_data;       
       
      elsif ex_mem_sig.opcode = "0100001" then
        --IN
        dest_data <= ex_mem_sig.dest_data;
        src_data  <= ex_mem_sig.src_data;       
        
      else
        --Other instructions do no access Data memory
        --TODO consider sending a default value that the memory interface would recognize
        dest_data <= (others => '0');
        src_data  <= (others => '0');

      end if;
      
    end if;

    end process;

  end Behavioral;