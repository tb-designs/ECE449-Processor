
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IF_ID is 
  port( instr_in     : in std_logic_vector (15 downto 0); --next instruction to latch
        PC_addr_in   : in std_logic_vector (15 downto 0);
        PC_addr_out  : out std_logic_vector (15 downto 0);
        op_pass      : out std_logic_vector (15 downto 0);  --Pass through operand (c1 OR ra OR disp1 OR disps OR imm)
        op_code      : out std_logic_vector (6 downto 0);
        instr_format : out std_logic_vector (2 downto 0);
        reg1_addr    : out std_logic_vector (2 downto 0); --To Reg File
        reg2_addr    : out std_logic_vector (2 downto 0); --To Reg File
        ra_addr_out  : out std_logic_vector (2 downto 0); --to ID/EX for forwarding
        mem_oper_out : out std_logic;
        wb_oper_out  : out std_logic;
        m1_out       : out std_logic;
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
        when "1000110" => format := "101"; --BR.SUB
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

--Type declaration for easier modification
type if_id is record
     --General
     pc_addr : std_logic_vector(15 downto 0);
     --A1,A3
     opcode  : std_logic_vector(6 downto 0);
     ra_addr : std_logic_vector (2 downto 0);
     rb_addr : std_logic_vector (2 downto 0);
     rc_addr : std_logic_vector (2 downto 0);
     --A2
     c1      : std_logic_vector (3 downto 0);
     --B1
     displ   : std_logic_vector (8 downto 0);
     --B2
     disps   : std_logic_vector (5 downto 0);
     --L1
     m1      : std_logic;
     imm     : std_logic_vector (7 downto 0);
     --L2
     rdest   : std_logic_vector (2 downto 0);
     rsrc    : std_logic_vector (2 downto 0);
end record if_id;

constant IF_ID_INIT : if_id := (
     pc_addr => (others => '0'),
     opcode  => (others => '0'),
     ra_addr => (others => '0'),
     rb_addr => (others => '0'),
     rc_addr => (others => '0'),
     --A2
     c1      => (others => '0'),
     --B1
     displ   => (others => '0'),
     --B2
     disps   => (others => '0'),
     --L1
     m1      => '0',
     imm     => (others => '0'),
     --L2
     rdest   => (others => '0'),
     rsrc    => (others => '0')
     );


--Signals
signal if_id_sig : if_id := IF_ID_INIT;
signal format    : std_logic_vector (2 downto 0)  := (others => '0');
  
begin
     --Decode Instruction
     if_id_sig.opcode  <= instr_in(15 downto 9);
     if_id_sig.ra_addr <= instr_in (8 downto 6);
     if_id_sig.rb_addr <= instr_in (5 downto 3);
     if_id_sig.rc_addr <= instr_in (2 downto 0);
     if_id_sig.c1    <= instr_in(3 downto 0);
     if_id_sig.displ <= instr_in(8 downto 0);
     if_id_sig.disps <= instr_in (5 downto 0);
     if_id_sig.m1    <= instr_in (8);
     if_id_sig.imm   <= instr_in(7 downto 0);
     if_id_sig.rdest <= instr_in(8 downto 6);
     if_id_sig.rsrc  <= instr_in(5 downto 3);
        
     if_id_sig.pc_addr <= PC_addr_in;
     format <= get_instrformat(instr_in(15 downto 9));
        
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
        ra_addr_out  <= (others => '0');
        mem_oper_out <= '0';
        wb_oper_out  <= '0';
        m1_out       <= '0';
   
     --if the clock is rising we gate
     --falling edge store input and compute instr format  
    elsif(clk='1' and clk'event) then
        --rising edge set output depending on format and opcode          
        case if_id_sig.opcode is
        --A1
        when "0000001" =>  --ADD
            reg1_addr <= if_id_sig.rb_addr; 
            reg2_addr <= if_id_sig.rc_addr;
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(unsigned(if_id_sig.ra_addr), 16));  
            mem_oper_out <= '0';
            wb_oper_out  <= '1';      
        when "0000010" =>  --SUB
            reg1_addr <= if_id_sig.rb_addr; 
            reg2_addr <= if_id_sig.rc_addr;
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(unsigned(if_id_sig.ra_addr), 16));
            mem_oper_out <= '0';
            wb_oper_out  <= '1';               
        when "0000011" =>  --MUL
            reg1_addr <= if_id_sig.rb_addr; 
            reg2_addr <= if_id_sig.rc_addr;
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(unsigned(if_id_sig.ra_addr), 16));
            mem_oper_out <= '0';
            wb_oper_out  <= '1';                   
        when "0000100" =>  --NAND
            reg1_addr <= if_id_sig.rb_addr; 
            reg2_addr <= if_id_sig.rc_addr;
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(unsigned(if_id_sig.ra_addr), 16));
            mem_oper_out <= '0';
            wb_oper_out  <= '1';       
            
        --A2
        when "0000101" =>  --SHL
            reg1_addr <= if_id_sig.ra_addr; 
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(unsigned(if_id_sig.c1), 16)); --pass padded c1,
            mem_oper_out <= '0';
            wb_oper_out  <= '1';  
        when "0000110" => --SHR
            reg1_addr <= if_id_sig.ra_addr; 
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(unsigned(if_id_sig.c1), 16)); --pass padded c1,
            mem_oper_out <= '0';
            wb_oper_out  <= '1'; 
            
        --A3
        when "0000111" =>  --TEST
            reg1_addr <= if_id_sig.ra_addr; 
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= (others => '0'); --Not needed here
            mem_oper_out <= '0';
            wb_oper_out  <= '0'; 

        when "0100000" =>  --OUT
            reg1_addr <= if_id_sig.ra_addr; 
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= X"FFF2"; --Not needed here
            mem_oper_out <= '0';
            wb_oper_out  <= '0';

        when "0100001" =>  --IN
            reg1_addr <= "000"; 
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= X"FFF0"; 
            mem_oper_out <= '1';
            wb_oper_out  <= '1';
            
        --B1
        when "1000000" =>  --BRR
            reg1_addr <= "000"; --Not needed here
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= "000"; --Not needed here
            op_pass <= std_logic_vector(resize(signed(if_id_sig.displ), 16)); --pass disp1
            mem_oper_out <= '0';
            wb_oper_out  <= '0';
            
        when "1000001" =>  --BRR.N
            reg1_addr <= "000"; --Not needed here
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(signed(if_id_sig.displ), 16)); --pass disp1
            mem_oper_out <= '0';
            wb_oper_out  <= '0';

        when "1000010" =>  --BRR.Z
            reg1_addr <= "000"; --Not needed here
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(signed(if_id_sig.displ), 16)); --pass disp1
            mem_oper_out <= '0';
            wb_oper_out  <= '0';
                    
        --B2
        when "1000011" =>  --BR
            reg1_addr <= if_id_sig.ra_addr;
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(signed(if_id_sig.disps), 16)); --pass disps padded with zeros
            mem_oper_out <= '0';
            wb_oper_out  <= '0';

        when "1000100" =>  --BR.N
            reg1_addr <= if_id_sig.ra_addr;
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(signed(if_id_sig.disps), 16)); --pass disps padded with zeros
            mem_oper_out <= '0';
            wb_oper_out  <= '0';

        when "1000101" =>  --BR.Z
            reg1_addr <= if_id_sig.ra_addr;
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(signed(if_id_sig.disps), 16)); --pass disp1 padded with zeros
            mem_oper_out <= '0';
            wb_oper_out  <= '0';

        when "1000110" =>  --BR.SUB
            reg1_addr <= if_id_sig.ra_addr;
            reg2_addr <= "000"; --Not needed here
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= std_logic_vector(resize(signed(if_id_sig.disps), 16)); --pass disp1 padded with zeros
            mem_oper_out <= '0';
            wb_oper_out  <= '0';
                    
        --L1
        when "0010010" =>  --LOADIMM
            reg1_addr <= "111";
            reg2_addr <= "000";
            ra_addr_out <= "111"; --Always using reg7 for LOADIMM
            op_pass <= std_logic_vector(resize(signed(if_id_sig.imm), 16));
            mem_oper_out <= '0';
            wb_oper_out  <= '1';        
 
        --L2
        when "0010000" =>  --LOAD
            reg1_addr <= if_id_sig.rsrc; --get memory address for load
            reg2_addr <= "000"; --unused
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= (others => '0');
            mem_oper_out <= '1';
            wb_oper_out  <= '1';
 
        when "0010001" =>  --STORE
            reg1_addr <= if_id_sig.rdest; --get memory address to store to
            reg2_addr <= if_id_sig.rsrc; --data to store
            ra_addr_out <= (others => '0'); --unused
            op_pass <= (others => '0');
            mem_oper_out <= '1';
            wb_oper_out  <= '0';

        when "0010011" =>  --MOV
            reg1_addr <= if_id_sig.rsrc;
            reg2_addr <= "000"; --unused
            ra_addr_out <= if_id_sig.ra_addr;
            op_pass <= (others => '0');
            mem_oper_out <= '0';
            wb_oper_out  <= '1';
        
        --A0
        when "1000111" => --RETURN
            reg1_addr <= "111"; -- get PC from r7
            reg2_addr <= "000";
            ra_addr_out <= "111";
            op_pass <= (others => '0');
            mem_oper_out <= '0';
            wb_oper_out  <= '0';
            
        when others => --Default to NOP  
            reg1_addr <= "000";
            reg2_addr <= "000";
            ra_addr_out <= "000";
            op_pass <= (others => '0');
            mem_oper_out <= '0';
            wb_oper_out  <= '0';          
        end case;
        
        op_code <= if_id_sig.opcode; --to ALU
        instr_format <= format; --to ID/EX
        PC_addr_out <= if_id_sig.pc_addr; --to ID/EX
        m1_out <= if_id_sig.m1;
        

    end if;
end process;

end Behavioral;
