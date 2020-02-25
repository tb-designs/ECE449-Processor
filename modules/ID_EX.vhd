library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ID_EX is 
  port(instr_in      : in std_logic_vector (15 downto 0);
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

end ID_EX;

architecture Behavioral of ID_EX is

    --Signal
    signal id_ex : std_logic_vector (62 downto 0) := (others => '0');
    
    --Alias
    alias instr     is id_ex(62 downto 47);
    alias reg_data1 is id_ex(46 downto 31);
    alias reg_data2 is id_ex(30 downto 15);
    alias c1        is id_ex(14 downto 11);
    alias alu_mode  is id_ex(10 downto 8);
    alias instr_form is id_ex(7 downto 5);
    alias ra_addr   is id_ex(4 downto 2);
    alias mem_opr   is id_ex(1);
    alias wb_opr    is id_ex(0);
    
    
    begin
    process(clk)

    if(clk='0' and clk'event) then
       --rising edge set output
        instr_out <= instr
        alu_mode_out <= alu_mode;
        ra_addr_out <= ra_addr;
        mem_opr_out <= mem_opr;
        wb_opr_out <= wb_opr;
  
        --Need to decide what operands to give the ALU
        case when instr_form is 
            when "010" =>
                --Format A2
                operand1 <= reg_data1;
                operand2 <= zeros(11 downto 0)&c1; --c1 padded with zeros?
            when others =>
                --For now do same as A0,A1,A3 (Feb 24)        
                operand1 <= reg_data1;
                operand2 <= reg_data2;
        end case
        
    elsif(clk='1' and clk'event) then
      --falling edge store the input in the register
          id_ex <= instr_in&
             reg_data_1&
             reg_data_2&
             c1_in&
             alu_mode_in&
             instr_form_in&
             ra_addr_in&
             mem_oper_in&
             wb_oper_in;
    end if
    end if
  
  
  end Behavioral;