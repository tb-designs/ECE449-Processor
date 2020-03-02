----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 04:18:32 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor is
    port ( --Inputs
        clk : in std_logic;
        rst : in std_logic;
        in_port : in std_logic_vector(15 downto 0);
        out_port : out std_logic_vector(15 downto 0)
    );
end processor;

architecture behavioral of processor is

--Program Counter
component pc is
    port (
        clk : in std_logic;
        rst : in std_logic;
        pc_in : in std_logic_vector(15 downto 0);
        pc_out : out std_logic_vector(15 downto 0)  
    );
end component;

-- Memory Interface
component mem_interface is
    port (
        addr1,addr2 : in std_logic_vector (15 downto 0); -- addr1 is r/w, addr2 is r only
        wr_data : in std_logic_vector(15 downto 0);
        clk,rst : in std_logic;
        wr_en : in std_logic_vector(1 downto 0);
        r1_data,r2_data : out std_logic_vector(15 downto 0);
  	    err : out std_logic;
  	    in_port : in std_logic_vector(15 downto 0);
  	    out_port : out std_logic_vector(15 downto 0)
    );
end component;

--IF/ID
component IF_ID is
    port (
        instr_in, pc_addr_in : in  std_logic_vector (15 downto 0);
        clk,rst : in  std_logic;
        pc_addr_out,op_pass : out std_logic_vector (15 downto 0);
        op_code: out std_logic_vector (6 downto 0);
        instr_format, reg1_addr, reg2_addr : out std_logic_vector (2 downto 0);
        mem_oper_out, wb_oper_out : out std_logic
    );
end component;

--Register File
component register_file is
    port (
        rst : in std_logic; clk: in std_logic;
        --read signals
        rd_index1: in std_logic_vector(2 downto 0); 
        rd_index2: in std_logic_vector(2 downto 0); 
        rd_data1: out std_logic_vector(15 downto 0); 
        rd_data2: out std_logic_vector(15 downto 0);
        --write signals
        wr_index: in std_logic_vector(2 downto 0); 
        wr_data: in std_logic_vector(15 downto 0);
        wr_enable: in std_logic
    );
end component;

--ID/EX
component ID_EX is 
    port (
        data_1, data_2, operand_3, pc_addr_in : in std_logic_vector (15 downto 0);
        opcode_in : in std_logic_vector (6 downto 0);
        instr_form_in : in std_logic_vector (2 downto 0);
        mem_oper_in, wb_oper_in, clk, rst : in std_logic;
        operand1, operand2, pc_addr_out, dest_mem_data, src_mem_data : out std_logic_vector (15 downto 0);
        opcode_out : out std_logic_vector (6 downto 0);
        alu_mode_out, instr_form_out, ra_addr_out : out std_logic_vector (2 downto 0);
        mem_oper_out, wb_oper_out : out std_logic
        );
end component;

--ALU
component ALU is
    port (
        in1 : in std_logic_vector (15 downto 0);
        in2 : in std_logic_vector (15 downto 0);
        alu_mode : in std_logic_vector (2 downto 0);
        rst : in std_logic;
        result : out std_logic_vector (15 downto 0);
        z_flag : out std_logic;
        n_flag : out std_logic
    );
end component;

--EX/MEM
component EX_MEM is
    port (
        alu_result, pc_addr_in, dest_data_in, src_data_in : in std_logic_vector (15 downto 0);
        opcode_in : in std_logic_vector (6 downto 0);
        instr_form_in, ra_addr_in : in std_logic_vector (2 downto 0);
        mem_oper_in, wb_oper_in, clk, rst : in std_logic;
        alu_result_out, pc_addr_out, dest_data, src_data : out std_logic_vector (15 downto 0);
        opcode_out : out std_logic_vector (6 downto 0);
        instr_form_out, ra_addr_out : out std_logic_vector (2 downto 0);
        wb_oper_out : out std_logic;
        mem_oper_out : out std_logic_vector (1 downto 0)
    );
end component;

--MEM/WB
component MEM_WB is 
    port (
        mem_data_in, alu_result_in, pc_addr_in : in std_logic_vector (15 downto 0);
        opcode_in : in std_logic_vector (6 downto 0);
        instr_format_in, ra_addr_in : in std_logic_vector (2 downto 0);
        wb_oper_in, clk, rst : in std_logic;
        wb_data_out   : out std_logic_vector (15 downto 0);
        ra_addr_out    : out std_logic_vector (2 downto 0);
        wb_oper_out    : out std_logic
    );
end component;

-- Constants
constant instr_mem_size : integer := 2; -- each instr is 2 bytes

--GLOBAL
signal clk_sig : std_logic;
signal rst_sig : std_logic;

--INSTRUCTION FETCH
signal instr_mem_output : std_logic_vector (15 downto 0);
signal ifid_pc_addr_out : std_logic_vector (15 downto 0);
signal ifid_op_pass_out : std_logic_vector (15 downto 0);
signal ifid_opcode_out : std_logic_vector (6 downto 0);
signal ifid_instr_format_out : std_logic_vector (2 downto 0);
signal ifid_reg1_addr_out : std_logic_vector (2 downto 0);
signal ifid_reg2_addr_out : std_logic_vector (2 downto 0);
signal ifid_mem_oper_out : std_logic;
signal ifid_wb_oper_out : std_logic;

--INSTRUCTION DECODE
signal regfile_reg1_data_out : std_logic_vector (15 downto 0);
signal regfile_reg2_data_out : std_logic_vector (15 downto 0);
signal idex_operand1_out : std_logic_vector (15 downto 0);
signal idex_operand2_out : std_logic_vector (15 downto 0);
signal idex_opcode_out : std_logic_vector (6 downto 0);
signal idex_alu_mode_out : std_logic_vector (2 downto 0);
signal idex_instr_form_out : std_logic_vector (2 downto 0);
signal idex_pc_addr_out : std_logic_vector (15 downto 0);
signal idex_dest_mem_data_out : std_logic_vector (15 downto 0);
signal idex_src_mem_data_out : std_logic_vector (15 downto 0);
signal idex_ra_addr_out : std_logic_vector (2 downto 0);
signal idex_mem_oper_out : std_logic;
signal idex_wb_oper_out : std_logic;

--EXECUTE
signal alu_result_out : std_logic_vector (15 downto 0);
signal alu_z_flag : std_logic;
signal alu_n_flag : std_logic;
signal exmem_alu_result_out : std_logic_vector (15 downto 0);
signal exmem_pc_addr_out : std_logic_vector (15 downto 0);
signal exmem_dest_data_out : std_logic_vector (15 downto 0);
signal exmem_src_data_out : std_logic_vector (15 downto 0);
signal exmem_opcode_out : std_logic_vector (6 downto 0);
signal exmem_instr_form_out : std_logic_vector (2 downto 0);
signal exmem_ra_addr_out : std_logic_vector (2 downto 0);
signal exmem_mem_oper_out : std_logic_vector (1 downto 0);
signal exmem_wb_oper_out : std_logic;

--MEMORY/WB
signal data_mem_output : std_logic_vector (15 downto 0);
signal memwb_data_out : std_logic_vector (15 downto 0);
signal memwb_ra_addr_out : std_logic_vector (2 downto 0);
signal memwb_wb_oper_out : std_logic;


--PC behaviour
signal pc_addr : std_logic_vector(15 downto 0);
signal pc_next_addr : std_logic_vector(15 downto 0);


begin
-- Component port mappings

--PC
pc0 : pc port map (
    clk => clk,
    rst => rst,
    pc_in => pc_next_addr,
    pc_out => pc_addr
);

--Mem Module
mem0 : mem_interface port map (
    clk => clk,
    rst => rst,
    
    --INSTRUCTION MEMORY
    addr2 => pc_addr,
    r2_data => instr_mem_output,

    --DATA MEMORY
    addr1 => exmem_dest_data_out,
    wr_data => exmem_src_data_out,
    wr_en => exmem_mem_oper_out,
    r1_data => data_mem_output,
    
    --INPUT AND OUTPUT PORTS
    in_port => in_port,
    out_port => out_port
);

--IF/ID
ifid0: if_id port map(
    clk => clk,
    rst => rst,
    
    instr_in => instr_mem_output,
    pc_addr_in => pc_addr,
    
    pc_addr_out => ifid_pc_addr_out,
    op_pass => ifid_op_pass_out,
    op_code => ifid_opcode_out,
    instr_format => ifid_instr_format_out,
    reg1_addr => ifid_reg1_addr_out,
    reg2_addr => ifid_reg2_addr_out,
    mem_oper_out => ifid_mem_oper_out,
    wb_oper_out => ifid_wb_oper_out
);

--Reg File
rf0: register_file port map (
    clk => clk,
    rst => rst,
    
    --READ
    rd_index1 => ifid_reg1_addr_out,
    rd_index2 => ifid_reg2_addr_out,
    rd_data1 => regfile_reg1_data_out,
    rd_data2 => regfile_reg2_data_out, 
    
    --WRITE
    wr_index => memwb_ra_addr_out,
    wr_data => memwb_data_out,
    wr_enable => memwb_wb_oper_out
);

--ID/EX
idex0 : id_ex port map (
    clk => clk,
    rst => rst,
    
    data_1 => regfile_reg1_data_out,
    data_2 => regfile_reg2_data_out,
    operand_3 => ifid_op_pass_out,
    opcode_in => ifid_opcode_out,
    instr_form_in => ifid_instr_format_out,
    pc_addr_in => ifid_pc_addr_out,
    mem_oper_in => ifid_mem_oper_out,
    wb_oper_in => ifid_wb_oper_out,
    
    operand1 => idex_operand1_out,
    operand2 => idex_operand2_out,
    opcode_out => idex_opcode_out,
    alu_mode_out => idex_alu_mode_out,
    instr_form_out => idex_instr_form_out,
    pc_addr_out => idex_pc_addr_out,
    dest_mem_data => idex_dest_mem_data_out,
    src_mem_data => idex_src_mem_data_out,
    ra_addr_out => idex_ra_addr_out,
    mem_oper_out => idex_mem_oper_out,
    wb_oper_out => idex_wb_oper_out
   
);

--ALU
alu0: alu port map (
    rst => rst,
    in1 => idex_operand1_out,
    in2 => idex_operand2_out,
    alu_mode => idex_alu_mode_out,
    result => alu_result_out,
    z_flag => alu_z_flag,
    n_flag => alu_n_flag
);

--EX/MEM
exmem0: ex_mem port map (
    clk => clk,
    rst => rst,

    alu_result => alu_result_out,
    instr_form_in => idex_instr_form_out,
    opcode_in => idex_opcode_out,
    pc_addr_in => idex_pc_addr_out,
    dest_data_in => idex_dest_mem_data_out,
    src_data_in => idex_src_mem_data_out,
    ra_addr_in => idex_ra_addr_out,
    mem_oper_in => idex_mem_oper_out,
    wb_oper_in => idex_wb_oper_out,
    
    alu_result_out => exmem_alu_result_out,
    pc_addr_out => exmem_pc_addr_out,
    dest_data => exmem_dest_data_out,
    src_data => exmem_src_data_out,
    opcode_out => exmem_opcode_out,
    instr_form_out => exmem_instr_form_out,
    ra_addr_out => exmem_ra_addr_out,
    mem_oper_out => exmem_mem_oper_out,
    wb_oper_out => exmem_wb_oper_out
);

--MEM/WB
memwb0: mem_wb port map (
    clk => clk,
    rst => rst,

    mem_data_in => data_mem_output,
    alu_result_in => exmem_alu_result_out,
    instr_format_in => exmem_instr_form_out,
    pc_addr_in => exmem_pc_addr_out,
    opcode_in => exmem_opcode_out,
    ra_addr_in => exmem_ra_addr_out,
    wb_oper_in => exmem_wb_oper_out,
    
    wb_data_out => memwb_data_out,
    ra_addr_out => memwb_ra_addr_out,
    wb_oper_out => memwb_wb_oper_out
    
);


-- Combinational logic
pc_next_addr <= std_logic_vector(unsigned(pc_addr) + instr_mem_size);






end behavioral;
