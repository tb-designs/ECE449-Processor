library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ID_EX is 
  port(data_1        : in std_logic_vector (15 downto 0);
       data_2        : in std_logic_vector (15 downto 0);
       v_flag_1      : in std_logic;
       operand_3     : in std_logic_vector (15 downto 0);
       opcode_in     : in std_logic_vector (6 downto 0);
       instr_form_in : in std_logic_vector (2 downto 0);
       reg1_addr_in  : in std_logic_vector (2 downto 0);
       reg2_addr_in  : in std_logic_vector (2 downto 0);
       ra_addr_in    : in std_logic_vector (2 downto 0);
       PC_addr_in    : in std_logic_vector (15 downto 0);
       mem_oper_in   : in std_logic;
       wb_oper_in    : in std_logic;
       m1_in         : in std_logic;
       mem_stall     : in std_logic;
       clk, rst      : in std_logic;
       operand1      : out std_logic_vector (15 downto 0);
       operand2      : out std_logic_vector (15 downto 0);
       opcode_out    : out std_logic_vector (6 downto 0);
       alu_mode_out  : out std_logic_vector (2 downto 0);
       instr_form_out: out std_logic_vector (2 downto 0);
       reg1_addr_out : out std_logic_vector (2 downto 0);
       reg2_addr_out : out std_logic_vector (2 downto 0);
       PC_addr_out   : out std_logic_vector (15 downto 0);
       data_pass_out : out std_logic_vector (15 downto 0);
       ra_addr_out   : out std_logic_vector (2 downto 0);
       mem_oper_out  : out std_logic;
       wb_oper_out   : out std_logic;
       m1_out        : out std_logic;
       v_flag_1_out  : out std_logic
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
        when "0100000" => mode := "001"; --OUT
        --B1
        when "1000000" => mode := "001"; --BRR
        when "1000001" => mode := "001"; --BRR.N
        when "1000010" => mode := "001"; --BRR.Z
        --B2
        when "1000011" => mode := "001"; --BR
        when "1000100" => mode := "001"; --BR.N
        when "1000101" => mode := "001"; --BR.Z
        when "1000110" => mode := "001"; --BR.SUB
        --L1
        when "0010010" => mode := "001";--LOADIMM       
        --L2
        when "0010000" => mode := "001";--LOAD
        when "0010001" => mode := "001";--STORE
        when "0010011" => mode := "001";--MOV
        
        --A0
        when "1000111" => mode := "001"; --RETURN (used to add 0 in alu, result is then placed in PC in ex/mem)
        --Default to NOP
        when others => mode := "000"; --IN
        end case; 

    return mode;
end function getalumode;

--Type for easier modification
type id_ex is record
    reg1_data  : std_logic_vector(15 downto 0);
    reg2_data  : std_logic_vector(15 downto 0);
    reg1_vflag : std_logic;
    op3        : std_logic_vector (15 downto 0);
    alu_mode   : std_logic_vector (2 downto 0);
    ra_addr    : std_logic_vector (2 downto 0);
    r1_addr    : std_logic_vector (2 downto 0);
    r2_addr    : std_logic_vector (2 downto 0);
    opcode     : std_logic_vector (6 downto 0);
    instr_form : std_logic_vector (2 downto 0);
    pc_addr    : std_logic_vector (15 downto 0);
    mem_opr    : std_logic;
    wb_opr     : std_logic;
    m1         : std_logic;
end record id_ex;

--Specify init value for the type
constant ID_EX_INIT : id_ex := (
    reg1_data => (others => '0'),
    reg2_data => (others => '0'),
    reg1_vflag => '0',
    op3 => (others => '0'),
    alu_mode => (others => '0'),
    ra_addr => (others => '0'),
    r1_addr => (others => '0'),
    r2_addr => (others => '0'),
    opcode => (others => '0'),
    instr_form => (others => '0'),
    pc_addr => (others => '0'),
    mem_opr => '0',
    wb_opr => '0',
    m1 => '0'
    );

--Signal
signal id_ex_sig : id_ex := ID_EX_INIT;
    
begin

    id_ex_sig.r1_addr <= reg1_addr_in;
    id_ex_sig.r2_addr <= reg2_addr_in;
    id_ex_sig.reg1_data <= data_1;
    id_ex_sig.reg2_data <= data_2;
    id_ex_sig.reg1_vflag <= v_flag_1;
    id_ex_sig.op3 <= operand_3;
    id_ex_sig.alu_mode <= getalumode(opcode_in);
    id_ex_sig.opcode <= opcode_in;
    id_ex_sig.instr_form <= instr_form_in;
    id_ex_sig.pc_addr <= pc_addr_in;
    id_ex_sig.mem_opr <= mem_oper_in;
    id_ex_sig.wb_opr <= wb_oper_in;
    id_ex_sig.ra_addr <= ra_addr_in;
    id_ex_sig.m1 <= m1_in;

    process(clk,rst)
    begin
        --reset behaviour
        if rst = '1' or (clk = '1' and clk'event and mem_stall = '1') then
            operand1 <= (others => '0');
            operand2 <= (others => '0');
            opcode_out <= (others => '0');
            PC_addr_out <= (others => '0');
            instr_form_out <= (others => '0');
            data_pass_out <= (others => '0');
            alu_mode_out <= (others => '0');
            ra_addr_out <= (others => '0');
            mem_oper_out <= '0';
            wb_oper_out <= '0';
            m1_out <= '0';
            v_flag_1_out <= '0';
              
        elsif(clk='1' and clk'event) then
       --rising edge set output depending on the instruction format

        alu_mode_out <= id_ex_sig.alu_mode;
        mem_oper_out <= id_ex_sig.mem_opr;
        wb_oper_out <= id_ex_sig.wb_opr;
        PC_addr_out <= id_ex_sig.pc_addr;
        instr_form_out <= id_ex_sig.instr_form;
        opcode_out <= id_ex_sig.opcode;
        m1_out <= id_ex_sig.m1; --passthrough m1 for LOADIMM
        reg1_addr_out <= id_ex_sig.r1_addr;
        reg2_addr_out <= id_ex_sig.r2_addr;
  
        --Need to decide what operands to give the ALU
        case id_ex_sig.instr_form is                
            when "000" =>
                --A0, need made explicit for RETURN
                operand1 <= id_ex_sig.reg1_data; --r7 data
                operand2 <= (others => '0'); --add with 0
                ra_addr_out <= (others => '0');
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
                operand2 <= id_ex_sig.op3(14 downto 0)&"0"; -- 2*disp.l = shl(disp.l)
                ra_addr_out <= (others => '0');
            when "101" =>
                --B2
                operand1 <= id_ex_sig.reg1_data; --ra data
                operand2 <= id_ex_sig.op3(14 downto 0)&"0"; --2*disp.s = shl(disp.s)
                ra_addr_out <= (others => '0');
            when "110" =>
                --L1
                operand1 <= id_ex_sig.reg1_data; -- pass r7 data through alu (add 0) for load immediate
                operand2 <= (others => '0');
                ra_addr_out <= id_ex_sig.ra_addr; --ra address
            when "111" =>
                --L2
                --pass data from reg1 through alu (add 0)
                --reg1 is wb data for MOV and mem data for STORE
                operand1 <= id_ex_sig.reg1_data;
                operand2 <= (others => '0');
                ra_addr_out <= id_ex_sig.ra_addr; --ra address
            when others =>
                operand1 <= (others => '0'); --Dont Care
                operand2 <= (others => '0'); --Dont Care
                ra_addr_out <= (others => '0');
        end case;

        --Set dest and src mem outputs
        case id_ex_sig.opcode is
        when "0000111" =>
        --TEST
        data_pass_out <= (others => '0');
        v_flag_1_out <= id_ex_sig.reg1_vflag;
        
        when "0100000" =>
        --OUT
        --out port mapped to X"FFF2"
        data_pass_out <= id_ex_sig.op3; --Address of OUT port
        
        when "0100001" =>
        --IN
        --in port mapped to X"FFF0"
        data_pass_out <= id_ex_sig.op3; --Address of IN port
        
        when "0010010" =>
        --LOADIMM
        data_pass_out <= id_ex_sig.op3; --immediate
        
        when "0010000" =>
        --LOAD
        data_pass_out <= id_ex_sig.reg2_data; --mem address
        
        when "0010001" =>
        --STORE
        data_pass_out <= id_ex_sig.reg2_data; --mem address
        
        when others =>
        data_pass_out <= (others => '0');
        
        end case;
        
        --pass overflow flag of reg1 to status reg if TEST
        if id_ex_sig.opcode = "0000111" then
            v_flag_1_out <= id_ex_sig.reg1_vflag;
        else
            v_flag_1_out <= '0';
        end if;
        
    end if;
end process;
end Behavioral;
