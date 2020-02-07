----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/05/2020 04:14:55 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( in_1 : in STD_LOGIC_VECTOR (15 downto 0);
           in_2 : in STD_LOGIC_VECTOR (15 downto 0);
           alu_mode : in STD_LOGIC_VECTOR (2 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           result : out STD_LOGIC_VECTOR (15 downto 0);
           z_flag : out STD_LOGIC;
           n_flag : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

--Functions

--to_int, used to determine amount of shift needed
function to_int(sig : std_logic_vector) return integer is
    variable num : integer := 0;
begin
    for i in sig'range loop
        if sig(i) = '1' then
            num := num*2+1;
        else
            num := num*2;
        end if;
    end loop;
    return num;
end function to_int;

begin
process(clk)

--Variables
variable result_buf: std_logic_vector(31 downto 0);
variable shift_amount: integer;

begin
--Reset Behaviour
   if(clk='0' and clk'event) then if(rst='1') then
      result <= (others => '0'); 
      z_flag <= '0'; 
      n_flag <= '0'; 
   else
         case alu_mode(2 downto 0) is
         --NOP
         when "000" => NULL;
         --ADD
         when "001" => 
            result_buf := in_1 + in_2;
            
            --Overflow Detection
            if (result_buf(16) = '1') then
                z_flag <= '1'; 
                n_flag <= '1';
            end if;
            result <= result_buf(15 downto 0);
            
         --SUB
         when "010" =>
            result_buf := in_1 - in_2;
            result <= result_buf(15 downto 0);
         
         --MUL
         when "011" =>
            result_buf := in_1*in_2;
            
            --Temp solution
            if (result_buf(16) = '1') then
                z_flag <= '1'; 
                n_flag <= '1';
            end if;
            result <= result_buf(15 downto 0);
            
         --NAND
         when "100" =>
            result <= in_1 NAND in_2;
            
         --SHL
         when "101" =>
            shift_amount := to_int(in_2);
            result_buf := in_1( 15 - shift_amount downto 0) & ((shift_amount-1) downto 0 => '0');
            result <= result_buf(15 downto 0);
         
         --SHR
         when "110" => 
            shift_amount := to_int(in_2);
            result_buf := ((shift_amount-1) downto 0 => '0') & in_1(15 downto shift_amount);
            result <= result_buf(15 downto 0);          
         
         --TEST
         when "111" => 
            result_buf := in_1;
            if (result_buf(15 downto 0) < ((others => '0'))) then 
                n_flag <= '1';
            elsif(result_buf(15 downto 0) = (others => '0')) then
                z_flag <= '1';
            end if;
            end if;                   
         when others => NULL; end case;
     end if;
end process;
end Behavioral;










