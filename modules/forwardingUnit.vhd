----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 04:14:29 PM
-- Design Name: 
-- Module Name: output_reg - Behavioral
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


--PLACE BETWEEN ID/EX LATCH AND ALU
entity fwdunit is
    Port(rst : in STD_LOGIC;
        memwb_ra_addr    : in STD_LOGIC_VECTOR (2 downto 0);
        exmem_ra_addr    : in STD_LOGIC_VECTOR (2 downto 0);
        ifid_reg1_addr   : in STD_LOGIC_VECTOR (2 downto 0);
        ifid_reg2_addr   : in STD_LOGIC_VECTOR (2 downto 0);
        idex_reg1_addr   : in STD_LOGIC_VECTOR (2 downto 0);
        idex_reg2_addr   : in STD_LOGIC_VECTOR (2 downto 0);
        idex_ra_addr     : in STD_LOGIC_VECTOR (2 downto 0);
        idex_reg1_data   : in STD_LOGIC_VECTOR (15 downto 0);
        idex_reg2_data   : in STD_LOGIC_VECTOR (15 downto 0);
        idex_reg1_vflag  : in STD_LOGIC;
        idex_data_pass   : in STD_LOGIC_VECTOR (15 downto 0);
        idex_instr_form  : in STD_LOGIC_VECTOR (2 downto 0);
        idex_opcode_in   : in STD_LOGIC_VECTOR (6 downto 0); --Use for overflow flag forwarding to TEST and LOAD special case
        exmem_alu_result : in STD_LOGIC_VECTOR (15 downto 0);
        memwb_alu_result : in STD_LOGIC_VECTOR (15 downto 0);
        exmem_wb_oper    : in STD_LOGIC;
        memwb_wb_oper    : in STD_LOGIC;
        exmem_v_flag     : in STD_LOGIC;
        memwb_v_flag     : in STD_LOGIC;
        alu_operand1     : out STD_LOGIC_VECTOR (15 downto 0);
        alu_operand2     : out STD_LOGIC_VECTOR (15 downto 0);
        data_pass        : out STD_LOGIC_VECTOR (15 downto 0);
        v_flag_out       : out STD_LOGIC;
        stall_out        : out STD_LOGIC
        );
end fwdunit;

architecture Behavioral of fwdunit is


begin
--Mux Operation

alu_operand1 <= (others => '0') when rst = '1' else
                exmem_alu_result when (exmem_wb_oper = '1') and (exmem_ra_addr = idex_reg1_addr) else
                memwb_alu_result when (memwb_wb_oper = '1') and (memwb_ra_addr = idex_reg1_addr) else
                idex_reg1_data;

alu_operand2 <= (others => '0') when rst = '1' else
                idex_reg2_data when idex_instr_form = "111" else -- don't forward operand2 for L2 instr
                exmem_alu_result when (exmem_wb_oper = '1') and (exmem_ra_addr = idex_reg2_addr) else
                memwb_alu_result when (memwb_wb_oper = '1') and (memwb_ra_addr = idex_reg2_addr) else
                idex_reg2_data;

-- forward mem addresses to LOAD and STORES if preceding instruction writes to same register               
data_pass <= (others => '0') when rst = '1' else
             exmem_alu_result when (idex_instr_form = "111") and (exmem_wb_oper = '1') and (exmem_ra_addr = idex_reg2_addr) else
             memwb_alu_result when (idex_instr_form = "111") and (memwb_wb_oper = '1') and (memwb_ra_addr = idex_reg2_addr) else
             idex_data_pass;
             
-- overflow flag forwarding for TEST
v_flag_out <= '0' when rst = '1' else
              exmem_v_flag when (idex_opcode_in = "0000111") and (exmem_wb_oper = '1') and (exmem_ra_addr = idex_reg1_addr) else
              memwb_v_flag when (idex_opcode_in = "0000111") and (memwb_wb_oper = '1') and (memwb_ra_addr = idex_reg1_addr) else
              idex_reg1_vflag;

--Stall in case when LOAD or IN followed by instr using result       
stall_out <= '1' when (idex_opcode_in = "0010000" or idex_opcode_in = "0100001") and (idex_ra_addr = ifid_reg1_addr or idex_ra_addr = ifid_reg2_addr) else --LOAD
             '0';

end Behavioral;
