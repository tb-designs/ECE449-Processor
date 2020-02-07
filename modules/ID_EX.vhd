library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ID_EX is 
  port(instr : in std_logic_vector (15 downto 0);
  opCode : out std_logic_vector (6 downto 0);
  ra_addr : out std_logic_vector (2 downto 0); -- or r_dest
  rb_addr : out std_logic_vector (2 downto 0); -- or r_source
  rc_addr : out std_logic_vector (2 downto 0);
  c1 : out std_logic_vector (3 downto 0);
  disp1 : out std_logic_vector (8 downto 0);
  disps : out std_logic_vector (5 downto 0);
  m1 : out std_logic);

end ID_EX;

architecture Behavioral of ID_EX is

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

  --B Format (Due TBA)
    --64,BRR = B1      (B1 = 100)
    --65,BRR.N = B1
    --66,BRR.Z = B1
    --67,BR = B2       (B2 = 101)
    --68,BR.N = B2
    --69,BR.Z = B2
    --70,BR.SUB = B2
    --71,RETURN = A0
  
  --L Format (Due TBA)
    --16,LOAD = L2     (L2 = 111)
    --17,STORE = L2
    --18,LOADIMM = L1  (L1 = 110)
    --19,MOV = L2

    begin
      --Variables
      variable format : std_logic_vector (2 downto 0);
    
      process(clk)
      begin
    
        --if the clock is falling we latch
        --if the clock is rising we gate??
        --Should this be handled by the controller? If so need to add latch_en and Gate-en inputs
    
        --Format decision
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