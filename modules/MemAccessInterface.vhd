library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

--Wrapper around Xilinx RAM and ROM modules

entity mem_interface is
Port (addr1,addr2 : in std_logic_vector (11 downto 0); -- addr1 is r/w, addr2 is r only
        write_data : in std_logic_vector(15 downto 0);
        clk,rst,wr_en : in std_logic;
  	r1_data,r2_data : out std_logic_vector(15 downto 0)); 
end mem_interface;

architecture behavioral of mem_interface is

-- RAM signals
signal ram_douta,ram_doutb : std_logic_vector(15 downto 0); -- Data output for port A,B read operations
signal ram_addra,ram_addrb : std_logic_vector(11 downto 0); -- Address for port A,B write and read operations
signal ram_dina : std_logic_vector(15 downto 0); -- Data input for port A write operations
signal ram_ena,ram_enb : std_logic; -- Memory enable signal for port A,B. Must be high on clock cycles when read or write operations are initiated

-- ROM signals
signal rom_douta : std_logic_vector(15 downto 0); -- Data output for port A read operations
signal rom_addra : std_logic_vector(11 downto 0); -- Address for port A read operations
signal rom_ena : std_logic; -- Memory enable signal for port A. Must be high on clock cycles when read operations are initiated. Pipelined internally

begin
process(clk)
begin
	if rising_edge(clk) or falling_edge(clk) then
     		--choice of output depends on memory address (mem mapped)
     		--ROM: 0x0000 to 0x03E0
     		--RAM: 0x0400 to 0x0800
     		--InputPort:  0xFFF0
     		--OutputPort: 0xFFF2
		
		if addr1 >= X"0400" and addr1 <= X"0800" then
			if wr_en = '1' then
				-- write to RAM
				ram_ena <= '1';
				ram_dina <= write_data;
				ram_addra <= addr1;
			else then
				-- read from RAM
				ram_ena <= '1';
				ram_addra <= addr1;
				r1_data <= ram_douta;
			end if;
		elsif addr1 = X"FFF0" and wr_en = '0' then
			-- read from In port

		elsif addr1 = X"FFF2" and wr_en = '1' then
			-- write to Out port

		end if;
		
		if addr2 >= X"0000" and addr2 <= X"03E0" then
			-- read from ROM
			rom_ena <= '1';
			rom_addra <= addr2;
			r2_data <= rom_douta;
		elsif addr2 >= X"0400" and addr2 <= X"0800" then
			-- read from RAM
			ram_enb <= '1';
			ram_addrb <= addr2;
			r2_data <= ram_doutb;
		elsif addr2 = X"FFF0" then
			-- read from In port

		end if;
	end if;
end process;

xpm_memory_dpdistram_inst : xpm_memory_dpdistram
generic map (
  ADDR_WIDTH_A => 12, -- DECIMAL
  ADDR_WIDTH_B => 12, -- DECIMAL
  BYTE_WRITE_WIDTH_A => 16, -- DECIMAL
  CLOCKING_MODE => "common_clock", -- String
  MEMORY_INIT_FILE => "none", -- String
  MEMORY_INIT_PARAM => "0", -- String
  MEMORY_OPTIMIZATION => "true", -- String
  MEMORY_SIZE => 8192, -- DECIMAL
  MESSAGE_CONTROL => 0, -- DECIMAL
  READ_DATA_WIDTH_A => 16, -- DECIMAL
  READ_DATA_WIDTH_B => 16, -- DECIMAL
  READ_LATENCY_A => 1, -- DECIMAL
  READ_LATENCY_B => 1, -- DECIMAL
  READ_RESET_VALUE_A => "0", -- String
  READ_RESET_VALUE_B => "0", -- String
  RST_MODE_A => "SYNC", -- String
  RST_MODE_B => "SYNC", -- String
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
  dina => ram_dina, -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
  ena => ram_ena, -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read
  -- or write operations are initiated. Pipelined internally.
  enb => ram_enb, -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read
  -- or write operations are initiated. Pipelined internally.
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
  ADDR_WIDTH_A => 12, -- DECIMAL
  AUTO_SLEEP_TIME => 0, -- DECIMAL
  ECC_MODE => "no_ecc", -- String
  MEMORY_INIT_FILE => "none", -- String
  MEMORY_INIT_PARAM => "0", -- String
  MEMORY_OPTIMIZATION => "true", -- String
  MEMORY_PRIMITIVE => "auto", -- String
  MEMORY_SIZE => 8192, -- DECIMAL
  MESSAGE_CONTROL => 0, -- DECIMAL
  READ_DATA_WIDTH_A => 16, -- DECIMAL
  READ_LATENCY_A => 1, -- DECIMAL
  READ_RESET_VALUE_A => "0", -- String
  RST_MODE_A => "SYNC", -- String
  USE_MEM_INIT => 1, -- DECIMAL
  WAKEUP_TIME => "disable_sleep" -- String
)
port map (
  douta => rom_douta, -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
  addra => rom_addra, -- ADDR_WIDTH_A-bit input: Address for port A read operations.
  clka => clk, -- 1-bit input: Clock signal for port A.
  ena => rom_ena, -- 1-bit input: Memory enable signal for port A. Must be high on clock
  -- cycles when read operations are initiated. Pipelined internally.
  rsta => rst, -- 1-bit input: Reset signal for the final port A output register
  -- stage. Synchronously resets output port douta to the value specified
  -- by parameter READ_RESET_VALUE_A.
);
-- End of xpm_memory_sprom_inst instantiation
end behavioral;
