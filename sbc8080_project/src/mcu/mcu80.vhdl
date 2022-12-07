--#############################################################################
-- mcu80_mcu : light8080-based Micro Controller Unit
--#############################################################################
-- This program is based on the mcu80 sample codes included in the
-- light8080 project, and modified to run programs for SBC8080
-- on Tang Nano 9K FPGA board with binary-level compatibility.
-- The UART is implemented in hardwired form, and the 8251 registers are
-- not implemented.
--#############################################################################
--
--#############################################################################
-- This MCU is meant as an usage example for the light8080 core. The code shows
-- how to interface the core to internal BRAM and other modules.
-- This module is not meant to be used in real applications though it can be
-- used as the starting point for one.
--
-- Please see the comments below for usage instructions.
-- Please see the LICENSE file in the project root for license matters.
--#############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
use work.mcu80_pkg.all;
use work.obj_code_pkg.all;

--#############################################################################
-- Interface pins:
------------------
-- rxd_i :    UART RxD pin.
-- txd_o :    UART TxD pin.
-- clk :      Master clock, rising edge active.
-- reset :    Synchronous reset, 1 cycle active to reset all SoC.
--
-------------------------------------------------------------------------------
-- Generics:
------------
-- OBJ_CODE (mandatory, no default value):  
-- Table that will be used to initialize internal BRAM, starting at address 0.
--
-------------------------------------------------------------------------------
-- I/O port map:
----------------
--
-- 000h..003h     UART registers.
-- 004h           Input port  (read only, writes are ignored).
-- 006h           Output port (write only, reads undefined data).
--
-- Please see the comments in the source of the relevant modules for a more
-- detailed explanation of their behavior.
--
-- All i/o  ports other than the above read as 00h.
--#############################################################################
entity mcu80 is
    generic (
      OBJ_CODE: obj_code_t := object_code; -- ROM initialization constant 
      ROM_SIZE: integer := 16*1024;   -- ROM size
      RAM_SIZE: integer := 32*1024;   -- RAM size
      MEM_SEL:  integer := 15;        -- ROM/RAM selection bit
      -- ROM area: 0000H..ROM_SIZE-1
      -- RAM area: 8000H..8000H+RAM_SIZE-1

--      BAUD_RATE:  integer := 115200; -- UART baud rate
      BAUD_RATE:  integer := 9600; -- UART baud rate
      CLOCK_FREQ: integer := 27E6  -- Clock rate (27MHz for Tang Nano 9K)
    );
    port (  
      clk:    in  std_logic;

      rxd_i:  in  std_logic;
      txd_o:  out std_logic;
      
      test_i: in  std_logic_vector(7 downto 0); -- for debug
      test_o: out std_logic_vector(3 downto 0); -- for debug
      led:    out std_logic_vector(5 downto 0);
      sw_S1:  in  std_logic;
      sw_S2:  in  std_logic
      );
end mcu80;

architecture hardwired of mcu80 is
-- Custom types ---------------------------------------------------------------
subtype t_byte is std_logic_vector(7 downto 0);
subtype io_addr_t is unsigned(7 downto 0);

-- CPU signals ----------------------------------------------------------------
signal reset : std_logic;

signal cpu_vma :      std_logic;
signal cpu_rd :       std_logic;
signal cpu_wr :       std_logic;
signal cpu_io :       std_logic;
signal cpu_fetch :    std_logic;
signal cpu_addr :     std_logic_vector(15 downto 0);
signal cpu_data_i :   std_logic_vector(7 downto 0);
signal cpu_data_o :   std_logic_vector(7 downto 0);
signal cpu_intr :     std_logic;
signal cpu_inte :     std_logic;
signal cpu_inta :     std_logic;
signal cpu_halt :     std_logic;

-- Aux CPU signals ------------------------------------------------------------
signal io_wr :        std_logic; -- asserted in IO write cycles
signal io_rd :        std_logic; -- asserted in IO read cycles

-- io_addr: IO port address, lowest 8 bits of address bus
signal io_addr :      unsigned(7 downto 0);
signal port_i :      std_logic_vector(7 downto 0); -- port register
signal port_o :      std_logic_vector(7 downto 0); -- port register

-- data coming from IO ports (io input mux)
signal io_rd_data :   std_logic_vector(7 downto 0);

-- registered cpu_io, used to control mux after cpu_io deasserts
signal cpu_io_reg :   std_logic;

-- UART -----------------------------------------------------------------------
signal uart_ce :      std_logic;
signal uart_data_rd : std_logic_vector(7 downto 0);
signal uart_rx_rdy  : std_logic;

signal uart_rxd : std_logic;
signal uart_txd : std_logic;

-- MEMORY ---------------------------------------------------------------------
constant ROM_ADDR_SIZE : integer := log2(ROM_SIZE);
constant RAM_ADDR_SIZE : integer := log2(RAM_SIZE);

signal mem_rd_data :  std_logic_vector(7 downto 0);
signal mem_we :       std_logic;

signal rom :      mem_t(0 to ROM_SIZE-1) := objcode_to_bram(OBJ_CODE, ROM_SIZE);
signal ram :      mem_t(0 to RAM_SIZE-1) := zerofilled_bram(RAM_SIZE);
signal mem_addr :     unsigned(15 downto 0);

-- for Debug ------------------------------------------------------------------
signal clk_4hz : std_logic;
signal counter_4hz: unsigned(25 downto 0);
signal testbuf : std_logic;
  
-- IO ports addresses ---------------------------------------------------------
constant ADDR_UART_0 : io_addr_t  := X"00"; -- UART registers (00h..03h)
constant ADDR_UART_1 : io_addr_t  := X"01"; -- UART registers (00h..03h)
constant ADDR_UART_2 : io_addr_t  := X"02"; -- UART registers (00h..03h)
constant ADDR_UART_3 : io_addr_t  := X"03"; -- UART registers (00h..03h)
constant ADDR_PIN    : io_addr_t  := X"04"; -- Input port register 
constant ADDR_POUT   : io_addr_t  := X"06"; -- Output port register 

begin
  reset  <= (not sw_S1) or (not sw_S2);

-- UART and MCU are connected via intermediate signals uart_*
-- to be able to output to test_o
  uart_rxd <= rxd_i;
  txd_o <= uart_txd;

  led(0) <= not clk_4hz;
--  test_o(3 downto 0) <= "0000";
  test_o(0) <= uart_rx_rdy;
  test_o(1) <= uart_txd;
  test_o(2) <= uart_rxd;
  test_o(3) <= '0';

  port_i <= test_i(7 downto 0);

  cpu: entity work.light8080 
  port map (
        clk =>      clk,
        reset =>    reset,
        vma =>      cpu_vma,
        rd =>       cpu_rd,
        wr =>       cpu_wr,
        io =>       cpu_io,
        fetch =>    cpu_fetch,
        addr_out => cpu_addr, 
        data_in =>  cpu_data_i,
        data_out => cpu_data_o,
        
        intr =>     cpu_intr,
        inte =>     cpu_inte,
        inta =>     cpu_inta,
        halt =>     cpu_halt
  );
  
  io_rd <= cpu_io and cpu_rd;
  io_wr <= '1' when cpu_io='1' and cpu_wr='1' else '0';
  io_addr <= unsigned(cpu_addr(7 downto 0));
  
  -- Register some control signals that are needed to control multiplexors the
  -- cycle after the control signal asserts -- e.g. cpu_io.
  control_signal_registers:
  process(clk)
  begin
    if clk'event and clk='1' then
      cpu_io_reg <= cpu_io;
    end if;
  end process control_signal_registers;
  
  -- Interrupt asserted by RXRDY -------------
  cpu_intr <= uart_rx_rdy;

  -- Input data mux -- remember, no 3-state buses within the FPGA -------------
  cpu_data_i <= 
    X"FF"        when cpu_inta = '1' -- RST7
    else
    io_rd_data   when cpu_io_reg = '1'
    else 
    mem_rd_data;
  
  -- BRAM ---------------------------------------------------------------------
  mem_we <= '1' when cpu_io='0' and cpu_wr='1' else '0';
  mem_addr <= unsigned(cpu_addr(15 downto 0));
  
  memory:
  process(clk)
  begin
    if clk'event and clk='1' then
      if(mem_addr(MEM_SEL) = '0') then -- ROM
        if mem_we = '1' then
        -- ROM is write protected
        -- If you want to write on ROM area, uncomment below.
        -- rom(to_integer(mem_addr(ROM_ADDR_SIZE-1 downto 0))) <= cpu_data_o;
        else
          mem_rd_data <= rom(to_integer(mem_addr(ROM_ADDR_SIZE-1 downto 0)));
        end if;
      else -- RAM
        if mem_we = '1' then
          ram(to_integer(mem_addr(RAM_ADDR_SIZE-1 downto 0))) <= cpu_data_o;
        else
          mem_rd_data <= ram(to_integer(mem_addr(RAM_ADDR_SIZE-1 downto 0)));
        end if;
      end if;
    end if;
  end process memory;
  
  -- UART -- simple UART with hardwired baud rate -----------------------------
  -- NOTE: the serial port does NOT have interrupt capability (yet)
  
  uart : entity work.mcu80_uart
  generic map (
    BAUD_RATE =>      BAUD_RATE,
    CLOCK_FREQ =>     CLOCK_FREQ
  )
  port map (
    clk_i =>          clk,
    reset_i =>        reset,
    
    rx_rdy_o =>         uart_rx_rdy,

    data_i =>         cpu_data_o,
    data_o =>         uart_data_rd,
    addr_i =>         cpu_addr(1 downto 0),
    
    ce_i =>           uart_ce,
    wr_i =>           io_wr,
    rd_i =>           io_rd,
    
    rxd_i =>          uart_rxd,
    txd_o =>          uart_txd
  );
  
  -- UART write enable
  uart_ce <= '1' when 
        io_addr(7 downto 2) = ADDR_UART_0(7 downto 2)
        else '0';
  
  -- IO ports -- Simple IO ports with hardcoded direction ---------------------
  -- These are meant as an usage example mostly
  
  output_ports:
  process(clk)
  begin
    if clk'event and clk='1' then
      if reset = '1' then 
        -- Reset values for all io ports
        port_o <= (others => '0');
      else
        if io_wr = '1' then
          if to_integer(io_addr) = ADDR_POUT then
            port_o <= cpu_data_o;
          end if;
        end if; 
      end if;
    end if;
  end process output_ports;
  
  for_debug:
  process(clk)
  begin
    if clk'event and clk='1' then
      if reset = '1' then
        clk_4hz <= '0';
        counter_4hz <= (others => '0');
      else
        if counter_4hz = CLOCK_FREQ/8 then
          counter_4hz <= (others => '0');
          clk_4hz <= not clk_4hz;
          led(5 downto 1) <= not cpu_addr(12 downto 8);
        else
          counter_4hz <= counter_4hz + 1;
        end if;
      end if;
    end if;
  end process for_debug;

-- Input IO data multiplexor
  with io_addr select io_rd_data <= 
    port_i          when ADDR_PIN,
    uart_data_rd    when ADDR_UART_0,
    uart_data_rd    when ADDR_UART_1,
    uart_data_rd    when ADDR_UART_2,
    uart_data_rd    when ADDR_UART_3,
    X"00"           when others;

end hardwired;

