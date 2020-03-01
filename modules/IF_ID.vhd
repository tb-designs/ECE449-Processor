----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2020 12:02:28 PM
-- Design Name: 
-- Module Name: IF_ID - Behavioral
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
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IF_ID is 
  port( instr_in     : in std_logic_vector (15 downto 0); --next instruction to latch
        PC_addr_in   : in std_logic_vector (15 downto 0);
        PC_addr_out  : out std_logic_vector (15 downto 0);
        op_pass      : out std_logic_vector (8 downto 0);  --Pass through operand (c1 OR ra OR disp1 OR disps OR imm)
        op_code      : out std_logic_vector (6 downto 0);
        instr_format : out std_logic_vector (2 downto 0);
        reg1_addr    : out std_logic_vector (2 downto 0); --To Reg File
        reg2_addr    : out std_logic_vector (2 downto 0); --To Reg File
        clk, rst     : in std_logic
      );
end IF_ID;

architecture Behavioral of IF_ID is
    --Functions

--Used to decode the instruction format
function get_instrformat(op : std_logic_vector(6 downto 0)) return std_logic_vector is
        variable format : std_logic_vector(2 downto 0) := (others => '0');       
        begin
        case op is
        --A1
        when "0000001" => format := "001"; --ADD
        when "0000010" => format := "001"; --SUB
        when "0000011" => format := "001"; --MUL
        when "0000100" => format := "001"; --NAND
        --A2
        when "0000101" => format := "010"; --SHL
        when "0000110" => format := "010"; --SHR
        --A3
        when "0000111" => format := "011"; --TEST
        when "0100000" => format := "011"; --OUT
        when "0100001" => format := "011"; --IN
        --B1
        when "1000000" => format := "100"; --BRR
        when "1000001" => format := "100"; --BRR.N
        when "1000010" => format := "100"; --BRR.Z
        --B2
        when "1000011" => format := "101"; --BR
        when "1000100" => format := "101"; --BR.N
        when "1000101" => format := "101"; --BR.Z
        when "1000111" => format := "101"; --BR.SUB
        --L1
        when "0010010" => format := "110"; --LOADIMM
        --L2
        when "0010000" => format := "111"; --LOAD
        when "0010001" => format := "111"; --STORE
        when "0010011" => format := "111"; --MOV
        --Default to A0 (NOP,RETURN)
        when others => format := "000";
        
        end case;    
        return format;
        
end function get_instrformat;


  --Signals
  signal if_id   : std_logic_vector (15 downto 0) := (others => '0');
  signal pc_addr : std_logic_vector (15 downto 0) := (others => '0');
  signal format  : std_logic_vector (2 downto 0)  := (others => '0');
  
  --Alias
  alias default_reg is "000";
  --Take the segments as needed depending on the format
  --A1, A3
  alias opcode is if_id(15 downto 9);
  alias ra_addr_sig is if_id(8 downto 6);
  alias rb_addr_sig is if_id(5 downto 3);
  alias rc_addr_sig is if_id(2 downto 0);
  --A2
  alias c1_sig is if_id(3 downto 0);
  --B1
  alias disp1 is if_id(8 downto 0);
  --B2
  alias disps is if_id(5 downto 0);
  --L1
  alias m1 is if_id(8);
  alias imm is if_id(7 downto 0);
  --L2
  alias rdest is if_id(8 downto 6);
  alias rsrc is if_id(5 downto 3);
  
begin
process(clk,rst)
begin
    --reset behaviour
    if rst = '1' then
        PC_addr_out  <= (others => '0');
        op_pass      <= (others => '0');
        op_code      <= (others => '0');
        instr_format <= (others => '0');
        reg1_addr    <= (others => '0');
        reg2_addr    <= (others => '0');
    end if;
   
     --if the clock is falling we latch
     --if the clock is rising we gate
    if(clk='1' and clk'event) then
        --falling edge store input and compute instr format
        
        if_id <= instr_in;
        pc_addr <= PC_addr_in;
        format <= get_instrformat(opcode); 
    
    elsif(clk='0' and clk'event) then
        --rising edge set output depending on format and opcode        
        case opcode is
        
        --A1
        when "0000001" =>  --ADD
            reg1_addr <= rb_addr_sig; 
            reg2_addr <= rc_addr_sig;
            op_pass <= "000000"&ra_addr_sig;        
        when "0000010" =>  --SUB
            reg1_addr <= rb_addr_sig; 
            reg2_addr <= rc_addr_sig;
            op_pass <=  "000000"&ra_addr_sig;        
        when "0000011" =>  --MUL
            reg1_addr <= rb_addr_sig; 
            reg2_addr <= rc_addr_sig;
            op_pass <= "000000"&ra_addr_sig;            
        when "0000100" =>  --NAND
            reg1_addr <= rb_addr_sig; 
            reg2_addr <= rc_addr_sig;
            op_pass <= "000000"&ra_addr_sig;
            
        --A2
        when "0000101" =>  --SHL
            reg1_addr <= ra_addr_sig; 
            reg2_addr <= default_reg; --Not needed here
            op_pass <= "00000"&c1_sig; --pass padded c1,
        when "0000110" => --SHR
            reg1_addr <= ra_addr_sig; 
            reg2_addr <= default_reg; --Not needed here
            op_pass <= "00000"&c1_sig; --pass padded c1,
            
        --A3
        when "0000111" =>  --TEST
            reg1_addr <= ra_addr_sig; 
            reg2_addr <= default_reg; --Not needed here
            op_pass <= (others => '0'); --Not needed here
        when "0100000" =>  --OUT
            reg1_addr <= ra_addr_sig; 
            reg2_addr <= default_reg; --Not needed here
            op_pass <= (others => '0'); --Not needed here
        when "0100001" =>  --IN
            reg1_addr <= ra_addr_sig; 
            reg2_addr <= default_reg; --Not needed here
            op_pass <= (others => '0'); --Not needed here
            
        --B1
        when "1000000" =>  --BRR
            reg1_addr <= default_reg; --Not needed here
            reg2_addr <= default_reg; --Not needed here
            op_pass <= disp1; --pass disp1
        when "1000001" =>  --BRR.N
            reg1_addr <= default_reg; --Not needed here
            reg2_addr <= default_reg; --Not needed here
            op_pass <= disp1; --pass disp1
        when "1000010" =>  --BRR.Z
            reg1_addr <= default_reg; --Not needed here
            reg2_addr <= default_reg; --Not needed here
            op_pass <= disp1; --pass disp1
                    
        --B2
        when "1000011" =>  --BR
            reg1_addr <= ra_addr_sig;
            reg2_addr <= default_reg; --Not needed here
            op_pass <= "000"&disps; --pass disp1 padded with zeros
        when "1000100" =>  --BR.N
            reg1_addr <= ra_addr_sig;
            reg2_addr <= default_reg; --Not needed here
            op_pass <= "000"&disps; --pass disp1 padded with zeros
        when "1000101" =>  --BR.Z
             reg1_addr <= ra_addr_sig;
            reg2_addr <= default_reg; --Not needed here
            op_pass <= "000"&disps; --pass disp1 padded with zeros
        when "1000111" =>  --BR.SUB
            reg1_addr <= ra_addr_sig;
            reg2_addr <= default_reg; --Not needed here
            op_pass <= "000"&disps; --pass disp1 padded with zeros
        
        --L1
        when "0010010" =>  --LOADIMM
            reg1_addr <= "111"; --Always using reg7 for LOADIMM
            reg2_addr <= default_reg;
            op_pass <= "0"&imm; --Pass along the imm value
        
        --L2
        when "0010000" =>  --LOAD
            reg1_addr <= rdest;
            reg1_addr <= rsrc;
            op_pass <= (others => '0');
        when "0010001" =>  --STORE
            reg1_addr <= rdest;
            reg1_addr <= rsrc;
            op_pass <= (others => '0');
        when "0010011" =>  --MOV
            reg1_addr <= rdest;
            reg1_addr <= rsrc;
            op_pass <= (others => '0');
        
        --Default to A0 (NOP,RETURN)
        when others => 
            reg1_addr <= "111"; --incase its a RETURN, get PC from r7
            reg2_addr <= "000";
            op_pass <= (others => '0');
        end case;
        
        
        op_code <= opcode; --to ALU
        instr_format <= format; --to ID/EX
        PC_addr_out <= pc_addr; --to ID/EX

     end if;
    end process;

end Behavioral;
