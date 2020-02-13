library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ID_EX is 
  port(instr : in std_logic_vector (15 downto 0);
       reg_data_1 : in std_logic_vector (15 downto 0);
       reg_data_2 : in std_logic_vector (15 downto 0);
       alu_mode   : in std_logic_vector (2 downto 0);
       mem_oper   : in std_logic;
       wb_oper    : in std_logic;
       operand1   : out std_logic_vector (15 downto 0);
       operand2   : out std_logic_vector (15 downto 0);
       instr_out : out std_logic_vector (15 downto 0));
       alu_mode_out : out std_logic_vector (2 downto 0);
       mem_oper_out : out std_logic;
       wb_oper_out  : out std_logic;
       );

end ID_EX;

architecture Behavioral of ID_EX is

    --Signals(acting as our register)
    signal id_ix : std_logic_vector (52 downto 0) := (others => '0');
    
    begin
    process(clk)
    if(clk='0' and clk'event) then
       --rising edge set output
        instr_out <= id_ix(52 downto 37); --pass along the instruction
        operand1 <= id_ix (36 downto 21);
        operand2 <= id_ix(20 downto 5);
        alu_mode_out <= id_ix(4 downto 2);
        mem_oper_out <= id_ix(1)
        wb_oper_out <= id_ix(0);
        
    elsif(clk='1' and clk'event) then
      --falling edge store the input in the register
          id_ex <= instr & 
               reg_data_1 &
               reg_data_2 &
               alu_mode &
               mem_oper &
               wb_oper;
    end if
    end if
  
  
  end Behavioral;