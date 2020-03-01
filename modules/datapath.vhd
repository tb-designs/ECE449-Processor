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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
  Port ( --Inputs
         data_in : in std_logic_vector (15 downto 0);
         clk     : in std_logic;
         rst     : in std_logic;
         --Input from Controller
         alu_mode   : in std_logic_vector (2 downto 0);
         instr_form : in std_logic_vector (2 downto 0);
         mem_opr, wb_opr : in std_logic;
         --Outputs
         data_out : out std_logic_vector(15 downto 0);
         --Output to controller
         opcode_out : out std_logic_vector(6 downto 0)
         --More outputs as we add to the controller
        );
end datapath;

architecture Behavioral of datapath is

--Datapath Components

--Program Counter
component pc is
    Port ( clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       addr_in : in std_logic_vector(15 downto 0);
       addr_out : out std_logic_vector(15 downto 0)  
      );
end component;

--PC Incrementor
component pc_incr is
  port( prev_addr : in std_logic_vector (15 downto 0);
      clk : in std_logic;
      rst : in std_logic;
      new_addr  : out std_logic_vector (15 downto 0)
    );
end component;


--RAM (Instruction Memory)
--TODO

--IF/ID
component IF_ID is
  port( instr_in  : in  std_logic_vector (15 downto 0); --next instruction to latch
      clk         : in  std_logic;
      mem_data_in : std_logic_vector (15 downto 0);
      op_code_out : out std_logic_vector (6 downto 0);
      ra_addr_out : out std_logic_vector (2 downto 0); -- or r_dest
      rb_addr_out : out std_logic_vector (2 downto 0); -- or r_source
      rc_addr_out : out std_logic_vector (2 downto 0);
      c1_out      : out std_logic_vector (3 downto 0);     --format A2
      instr_out   : out std_logic_vector (15 downto 0)
      );
end component;

--Register File
component register_file is
    port(rst : in std_logic; clk: in std_logic;
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
  port(instr_in    : in std_logic_vector (15 downto 0);
     reg_data_1    : in std_logic_vector (15 downto 0);
     reg_data_2    : in std_logic_vector (15 downto 0);
     c1_in         : in std_logic_vector (3 downto 0);
     alu_mode_in   : in std_logic_vector (2 downto 0);
     instr_form_in : in std_logic_vector (2 downto 0);
     ra_addr_in    : in std_logic_vector (2 downto 0);
     mem_oper_in   : in std_logic;
     wb_oper_in    : in std_logic;
     clk           : in std_logic;
     operand1      : out std_logic_vector (15 downto 0);
     operand2      : out std_logic_vector (15 downto 0);
     instr_out     : out std_logic_vector (15 downto 0);
     instr_form_out: out std_logic_vector (2 downto 0);
     alu_mode_out  : out std_logic_vector (2 downto 0);
     ra_addr_out   : out std_logic_vector (2 downto 0);
     mem_oper_out  : out std_logic;
     wb_oper_out   : out std_logic
     );
end component;

--ALU
component ALU is
	Port ( in_1 : in STD_LOGIC_VECTOR (15 downto 0);
           in_2 : in STD_LOGIC_VECTOR (15 downto 0);
           alu_mode : in STD_LOGIC_VECTOR (2 downto 0);
           rst : in STD_LOGIC;
           result : out STD_LOGIC_VECTOR (15 downto 0);
           z_flag : out STD_LOGIC;
           n_flag : out STD_LOGIC
           );
end component;

--EX/MEM
component EX_MEM is
  port(instr_in     : in std_logic_vector (15 downto 0);
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
end component;

--RAM (Data Memory)
--TODO

--MEM/WB
component MEM_WB is 
  port(
     instr_in       : in std_logic_vector (15 downto 0);
     --mem_data_in    : in std_logic_vector (15 downto 0);
     alu_result_in  : in std_logic_vector (15 downto 0);
     ra_addr_in     : in std_logic_vector (2 downto 0);
     wb_oper_in     : in std_logic;
     clk            : in std_logic;
     --mem_data_out   : out std_logic_vector (15 downto 0);
     alu_result_out : out std_logic_vector (15 downto 0);
     ra_addr_out    : out std_logic_vector (2 downto 0);
     wb_oper_out    : out std_logic
     );
end component;

--Output Register
component output_reg is 
    Port ( clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       result_in : in STD_LOGIC_VECTOR (15 downto 0);
       result_out : out STD_LOGIC_VECTOR (15 downto 0)
       );
end component;

--Signals (internal connections)
--PC & Instr Mem
signal pc_input,pc_output : std_logic_vector (15 downto 0);

--IF/ID
signal ifid_in, ifid_instr_out : std_logic_vector (15 downto 0);
signal ifid_ra_out, ifid_rb_out, ifid_rc_out : std_logic_vector(2 downto 0);
signal ifid_c1_out : std_logic_vector (3 downto 0);

--Reg_File
signal ra_addr_in, rb_addr_in, rc_addr_in : std_logic_vector (2 downto 0);
signal regfile_alu_result_in, rb_data_out, rc_data_out : std_logic_vector (15 downto 0);
signal regfile_wr_en_in : std_logic;

--ID/EX
signal rb_data_in, rc_data_in, operand1_sig, operand2_sig, idex_instr_out : std_logic_vector(15 downto 0);
signal idex_ra_out,alu_mode_in, alu_mode_out, instr_form_in, idex_instr_form_out : std_logic_vector (2 downto 0);
signal mem_opr_in,wb_opr_in, idex_mem_opr_out, idex_wb_opr_out : std_logic;

--ALU
signal alu_result_out : std_logic_vector(15 downto 0);
 
 --EX/MEM
 signal exmem_alu_res_out, exmem_instr_out : std_logic_vector(15 downto 0);
 signal exmem_ra_out, exmem_instr_form_out : std_logic_vector (2 downto 0);
 signal exmem_mem_opr_out, exmem_wb_opr_out : std_logic;
 
 --MEM/WB

 
 
 
 
 


--Connections
begin
--IF Stage
pc0: pc port map (
    clk => clk,
    rst => rst,
    addr_in => data_in,
    addr_out => pc_output
);

pc1: pc_incr port map(
    clk =>clk,
    rst => rst,
    prev_addr => pc_output,
    new_addr => pc_input
);

--ROM MAP HERE
--INSTR MEM MAP HERE 

ifid0: IF_ID port map(
    clk => clk,
    instr_in => ifid_in,
    op_code_out => opcode_out,
    ra_addr_out => ifid_ra_out,
    rb_addr_out => ifid_rb_out,
    rc_addr_out => ifid_rc_out,
    c1_out => ifid_c1_out,
    instr_out => ifid_instr_out
);

rf0: register_file port map(
    clk => clk,
    rst => rst,
    wr_index => ra_addr_in,
    rd_index1 => ifid_rb_out,
    rd_index2 => ifid_rc_out,
    rd_data1 => rb_data_out,
    rd_data2 => rc_data_out,
    wr_data => regfile_alu_result_in,
    wr_enable => regfile_wr_en_in
);

idex0: ID_EX port map(
    clk => clk,
    instr_in => ifid_instr_out,
    reg_data_1 => rb_data_out,
    reg_data_2 => rc_data_out,
    c1_in => ifid_c1_out,
    alu_mode_in => alu_mode, --From controller
    instr_form_in => instr_form, --From controller
    ra_addr_in => ifid_ra_out,
    mem_oper_in => mem_opr, --From Controller
    wb_oper_in => wb_opr,
    operand1 => operand1_sig,
    operand2 => operand2_sig,
    instr_out => idex_instr_out,
    alu_mode_out => alu_mode_out,
    ra_addr_out => idex_ra_out,
    mem_oper_out => idex_mem_opr_out,
    wb_oper_out => idex_wb_opr_out
);

alu0: alu port map (
    in_1 => operand1_sig,
    in_2 => operand2_sig,
    alu_mode => alu_mode_out,
    rst => rst,
    result => alu_result_out
);

exmem0: EX_MEM port map (
    clk => clk,
    instr_in => idex_instr_out,
    alu_result => alu_result_out,
    instr_form_in => idex_instr_form_out,
    ra_addr_in => idex_ra_out,
    mem_oper_in => idex_mem_opr_out,
    wb_oper_in => idex_wb_opr_out,
    instr_out => exmem_instr_out,
    alu_result_out => exmem_alu_res_out,
    ra_addr_out => exmem_ra_out,
    mem_oper_out => exmem_mem_opr_out,
    wb_oper_out => exmem_wb_opr_out,
    instr_form_out => exmem_instr_form_out
);

--RAM here

memwb0: MEM_WB port map (
    clk => clk,
    instr_in => exmem_instr_out,
    alu_result_in => exmem_alu_res_out,
    ra_addr_in => idex_ra_out,
    wb_oper_in => exmem_wb_opr_out,
    --mem_data_out =>    --Decide between this value and the alu data   
    alu_result_out => regfile_alu_result_in, --to REGFILE
    ra_addr_out => ra_addr_in,
    wb_oper_out => regfile_wr_en_in
);


end Behavioral;
