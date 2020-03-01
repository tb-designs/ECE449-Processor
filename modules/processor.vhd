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
        en : in std_logic;
        addr_in : in std_logic_vector(15 downto 0);
        addr_out : out std_logic_vector(15 downto 0)  
    );
end component;

--PC Incrementor
component pc_incr is
    port (
        prev_addr : in std_logic_vector (15 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        new_addr  : out std_logic_vector (15 downto 0)
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
        instr_in : in  std_logic_vector (15 downto 0); --next instruction to latch
        clk : in  std_logic;
        op_code_out : out std_logic_vector (6 downto 0);
        ra_addr_out : out std_logic_vector (2 downto 0); -- or r_dest
        rb_addr_out : out std_logic_vector (2 downto 0); -- or r_source
        rc_addr_out : out std_logic_vector (2 downto 0);
        c1_out : out std_logic_vector (3 downto 0);     --format A2
        instr_out : out std_logic_vector (15 downto 0)
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
        instr_in    : in std_logic_vector (15 downto 0);
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
        alu_mode_out  : out std_logic_vector (2 downto 0);
        ra_addr_out   : out std_logic_vector (2 downto 0);
        mem_oper_out  : out std_logic;
        wb_oper_out   : out std_logic
        );
end component;

--ALU
component ALU is
    port (
        in_1 : in std_logic_vector (15 downto 0);
        in_2 : in std_logic_vector (15 downto 0);
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
        instr_in     : in std_logic_vector (15 downto 0);
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

--MEM/WB
component MEM_WB is 
    port (
        instr_in       : in std_logic_vector (15 downto 0);
        mem_data_in    : in std_logic_vector (15 downto 0);
        alu_result_in  : in std_logic_vector (15 downto 0);
        ra_addr_in     : in std_logic_vector (2 downto 0);
        wb_oper_in     : in std_logic;
        clk            : in std_logic;
        instr_out      : out std_logic_vector (15 downto 0);
        mem_data_out   : out std_logic_vector (15 downto 0);
        alu_result_out : out std_logic_vector (15 downto 0);
        ra_addr_out    : out std_logic_vector (2 downto 0);
        wb_oper_out    : out std_logic
    );
end component;

--Signals (internal connections)


--Connections
begin



--TODO









end behavioral;
