library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ID_EX is 
  port(data_1        : in std_logic_vector (15 downto 0);
       data_2        : in std_logic_vector (15 downto 0);
       operand_3     : in std_logic_vector (15 downto 0);
       opcode_in     : in std_logic_vector (6 downto 0);
       instr_form_in : in std_logic_vector (2 downto 0);
       ra_addr_in    : in std_logic_vector (2 downto 0);
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
       ra_addr_out   : out std_logic_vector (2 downto 0);
       mem_oper_out  : out std_logic;
       wb_oper_out   : out std_logic
       );

end ID_EX;

architecture Behavioral of ID_EX is

--ALU mode decoding function
function getalumode(op : std_logic_vector(6 downto 0)) return std_logic_vector is
    variable mode : std_logic_vector(2 downto 0) := (others => '0');
    begin
        case op is
        --A1
        when "0000001" => mode := "001"; --ADD
        when "0000010" => mode := "010"; --SUB
        when "0000011" => mode := "011"; --MUL
        when "0000100" => mode := "100"; --NAND
        --A2
        when "0000101" => mode := "101"; --SHL
        when "0000110" => mode := "110"; --SHR
        --A3
        when "0000111" => mode := "111"; --TEST
        --B1
        when "1000000" => mode := "001"; --BRR
        when "1000001" => mode := "001"; --BRR.N
        when "1000010" => mode := "001"; --BRR.Z
        --B2
        when "1000011" => mode := "001"; --BR
        when "1000100" => mode := "001"; --BR.N
        when "1000101" => mode := "001"; --BR.Z
        when "1000111" => mode := "001"; --BR.SUB
        --Default to NOP
        when others => mode := "000";
        end case; 

    return mode;
end function getalumode;

--Type for easier modification
type id_ex is record
    reg1_data  : std_logic_vector(15 downto 0);
    reg2_data  : std_logic_vector(15 downto 0);
    op3        : std_logic_vector (15 downto 0);
    alu_mode   : std_logic_vector (2 downto 0);
    ra_addr    : std_logic_vector (2 downto 0);
    opcode     : std_logic_vector (6 downto 0);
    instr_form : std_logic_vector (2 downto 0);
    pc_addr    : std_logic_vector (15 downto 0);
    mem_opr    : std_logic;
    wb_opr    : std_logic;
end record id_ex;

--Specify init value for the type
constant ID_EX_INIT : id_ex := (
    reg1_data => (others => '0'),
    reg2_data => (others => '0'),
    op3 => (others => '0'),
    alu_mode => (others => '0'),
    ra_addr => (others => '0'),
    opcode => (others => '0'),
    instr_form => (others => '0'),
    pc_addr => (others => '0'),
    mem_opr => '0',
    wb_opr => '0'
    );

--Signal
signal id_ex_sig : id_ex := ID_EX_INIT;
    
begin
    process(clk,rst)
    begin
        --reset behaviour
        if rst = '1' then
            operand1 <= (others => '0');
            operand2 <= (others => '0');
            alu_mode_out <= (others => '0');
            dest_mem_data <= (others => '0');
            src_mem_data <= (others => '0');
            alu_mode_out <= (others => '0');
            ra_addr_out <= (others => '0');
            mem_oper_out <= '0';
            wb_oper_out <= '0';
        end if;

        --falling edge store the input in the register
        -- also compute the alu_mode
        id_ex_sig.reg1_data <= data_1;
        id_ex_sig.reg2_data <= data_2;
        id_ex_sig.op3 <= operand_3;
        id_ex_sig.alu_mode <= getalumode(opcode_in); --produce alu_mode
        id_ex_sig.opcode <= opcode_in;
        id_ex_sig.instr_form <= instr_form_in;
        id_ex_sig.pc_addr <= pc_addr_in;
        id_ex_sig.mem_opr <= mem_oper_in;
        id_ex_sig.wb_opr <= wb_oper_in;
        id_ex_sig.ra_addr <= ra_addr_in;
              
        if(clk='1' and clk'event) then
        --reset behaviour    

       --rising edge set output depending on the instruction format

        alu_mode_out <= id_ex_sig.alu_mode;
        mem_oper_out <= id_ex_sig.mem_opr;
        wb_oper_out <= id_ex_sig.wb_opr;
        PC_addr_out <= id_ex_sig.pc_addr;
        instr_form_out <= id_ex_sig.instr_form;
        opcode_out <= id_ex_sig.opcode;
  
        --Need to decide what operands to give the ALU
        case id_ex_sig.instr_form is
            when "001" =>
                --A1
                operand1 <= id_ex_sig.reg1_data; --rb data
                operand2 <= id_ex_sig.reg2_data; --rc data
                ra_addr_out <= id_ex_sig.op3(2 downto 0); --ra address
            when "010" =>
                --A2
                operand1 <= id_ex_sig.reg1_data; --ra data
                operand2 <= id_ex_sig.op3; --c1
                ra_addr_out <= id_ex_sig.ra_addr;
            when "011" =>
                --A3
                operand1 <= id_ex_sig.reg1_data; --ra data
                operand2 <= (others => '0'); --Dont care
                ra_addr_out <= id_ex_sig.ra_addr; --ra address
            when "100" =>
                --B1
                operand1 <= id_ex_sig.pc_addr; --PC address
                operand2 <= id_ex_sig.op3; --disp.l

            when "101" =>
                --B2
                operand1 <= id_ex_sig.reg1_data; --ra data
                operand2 <= id_ex_sig.op3; --disp.s

            when others =>
                --A0,L1, and L2 skip this stage so treat like a NOP   
                operand1 <= (others => '0'); --Dont Care
                operand2 <= (others => '0'); --Dont Care
        end case;

        --Set dest and src mem outputs
        case id_ex_sig.opcode is
        when "0100000" =>
        --OUT
        --out port mapped to X"FFF2"
        dest_mem_data <= id_ex_sig.op3; --Address of OUT port
        src_mem_data <= id_ex_sig.reg1_data; --Data to send out
        
        when "0100001" =>
        --IN
        --in port mapped to X"FFF0"
        dest_mem_data <= id_ex_sig.op3; --Address of IN port
        src_mem_data <= (others => '0');       
        
        when "0010000" =>
        --LOAD
            dest_mem_data <= id_ex_sig.reg1_data;
            src_mem_data <= id_ex_sig.reg2_data;
        
        when "0010001" =>
        --STORE
            dest_mem_data <= id_ex_sig.reg1_data;
            src_mem_data <= id_ex_sig.reg2_data;
        
        when others =>
            dest_mem_data <= (others => '0');
            src_mem_data <=  (others => '0');
        
        end case;
    

        if id_ex_sig.instr_form = "110" then
            --For load, pass along the register data as-is
            dest_mem_data <= id_ex_sig.reg1_data;
            src_mem_data <= id_ex_sig.reg2_data;
        elsif id_ex_sig.instr_form = "111" then
            --For store, pass along the register data as-is
            dest_mem_data <= id_ex_sig.reg1_data;
            src_mem_data <= id_ex_sig.reg2_data;
        end if;

        
    end if;

    end process;
  
  end Behavioral;