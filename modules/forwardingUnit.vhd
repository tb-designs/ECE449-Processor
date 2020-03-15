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
        idex_reg1_addr   : in STD_LOGIC_VECTOR (2 downto 0);
        idex_reg2_addr   : in STD_LOGIC_VECTOR (2 downto 0);
        idex_reg1_data   : in STD_LOGIC_VECTOR (15 downto 0);
        idex_reg2_data   : in STD_LOGIC_VECTOR (15 downto 0);
        idex_instr_form  : in STD_LOGIC_VECTOR (2 downto 0);
        exmem_alu_result : in STD_LOGIC_VECTOR (15 downto 0);
        memwb_alu_result : in STD_LOGIC_VECTOR (15 downto 0);
        exmem_wb_oper    : in STD_LOGIC;
        memwb_wb_oper    : in STD_LOGIC;
        alu_operand1     : out STD_LOGIC_VECTOR (15 downto 0);
        alu_operand2     : out STD_LOGIC_VECTOR (15 downto 0)
        );
end fwdunit;

architecture Behavioral of fwdunit is


begin
--Mux Operation
alu_operand1 <= (others => '0') when rst = '1' else 
                exmem_alu_result when ((exmem_wb_oper = '1') and (exmem_ra_addr = idex_reg1_addr)) else
                memwb_alu_result when ((memwb_wb_oper = '1') and (memwb_ra_addr = idex_reg1_addr) and (exmem_ra_addr /= idex_reg1_addr or exmem_wb_oper = '0')) else
                idex_reg1_data;

alu_operand2 <= (others => '0') when rst = '1' else
                exmem_alu_result when ((exmem_wb_oper = '1') and (exmem_ra_addr = idex_reg2_addr)) else
                memwb_alu_result when ((memwb_wb_oper = '1') and (memwb_ra_addr = idex_reg2_addr) and (exmem_ra_addr /= idex_reg2_addr or exmem_wb_oper /= '0')) else
                idex_reg2_data;
                     

end Behavioral;
