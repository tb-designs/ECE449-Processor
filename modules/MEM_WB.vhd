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

--Type for easier modification
type mem_wb is record
    mem_data     : std_logic_vector (15 downto 0);
    alu_result   : std_logic_vector (15 downto 0);
    instr_format : std_logic_vector (2 downto 0);
    pc_addr      : std_logic_vector (15 downto 0);
    opcode       : std_logic_vector (6 downto 0);
    ra_addr      : std_logic_vector (2 downto 0);
    wb_opr       : std_logic;
end record mem_wb;

--Specify init value for the type
constant MEM_WB_INIT : mem_wb := (
    mem_data    => (others => '0'),
    alu_result => (others => '0'),
    instr_format     => (others => '0'),
    pc_addr    => (others => '0'),
    opcode  => (others => '0'),
    ra_addr   => (others => '0'),
    wb_opr     => '0'
    );

  --Signals(acting as our register)
  signal mem_wb_sig : mem_wb := MEM_WB_INIT;

  begin
    process(clk,rst)
    begin
      --reset behaviour, all outputs to zero
      if rst = '1' then
          wb_data_out <= (others => '0');
          ra_addr_out <= (others => '0');
          wb_oper_out <= '0';
      end if;

    
    --if the clock is falling we latch
    --if the clock is rising we gate
    if(clk='0' and clk'event) then
       --rising edge set output

        ra_addr_out <= mem_wb_sig.ra_addr;
        wb_oper_out <= mem_wb_sig.wb_opr;

      --data output depends on if ALU op or if a LOAD
      if mem_wb_sig.opcode = "0010000" then
        --LOAD
        wb_data_out <= mem_wb_sig.mem_data;
      else
        --NOT LOAD
        wb_data_out <= mem_wb_sig.alu_result;  
      end if;
        
    elsif(clk='1' and clk'event) then
       --falling edge store input
       mem_wb_sig.mem_data <= mem_data_in;
       mem_wb_sig.alu_result <= alu_result_in;
       mem_wb_sig.instr_format <= instr_format_in;
       mem_wb_sig.pc_addr <= pc_addr_in;
       mem_wb_sig.opcode <= opcode_in;
       mem_wb_sig.ra_addr <= ra_addr_in;
       mem_wb_sig.wb_opr <= wb_oper_in;

    end if;
  end process;   
end Behavioral;