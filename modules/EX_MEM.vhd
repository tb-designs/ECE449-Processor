library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity EX_MEM is 
  port(alu_result     : in std_logic_vector (15 downto 0);
       instr_form_in  : in std_logic_vector (2 downto 0);
       opcode_in      : in std_logic_vector (6 downto 0);
       PC_addr_in     : in std_logic_vector (15 downto 0);
       data_pass_in   : in std_logic_vector (15 downto 0);
       ra_addr_in     : in std_logic_vector (2 downto 0);
       mem_oper_in    : in std_logic;
       wb_oper_in     : in std_logic;
       m1_in          : in std_logic;
       n_flag_in      : in std_logic;
       z_flag_in      : in std_logic;
       br_flag_in     : in std_logic;
       clk,rst        : in std_logic;
       alu_result_out : out std_logic_vector (15 downto 0);
       PC_addr_out    : out std_logic_vector (15 downto 0);
       new_pc_addr_out: out std_logic_vector (15 downto 0); 
       dest_data      : out std_logic_vector (15 downto 0); 
       src_data       : out std_logic_vector (15 downto 0);
       opcode_out     : out std_logic_vector (6 downto 0);
       instr_form_out : out std_logic_vector (2 downto 0);
       ra_addr_out    : out std_logic_vector (2 downto 0);
       mem_oper_out   : out std_logic_vector (1 downto 0); --Mem interface requires vector input
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
    data_pass  : std_logic_vector (15 downto 0);
    ra_addr    : std_logic_vector (2 downto 0);
    n_flag     : std_logic;
    z_flag     : std_logic;
    mem_opr    : std_logic;
    wb_opr     : std_logic;
    m1         : std_logic;
end record ex_mem;

--Specify init value for the type
constant EX_MEM_INIT : ex_mem := (
    alu_res    => (others => '0'),
    instr_form => (others => '0'),
    opcode     => (others => '0'),
    pc_addr    => (others => '0'),
    data_pass  => (others => '0'),
    ra_addr    => (others => '0'),
    n_flag     => '0',
    z_flag     => '0',
    mem_opr    => '0',
    wb_opr     => '0',
    m1         => '0'
    );


  --Signal (acting as our storage)
  signal ex_mem_sig : ex_mem := EX_MEM_INIT;
  
  begin
  
  --falling edge store input
  ex_mem_sig.alu_res    <= alu_result;
  ex_mem_sig.instr_form <= instr_form_in;
  ex_mem_sig.opcode     <= opcode_in;
  ex_mem_sig.pc_addr    <= pc_addr_in;
  ex_mem_sig.data_pass  <= data_pass_in;
  ex_mem_sig.ra_addr    <= ra_addr_in;
  ex_mem_sig.mem_opr    <= mem_oper_in;
  ex_mem_sig.wb_opr     <= wb_oper_in;
  ex_mem_sig.m1         <= m1_in;
  ex_mem_sig.n_flag     <= n_flag_in;
  ex_mem_sig.z_flag     <= z_flag_in;

process(clk,rst)
begin
    --reset behaviour, all outputs to zero
    if rst = '1' or br_flag_in = '1' then
        alu_result_out <= (others => '0');
        PC_addr_out    <= (others => '0');
        new_pc_addr_out <= (others => '0');
        dest_data      <= (others => '0');
        src_data       <= (others => '0');
        opcode_out     <= (others => '0');
        instr_form_out <= (others => '0');
        ra_addr_out    <= (others => '0');
        mem_oper_out   <= "00";
        wb_oper_out    <= '0';
        br_trigger     <= '0';

    elsif(clk='1' and clk'event) then
      --rising edge set output

      --if BR.SUB then we store the current_PC + 2 in the regfile
      if ex_mem_sig.opcode = "1000110" then
        wb_oper_out <= '1'; --enable writeBack to reg 7
        ra_addr_out <= "111"; --r7 is reserved for subroutine return address
        alu_result_out <= ex_mem_sig.pc_addr + X"0002"; -- pass the 2's complement of 2 + current pc_addr
      elsif ex_mem_sig.opcode = "0010010" then
        --if LOADIMM create data to write back to ra
        if ex_mem_sig.m1 = '1' then
            alu_result_out <= ex_mem_sig.data_pass(7 downto 0)&ex_mem_sig.alu_res(7 downto 0); --concat upper imm with lower r7
        else --m1 = 0
            alu_result_out <= ex_mem_sig.alu_res(15 downto 8)&ex_mem_sig.data_pass(7 downto 0); --concat upper r7 with lower imm
        end if;
        wb_oper_out    <= ex_mem_sig.wb_opr;
        ra_addr_out    <= ex_mem_sig.ra_addr;
      else
        alu_result_out <= ex_mem_sig.alu_res;
        wb_oper_out    <= ex_mem_sig.wb_opr;
        ra_addr_out    <= ex_mem_sig.ra_addr;
      end if;

      --Pass Through Values              
      instr_form_out <= ex_mem_sig.instr_form;
      opcode_out     <= ex_mem_sig.opcode;
      PC_addr_out    <= ex_mem_sig.pc_addr;
      mem_oper_out   <= ex_mem_sig.mem_opr&ex_mem_sig.mem_opr; --Fix for mem_oper needing to be 0-length vector      
      
      --Opcode specific behaviour
      case ex_mem_sig.opcode is
      when "0010000" =>
        --LOAD
        dest_data  <= ex_mem_sig.data_pass; --address to load data from
        src_data <= (others => '0'); --don't care
        br_trigger <= '0';
      when "0010001" =>
        --STORE
        dest_data <= ex_mem_sig.data_pass; --address to store data to
        src_data  <= ex_mem_sig.alu_res; --data to store passed through alu
        br_trigger <= '0';
      when "0100000" =>
        --OUT
        dest_data <= ex_mem_sig.data_pass; --address of mem mapped out port
        src_data  <= ex_mem_sig.alu_res; --data to store passed through alu
        br_trigger <= '0';        
      when "0100001" =>
        --IN
        dest_data <= ex_mem_sig.data_pass; --address of mem mapped in port
        src_data  <= (others => '0'); --don't care
        br_trigger <= '0';
      when "1000000" =>
        --BRR
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;  
        br_trigger <= '1';
      when "1000001" =>
        --BRR.N
        --Check the n and z flags to decide if branch is taken
        if ex_mem_sig.n_flag = '1' then
          br_trigger <= '1';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;  
      when "1000010" =>
        --BRR.Z
        if ex_mem_sig.z_flag = '1' then
          br_trigger <= '1';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;        
      when "1000011" =>
        --BR
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;          
      when "1000100" =>
        --BR.N
        if ex_mem_sig.n_flag = '1' then
          br_trigger <= '1';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;  
      when "1000101" =>
        --BR.Z
        if ex_mem_sig.z_flag = '1' then
          br_trigger <= '1';
        end if;
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res; 
      when "1000110" =>
        --BR.SUB  
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;
        br_trigger <= '1';  
      when "1000111" =>
        --RETURN
        br_trigger <= '1';
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        new_pc_addr_out <= ex_mem_sig.alu_res;  
      when others =>
        --OTHER
        dest_data <= (others => '0');
        src_data  <= (others => '0');
        br_trigger <= '0';
        new_pc_addr_out <= (others => '0');  
      end case;    
      
    end if;
end process;

end Behavioral;
