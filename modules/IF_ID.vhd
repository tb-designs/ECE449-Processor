library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IF_ID is 
  port( instr_in : in std_logic_vector (15 downto 0); --next instruction to latch
        opCode : out std_logic_vector (6 downto 0);
        ra_addr : out std_logic_vector (2 downto 0); -- or r_dest
        rb_addr : out std_logic_vector (2 downto 0); -- or r_source
        rc_addr : out std_logic_vector (2 downto 0);
        instr_out : out std_logic_vector (15 downto 0); --pass along the current instruction
      );
end IF_ID;

architecture Behavioral of IF_ID is

  --Instruction format depends on opcode
  --A Format (Due Feb 26th)
    --0,NOP = A0      (A0 = 000)
    --1,ADD = A1      (A1 = 001)
    --2,SUB = A1
    --3,MUL = A1
    --4,NAND = A1
    --5,SHL = A2      (A2 = 010)
    --6,SHL = A2
    --7,TEST = A3     (A3 = 011)
    --32,OUT = A3
    --33,IN = A3

    --Variables
    variable format : std_logic_vector (2 downto 0);
    
    process(clk)
   begin
     
      --if the clock is falling we latch?
     --if the clock is rising we gate?
     
      --Format decision (probably should do this in the controller)
     case instr(15 downto 9) is
        --A Format Instr
        when "0000000" => format := "000"
        when "0000001" => format := "001"
        when "0000010" => format := "001"
        when "0000011" => format := "001"
        when "0000100" => format := "001"
        when "0000101" => format := "010"
        when "0000110" => format := "010"
        when "0000111" => format := "011"
        when "0100000" => format := "011"
        when "0100001" => format := "011"
        --B Format Instr
     
        --L Format Instr
     
 

  end Behavioral;