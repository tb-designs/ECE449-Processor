library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ID_EX is 
  port(data_1        : in std_logic_vector (15 downto 0);
       data_2        : in std_logic_vector (15 downto 0);
       operand_3     : in std_logic_vector (8 downto 0);
       alu_mode_in   : in std_logic_vector (2 downto 0);
       opcode_in     : in std_logic_vector (6 downto 0)
       instr_form_in : in std_logic_vector (2 downto 0);
       PC_addr_in    : in std_logic_vector (15 downto 0);
       mem_oper_in   : in std_logic;
       wb_oper_in    : in std_logic;
       clk, rst      : in std_logic;
       operand1      : out std_logic_vector (15 downto 0);
       operand2      : out std_logic_vector (15 downto 0);
       opcode_out    : out std_logic_vector (6 downto 0);
       alu_mode_out  : out std_logic_vector (2 downto 0);
       instr_form_out: out std_logic_vector (2 downto 0);
       PC_addr_out   : out std_logic_vector (15 downto 0);
       dest_mem_data : out std_logic_vector (15 downto 0);
       src_mem_data  : out std_logic_vector (15 downto 0);
       alu_mode_out  : out std_logic_vector (2 downto 0);
       ra_addr_out   : out std_logic_vector (2 downto 0);
       mem_oper_out  : out std_logic;
       wb_oper_out   : out std_logic
       );

end ID_EX;

architecture Behavioral of ID_EX is

    --Signal
    signal id_ex : std_logic_vector (71 downto 0) := (others => '0');
    
    --Alias
    alias reg1_data  is id_ex(71 downto 56);
    alias reg2_data  is id_ex(55 downto 40);
    alias operand3   is id_ex(49 downto 31); --Size 0f 9, needs to be 16 when passed to ALU
    alias alu_mode   is id_ex(30 downto 28);
    alias opcode     is id_ex(27 downto 21)
    alias instr_form is id_ex(20 downto 18);
    alias PC_addr    is id_ex(17 downto 2);
    alias mem_opr    is id_ex(1);
    alias wb_opr     is id_ex(0);

    
    begin
    process(clk,rst)
    begin

        --reset behaviour
        if rst = '1' then
            operand1 <= (others => '0');
            operand2 <= (others => '0');
            alu_mode_out <= (others => '0');
            dest_mem_addr <= (others => '0');
            src_mem_addr <= (others => '0');
            alu_mode_out <= (others => '0');
            ra_addr_out <= (others => '0');
            mem_oper_out <= (others => '0');
            wb_oper_out <= (others => '0');
        end if;
    


        if(clk='0' and clk'event) then
       --rising edge set output depending on the instruction format

        alu_mode_out <= alu_mode;
        ra_addr_out <= ra_addr;
        mem_opr_out <= mem_opr;
        wb_opr_out <= wb_opr;
        PC_addr_our <= PC_addr;
        instr_form_out <= instr_form;
        opcode_out <= opcode;
  
        --Need to decide what operands to give the ALU
        case when instr_form is
            when "001" =>
                --A1
                operand1 <= reg_data1; --rb data
                operand2 <= reg_data2; --rc data
                ra_addr_out <= operand3(2 downto 0) --ra address
            when "010" =>
                --A2
                operand1 <= reg_data1; --ra data
                operand2 <= zeros(6 downto 0)&operand3 --c1
            when "011" =>
                --A3
                operand1 <= reg_data1; --ra data
                operand2 <= zeros(15 downto 0); --Dont care

            when "100" =>
                --B1
                operand1 <= PC_addr; --PC address
                operand2 <= zeros(6 downto 0)&operand3 --disp.l

            when "101" =>
                --B2
                operand1 <= reg_data1; --ra data
                operand2 <= zeros(6 downto 0)&operand3; --disp.s

            when others =>
                --A0,L1, and L2 skip this stage so treat like a NOP   
                operand1 <= zeros(15 downto 0); --Dont Care
                operand2 <= zeros(15 downto 0); --Dont Care
        end case

        if instr_form is "110" or "111" then
            --For load/store, pass along the register data as-is
            dest_mem_data <= reg_data1;
            src_mem_data <= reg_data2;
        else
            -- for all other formats we don't care
            dest_mem_addr <= zeros(15 downto 0);
            src_mem_addr <=  zeros(15 downto 0);
        end if;

        
    elsif(clk='1' and clk'event) then
      --falling edge store the input in the register
          id_ex <= data_1&
             data_2&
             operand_3&
             alu_mode_in&
             opcode_in&
             instr_form_in&
             PC_addr_in&
             mem_oper_in&
             wb_oper_in;
    end if
    end process
  
  end Behavioral;