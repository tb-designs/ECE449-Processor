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
       n_flag_in      : in std_logic;
       z_flag_in      : in std_logic;
       clk,rst        : in std_logic;
       alu_result_out : out std_logic_vector (15 downto 0);
       PC_addr_out    : out std_logic_vector (15 downto 0);
       new_pc_addr_out: out std_logic_vector (15 downto 0); 
       dest_data      : out std_logic_vector (15 downto 0); 
       src_data       : out std_logic_vector (15 downto 0);
       opcode_out     : out std_logic_vector (6 downto 0);
       instr_form_out : out std_logic_vector (2 downto 0);
       ra_addr_out    : out std_logic_vector (2 downto 0);
       mem_oper_out   : out std_logic_vector (1 downto 0); --Mem interface requires vector
       wb_oper_out    : out std_logic;
       br_trigger     : out std_logic --Notifies elements that a branch is occuring (reset by PC once new address is in place)
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
    n_flag     : std_logic;
    z_flag     : std_logic;
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
    n_flag     => '0',
    z_flag     => '0',
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
  ex_mem_sig.n_flag     <= n_flag_in;
  ex_mem_sig.z_flag     <= z_flag_in;                  
            
  
    process(clk,rst)
    begin
      --reset behaviour, all outputs to zero
      if rst = '1' then
          alu_result_out <= (others => '0');
          PC_addr_out    <= (others => '0');
          new_pc_addr_out <= (others => '0');
          dest_data      <= (others => '0');
          src_data       <= (others => '0');
          instr_form_out <= (others => '0');
          ra_addr_out    <= (others => '0');
          mem_oper_out   <= "00";
          wb_oper_out    <= '0';
      end if;

    if(clk='1' and clk'event) then
      --rising edge set output

      --if BR.SUB then we store the current_PC + 2 in the regfile
      if ex_mem_sig.opcode = "1000111" then
        wb_oper_out <= '1'; --enable writeBack to reg 7
        ra_addr_out <= "111"; --r7 is reserved for subroutine return address
        alu_result_out <= ex_mem_sig.pc_addr + (not(X"0002")+X"0001"); -- pass the 2's complement of 2 + current pc_addr
      else
        alu_result_out <= ex_mem_sig.alu_res;
        wb_oper_out    <= ex_mem_sig.wb_opr;
      end if;

      --Pass Through Values              
      instr_form_out <= ex_mem_sig.instr_form;
      opcode_out     <= ex_mem_sig.opcode;
      PC_addr_out    <= ex_mem_sig.pc_addr;
      ra_addr_out    <= ex_mem_sig.ra_addr;
      
      --Fix for mem_oper needing to be 0-length vector
      if ex_mem_sig.mem_opr = '1' then
        mem_oper_out   <= "11";
      else
        mem_oper_out   <= "00";
      end if;
      
      --Data memory outputs depend on if LOAD/IN or STORE/OUT instruction
      --also deal with branch logic here
      case ex_mem_sig.opcode is 
      when "0010000" =>
        --LOAD
        src_data  <= ex_mem_sig.dest_data;
        dest_data <= ex_mem_sig.src_data;
      when "0010001" =>
        --STORE
        dest_data <= ex_mem_sig.dest_data;
        src_data  <= ex_mem_sig.src_data;
      when "0100000" =>
        --OUT
        dest_data <= ex_mem_sig.dest_data;
        src_data  <= ex_mem_sig.src_data;               
      when "0100001" =>
        --IN
        dest_data <= ex_mem_sig.dest_data;
        src_data  <= ex_mem_sig.src_data;
      when "1000001" =>
        --BRR.N
        --Check the n and z flags to decide if branch is taken
        if ex_mem_sig.n_flag = '1' then
          br_trigger <= '1';
        else
          br_trigger <= '0';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
      when "1000010" =>
        --BRR.Z
        if ex_mem_sig.z_flag = '1' then
          br_trigger <= '1';
        else
          br_trigger <= '0';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
      when "1000100" =>
        --BR.N
        if ex_mem_sig.n_flag = '1' then
          br_trigger <= '1';
        else
          br_trigger <= '0';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
      when "1000101" =>
        --BR.Z
        if ex_mem_sig.z_flag = '1' then
          br_trigger <= '1';
        else
          br_trigger <= '0';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
      when others =>
        --OTHER
        dest_data <= (others => '0');
        src_data  <= (others => '0');
      end case;    
          
      --Format Specific Operations (Mostly for Branching behaviour)
      case ex_mem_sig.instr_form is
      when "100" =>
        --BRR, BRR.Z, BRR.N
        new_pc_addr_out <= ex_mem_sig.alu_res;                        
      when "101" =>
        --BR, BR.N, BR.Z, BR.SUB
        new_pc_addr_out <= ex_mem_sig.alu_res;       
      when others =>
        new_pc_addr_out <= (others => '0');          
        br_trigger <= '0';
      end case;
      
    end if;
    end process;

  end Behavioral;
