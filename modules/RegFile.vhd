library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity register_file is
port(
rst : in std_logic;
clk: in std_logic;
--read signals
rd_index1: in std_logic_vector(2 downto 0); 
rd_index2: in std_logic_vector(2 downto 0); 
rd_data1: out std_logic_vector(15 downto 0); 
rd_data2: out std_logic_vector(15 downto 0);
rd_vflag1: out std_logic;
--write signals
wr_index: in std_logic_vector(2 downto 0); 
wr_data: in std_logic_vector(15 downto 0);
wr_enable: in std_logic;
v_flag: in std_logic
);
end register_file;

architecture behavioural of register_file is

type reg_t is record
    data   : std_logic_vector(15 downto 0);
    v_flag : std_logic;
end record reg_t;

type reg_array is array (integer range 0 to 7) of reg_t;
--internals signals
signal reg_file : reg_array;

begin
--write operation 
process(clk)
begin
  if(clk='0' and clk'event) then
    if (rst='1') then
       for i in 0 to 7 loop
          reg_file(i).data <= (others => '0');
          reg_file(i).v_flag <= '0';
       end loop;
    elsif(wr_enable = '1') then
       case wr_index(2 downto 0) is
       when "000" => reg_file(0).data <= wr_data;
                     reg_file(0).v_flag <= v_flag;
       when "001" => reg_file(1).data <= wr_data;
                     reg_file(1).v_flag <= v_flag;
       when "010" => reg_file(2).data <= wr_data;
                     reg_file(2).v_flag <= v_flag;
       when "011" => reg_file(3).data <= wr_data;
                     reg_file(3).v_flag <= v_flag;
       when "100" => reg_file(4).data <= wr_data;
                     reg_file(4).v_flag <= v_flag;
       when "101" => reg_file(5).data <= wr_data;
                     reg_file(5).v_flag <= v_flag;
       when "110" => reg_file(6).data <= wr_data;
                     reg_file(6).v_flag <= v_flag;
       when "111" => reg_file(7).data <= wr_data;
                     reg_file(7).v_flag <= v_flag;
       when others => NULL;
       end case;
    end if; 
   end if;
end process;

--read operation
rd_data1 <=	
reg_file(0).data when(rd_index1="000") else
reg_file(1).data when(rd_index1="001") else
reg_file(2).data when(rd_index1="010") else
reg_file(3).data when(rd_index1="011") else
reg_file(4).data when(rd_index1="100") else
reg_file(5).data when(rd_index1="101") else
reg_file(6).data when(rd_index1="110") else
reg_file(7).data;

rd_data2 <=
reg_file(0).data when(rd_index2="000") else
reg_file(1).data when(rd_index2="001") else
reg_file(2).data when(rd_index2="010") else
reg_file(3).data when(rd_index2="011") else
reg_file(4).data when(rd_index2="100") else
reg_file(5).data when(rd_index2="101") else
reg_file(6).data when(rd_index2="110") else
reg_file(7).data;

rd_vflag1 <=
reg_file(0).v_flag when(rd_index1="000") else
reg_file(1).v_flag when(rd_index1="001") else
reg_file(2).v_flag when(rd_index1="010") else
reg_file(3).v_flag when(rd_index1="011") else
reg_file(4).v_flag when(rd_index1="100") else
reg_file(5).v_flag when(rd_index1="101") else
reg_file(6).v_flag when(rd_index1="110") else
reg_file(7).v_flag;

end behavioural;