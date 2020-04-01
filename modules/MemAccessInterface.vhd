library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

--Wrapper around Xilinx RAM and ROM modules

entity mem_interface is
port (addr1,addr2 : in std_logic_vector (15 downto 0); -- addr1 is r/w, addr2 is r only
      wr_data : in std_logic_vector(15 downto 0);
      clk,rst : in std_logic;
      wr_en : in std_logic_vector(1 downto 0);
  	  r1_data,r2_data : out std_logic_vector(15 downto 0);
  	  err : out std_logic;
  	  in_port : in std_logic_vector(15 downto 0);
  	  out_port : out std_logic_vector(15 downto 0));
end mem_interface;

architecture behavioral of mem_interface is

constant addr_mask : std_logic_vector(15 downto 0) := X"03FF";

-- RAM signals
signal ram_douta,ram_doutb : std_logic_vector(15 downto 0); -- Data output for port A,B read operations
signal ram_addra,ram_addrb : std_logic_vector(15 downto 0); -- Address for port A,B write and read operations
signal ram_dina : std_logic_vector(15 downto 0); -- Data input for port A write operations

-- ROM signals
signal rom_douta : std_logic_vector(15 downto 0); -- Data output for port A read operations
signal rom_addra : std_logic_vector(15 downto 0); -- Address for port A read operations

-- Processor ports
signal in_reg : std_logic_vector(15 downto 0) := (others => '0');
signal out_reg : std_logic_vector(15 downto 0) := (others => '0');

begin	
--choice of output depends on memory address (mem mapped)
--ROM: 0x0000 to 0x03FF
--RAM: 0x0400 to 0x07FF
--InputPort:  0xFFF0
--OutputPort: 0xFFF2

r1_data <= ram_douta when addr1 >= X"0400" and addr1 <= X"07FF" else
           in_reg when addr1 = X"FFF0" else
           (others => '0');
r2_data <= ram_doutb when rst = '1' or (addr2 >= X"0400" and addr2 <= X"07FF") else
           rom_douta when addr2 >= X"0000" and addr2 <= X"03FF" else
           in_reg when addr2 = X"FFF0" else
           (others => '0');
        
ram_dina <= wr_data;

ram_addra <= (addr1 and addr_mask) when rst = '0' and addr1 >= X"0400" and addr1 <= X"07FF" else
             (others => '0');
ram_addrb <= (addr2 and addr_mask) when rst = '0' and addr2 >= X"0400" and addr1 <= X"07FF" else
             (others => '0');
rom_addra <= ('0' & addr2(15 downto 1)) when rst = '0' and addr2 >= X"0000" and addr2 <= X"03FF" else
             (others => '0');

err <= '1' when (addr1 > X"07FF" and addr1 < X"FFF0") or (addr1 > X"FFF3") or (addr2 > X"07FF" and addr2 < X"FFF0") or (addr2 > X"FFF3") else
       '0' when rst = '1' else
       '0'; --default
       
out_port <= out_reg;
       
ext_in : process(rst,in_port)
begin
    if rst = '1' then
        in_reg <= (others => '0');
    else
        in_reg <= in_port;
    end if;
end process;

ext_out : process(addr1)
begin
    if addr1 = x"FFF2" then
        out_reg <= wr_data;
    end if;
end process;

xpm_memory_dpdistram_inst : xpm_memory_dpdistram
generic map (
  ADDR_WIDTH_A => 16, -- DECIMAL
  ADDR_WIDTH_B => 16, -- DECIMAL
  BYTE_WRITE_WIDTH_A => 8, -- DECIMAL
  CLOCKING_MODE => "common_clock", -- String
  MEMORY_INIT_FILE => "none", -- String
  MEMORY_INIT_PARAM => "", -- String
  MEMORY_OPTIMIZATION => "true", -- String
  MEMORY_SIZE => 8192, -- DECIMAL
  MESSAGE_CONTROL => 0, -- DECIMAL
  READ_DATA_WIDTH_A => 16, -- DECIMAL
  READ_DATA_WIDTH_B => 16, -- DECIMAL
  READ_LATENCY_A => 0, -- DECIMAL
  READ_LATENCY_B => 0, -- DECIMAL
  READ_RESET_VALUE_A => "0", -- String
  READ_RESET_VALUE_B => "0", -- String
  --RST_MODE_A => "SYNC", -- String
  --RST_MODE_B => "SYNC", -- String
  USE_EMBEDDED_CONSTRAINT => 0, -- DECIMAL
  USE_MEM_INIT => 1, -- DECIMAL
  WRITE_DATA_WIDTH_A => 16 -- DECIMAL
)
port map (
  douta => ram_douta, -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
  doutb => ram_doutb, -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
  addra => ram_addra, -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
  addrb => ram_addrb, -- ADDR_WIDTH_B-bit input: Address for port B write and read operations.
  clka => clk, -- 1-bit input: Clock signal for port A. Also clocks port B when parameter
  -- CLOCKING_MODE is "common_clock".
  clkb => clk, -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
    -- "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
  dina => ram_dina, -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
  ena => '1', -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read
  -- or write operations are initiated. Pipelined internally.
  enb => '1', -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read
  -- or write operations are initiated. Pipelined internally.
  regcea => '1', -- 1-bit input: Clock Enable for the last register stage on the output data path.
  regceb => '1', -- 1-bit input: Do not change from the provided value.
  rsta => rst, -- 1-bit input: Reset signal for the final port A output register stage. Synchronously
  -- resets output port douta to the value specified by parameter READ_RESET_VALUE_A.
  rstb => rst, -- 1-bit input: Reset signal for the final port B output register stage. Synchronously
  -- resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
  wea => wr_en -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1
  -- bit wide when word-wide writes are used. In byte-wide write configurations, each bit
  -- controls the writing one byte of dina to address addra. For example, to
  -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea
  -- would be 4'b0010.
);
-- End of xpm_memory_dpdistram_inst instantiation

xpm_memory_sprom_inst : xpm_memory_sprom
generic map (
  ADDR_WIDTH_A => 16, -- DECIMAL
  AUTO_SLEEP_TIME => 0, -- DECIMAL
  ECC_MODE => "no_ecc", -- String
  MEMORY_INIT_FILE => "formatl_pt2.mem", -- String
  MEMORY_INIT_PARAM => "", -- String
  MEMORY_OPTIMIZATION => "true", -- String
  MEMORY_PRIMITIVE => "auto", -- String
  MEMORY_SIZE => 8192, -- DECIMAL
  MESSAGE_CONTROL => 0, -- DECIMAL
  READ_DATA_WIDTH_A => 16, -- DECIMAL
  READ_LATENCY_A => 0, -- DECIMAL
  READ_RESET_VALUE_A => "0", -- String
  --RST_MODE_A => "SYNC", -- String
  USE_MEM_INIT => 1, -- DECIMAL
  WAKEUP_TIME => "disable_sleep" -- String
)
port map (
  dbiterra => open, -- 1-bit output: Leave open.
  douta => rom_douta, -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
  sbiterra => open, -- 1-bit output: Leave open.
  addra => rom_addra, -- ADDR_WIDTH_A-bit input: Address for port A read operations.
  clka => clk, -- 1-bit input: Clock signal for port A.
  ena => '1', -- 1-bit input: Memory enable signal for port A. Must be high on clock
  -- cycles when read operations are initiated. Pipelined internally.
  injectdbiterra => '0', -- 1-bit input: Do not change from the provided value.
  injectsbiterra => '0', -- 1-bit input: Do not change from the provided value.
  regcea => '1', -- 1-bit input: Do not change from the provided value.
  rsta => rst, -- 1-bit input: Reset signal for the final port A output register
  -- stage. Synchronously resets output port douta to the value specified
  -- by parameter READ_RESET_VALUE_A.
  sleep => '0' -- 1-bit input: sleep signal to enable the dynamic power saving feature.
);
-- End of xpm_memory_sprom_inst instantiation
end behavioral;