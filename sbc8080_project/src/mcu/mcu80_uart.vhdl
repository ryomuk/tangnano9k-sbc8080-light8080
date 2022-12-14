--#############################################################################
-- mcu80_uart.vhdl -- Basic, hardwired RS232 UART.
--
--#############################################################################
-- This program is based on the mcu80_uart.vhdl included in the
-- light8080 project, and modified to run programs for SBC8080
-- on Tang Nano 9K.
-- The IRQ functions are removed for simplicity.
--#############################################################################

--#############################################################################
-- Most operational parameters are hardcoded: 8 bit words, no parity, 1 stop 
-- bit. The only parameter that can be configured in run time is the baud rate.
--
-- The receiver logic is a simplified copy of the 8251 UART. The bit period is 
-- split in 16 sampling periods, and 3 samples are taken at the center of each 
-- bit period. The bit value is decided by majority.The receiver logic has some
-- error recovery capability that should make this core reliable enough for
-- actual application use -- yet, the core does not have a formal test bench.
--
-- See usage notes below.
--
-------------------------------------------------------------------------------
-- Please see the LICENSE file in the project root for license matters.
--#############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- UART programmer model
-------------------------------------------------------------------------------
--
-- The UART has a number of configuration registers addressable with input 
-- signal addr_i:
--
-- [00] => Data buffer, both transmission and reception.
-- [01] => Status/control register (r/w).
-- [10] => Bit period register, low byte.
-- [11] => Bit period register, high byte.
--
-- Data buffers:
----------------
--
-- The same address [00b] is used for both the receive buffer and the 
-- transmision buffer. 
--
-- Writing to the data buffer when flag TxRdy is high will trigger a 
-- transmission and clear flag TxRdy.
-- Writing to the data buffer when flag TxRdy is clear will have no effect.
-- 
-- Reading the data register when flag RxRdy is high will return the last 
-- received data byte, and will clear flag RxRdy.
-- Reading the register when flag RxRdy is clear will return indeterminate data,
-- which in practice will usually be the last byte received.
--
-------------------
--
-- The core is capable of detecting and recovering from these error conditions:
-- 
-- -# When a start bit is determined to be spurious (i.e. the falling edge is 
--    detected but the bit value when sampled is not 0) then the core returns to
--    its idle state (waiting for a new start bit).
-- -# If a stop bit is determined to be invalid (not 1 when sampled), the 
--    reception interrupt is not triggered and the received byte is discarded.
-- -# When the 3 samples taken from the center of a bit period are not equal, 
--    the bit value is decided by majority.
-- 
-- In none of the 3 cases does the core raise any error flag. It would be very 
-- easy to include those flags in the core, but it would take a lot more time 
-- to test them minimally and that's why they haven't been included.
--
-- Status register flags:
-------------------------
--
--      7       6       5       4       3       2       1       0
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--  |   0   |   0   |   0   |   0   |   0   |   0   | RxRdy | TxRdy |
--  +-------+-------+-------+-------+-------+-------+-------+-------+
--      h       h       h       h       h       h       r       r     
--
--  Bits marked 'h' are hardwired and can't be modified. 
--  Bits marked 'r' are read only; they are set and clear by the core.
--
-- -# Status bit TxRdy is high when there isn't any transmission in progress. 
--    It is cleared when data is written to the transmission buffer and is 
--    raised at the same time the transmission interrupt is triggered.
-- -# Status bit RxRdy is raised at the same time the receive interrupt is
--    triggered and is cleared when the data register is read.
--
-- Baud rate configuration:
---------------------------
--
-- The baud rate is determined by the value of 14-bit register 'bit_period_reg'.
-- This register holds the length of the bit period in clock cycles and its
-- value may be hardcoded or configured at run time.
--
--------------------------------------------------------------------------------
-- Core interface signals:
--
-- clk_i:     Clock input, active rising edge.
-- reset_i:   Synchronous reset.
-- txd_o:     TxD UART output.
-- rxd_i:     RxD UART input -- synchronization logic included.
-- rx_rdy_o:  RxD ready output.
-- data_i:    Data bus, input.
-- data_o:    Data bus, output.
-- addr_i:    Register selection address (see above).
-- wr_i:      Write enable input.
-- rd_i:      Read enable input.
-- ce_i:      Chip enable, must be active at the same time as wr_i or rd_i.
-- 
--
-- A detailed explanation of the interface timing will not be given. The core 
-- reads and writes like a synchronous memory. There's usage examples in other 
-- project files.
--------------------------------------------------------------------------------

entity mcu80_uart is
  generic (
    BAUD_RATE     : integer ;
    CLOCK_FREQ    : integer
  );
  port ( 
        rxd_i     : in std_logic;
        txd_o     : out std_logic;
        
        rx_rdy_o  : out std_logic;
        
        data_i    : in std_logic_vector(7 downto 0);
        data_o    : out std_logic_vector(7 downto 0);
        
        addr_i    : in std_logic_vector(1 downto 0);
        wr_i      : in std_logic;
        rd_i      : in std_logic;
        ce_i      : in std_logic;
        
        clk_i     : in std_logic;
        reset_i   : in std_logic
  );
end mcu80_uart;

architecture hardwired of mcu80_uart is

-- Bit period expressed in master clock cycles
constant DEFAULT_BIT_PERIOD : integer := (CLOCK_FREQ / BAUD_RATE);

-- Bit sampling period is 1/16 of the baud rate.
constant DEFAULT_SAMPLING_PERIOD : integer := DEFAULT_BIT_PERIOD / 16;

--#############################################################################

-- Common signals

signal reset :            std_logic;
signal clk :              std_logic;

signal bit_period_reg :   unsigned(13 downto 0);
signal sampling_period :  unsigned(9 downto 0);

-- Interrupt & status register signals

signal load_stat_reg :    std_logic;
signal load_tx_reg :      std_logic;

-- Receiver signals
signal rxd_q :            std_logic;
signal tick_ctr :         unsigned(3 downto 0);
signal state :            unsigned(3 downto 0);
signal next_state :       unsigned(3 downto 0);
signal start_bit_detected : std_logic;
signal reset_tick_ctr :   std_logic;
signal stop_bit_sampled : std_logic;
signal load_rx_buffer :   std_logic;
signal stop_error :       std_logic;
signal samples :          std_logic_vector(2 downto 0);
signal sampled_bit :      std_logic;
signal do_shift :         std_logic;
signal rx_buffer :        std_logic_vector(7 downto 0);
signal rx_shift_reg :     std_logic_vector(9 downto 0);
signal tick_ctr_enable :  std_logic;
signal tick_baud_ctr :    unsigned(10 downto 0);

signal rx_rdy_flag :      std_logic;
signal set_rx_rdy_flag :  std_logic;
signal rxd :              std_logic;

signal read_rx :          std_logic;
signal status :           std_logic_vector(7 downto 0);

-- Transmitter signals 

signal tx_counter :       unsigned(13 downto 0);
signal tx_data :          std_logic_vector(10 downto 0);
signal tx_ctr_bit :       unsigned(3 downto 0);
signal tx_busy :          std_logic;

begin

-- Rename the most commonly used inputs to get rid of the i/o suffix
clk <= clk_i;
reset <= reset_i;
rxd <= rxd_i;

-- Serial port status byte -- only 2 status flags
status <= 
    "000000" & rx_rdy_flag & (not tx_busy); -- State flags

-- Read register multiplexor
with addr_i select data_o <= 
    rx_buffer   when "00",
    status      when others;

load_tx_reg <= '1' when wr_i = '1' and ce_i = '1' and addr_i = "00" else '0';
load_stat_reg <= '1' when wr_i = '1' and ce_i = '1' and addr_i = "01" else '0';
read_rx <= '1' when rd_i = '1' and ce_i = '1' and addr_i= "00" else '0';

rx_rdy_o <= rx_rdy_flag;

baud_rate_registers:
process(clk)
begin
  if clk'event and clk='1' then
    if reset = '1' then
      bit_period_reg <= to_unsigned(DEFAULT_BIT_PERIOD,14);
    else
      if wr_i = '1' and ce_i = '1' then
        if addr_i = "10" then
          bit_period_reg(7 downto 0) <= unsigned(data_i);
        elsif addr_i = "11" then
          bit_period_reg(13 downto 8) <= unsigned(data_i(5 downto 0));
        end if;
      end if;
    end if;
  end if;
end process baud_rate_registers;

sampling_period <= bit_period_reg(13 downto 4);
  
-- Receiver -------------------------------------------------------------------

baud_counter:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      tick_baud_ctr <= (others => '0');
    else
      if tick_baud_ctr=sampling_period then
        tick_baud_ctr <= (others => '0');
      else
        tick_baud_ctr <= tick_baud_ctr + 1;
      end if;
    end if;
  end if;
end process baud_counter;

tick_ctr_enable<= '1' when tick_baud_ctr=sampling_period else '0';

-- Register RxD at the bit sampling rate -- 16 times the baud rate. 
rxd_input_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rxd_q <= '0';
    else
      if tick_ctr_enable='1' then
        rxd_q <= rxd;
      end if;
    end if;
  end if;
end process rxd_input_register;

-- We detect the start bit when...
start_bit_detected <= '1' when 
      state="0000" and        -- ...we're waiting for the start bit...
      rxd_q='1' and rxd='0'   -- ...and we see RxD going 1-to-0
      else '0';         

-- As soon as we detect the start bit we synchronize the bit sampler to 
-- the start bit's falling edge.
reset_tick_ctr <= '1' when start_bit_detected='1' else '0';

-- We have seen the end of the stop bit when...
stop_bit_sampled <= '1' when 
      state="1010" and      -- ...we're in the stop bit period...
      tick_ctr="1011"       -- ...and we get the 11th sample in the bit period
      else '0';

-- Load the RX buffer with the shift register when...
load_rx_buffer <= '1' when 
      stop_bit_sampled='1' and -- ...we've just seen the end of the stop bit...
      sampled_bit='1'          -- ...and its value is correct (1)
      else '0';

-- Conversely, we detect a stop bit error when...   
stop_error <= '1' when 
      stop_bit_sampled='1' and -- ...we've just seen the end of the stop bit...
      sampled_bit='0'          -- ...and its value is incorrect (0)
      else '0';

-- tick_ctr is a counter 16 times faster than the baud rate that is aligned to 
-- the falling edge of the start bit, so that when tick_ctr=0 we're close to 
-- the start of a bit period.      
bit_sample_counter:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      tick_ctr <= "0000";
    else
      if tick_ctr_enable='1' then
        -- Restart counter when it reaches 15 OR when the falling edge
        -- of the start bit is detected; this is how we synchronize to the 
        -- start bit.
        if tick_ctr="1111" or reset_tick_ctr='1' then
          tick_ctr <= "0000";
        else
          tick_ctr <= tick_ctr + 1;
        end if;
      end if;
    end if;
  end if;
end process bit_sample_counter;

-- Main RX state machine: 
-- 0      -> waiting for start bit
-- 1      -> sampling start bit
-- 2..9   -> sampling data bit 0 to 7
-- 10     -> sampling stop bit
next_state <= 
  -- Start sampling the start bit when we detect the falling edge
  "0001" when state="0000" and start_bit_detected='1' else
  -- Return to idle state if the start bit is not a clean 0
  "0000" when state="0001" and tick_ctr="1010" and sampled_bit='1' else
  -- Return to idle state at the end of the stop bit period
  "0000" when state="1010" and tick_ctr="1111" else
  -- Otherwise, proceed to next bit period at the end of each period
  state + 1 when tick_ctr="1111" and do_shift='1' else
  state;
      
rx_state_machine_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      state <= "0000";
    else
      if tick_ctr_enable='1' then
        state <= next_state;
      end if;   
    end if;
  end if;
end process rx_state_machine_register;

-- Collect 3 RxD samples from the 3 central sampling periods of the bit period.
rx_sampler:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      samples <= "000";
    else
      if tick_ctr_enable='1' then
        if tick_ctr="0111" then
          samples(0) <= rxd;
        end if;
        if tick_ctr="1000" then
          samples(1) <= rxd;
        end if;
        if tick_ctr="1001" then
          samples(2) <= rxd;
        end if;
      end if;
    end if;
  end if;
end process rx_sampler;

-- Decide the value of the RxD bit by majority
with samples select 
  sampled_bit <=  '0' when "000",
                  '0' when "001",
                  '0' when "010",
                  '1' when "011",
                  '0' when "100",
                  '1' when "101",
                  '1' when "110",
                  '1' when others;

rx_buffer_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rx_buffer <= "00000000";
      set_rx_rdy_flag <= '0';
    else
      if tick_ctr_enable='1' and load_rx_buffer='1' and rx_rdy_flag='0' then
        rx_buffer <= rx_shift_reg(8 downto 1);
        set_rx_rdy_flag <= '1';
      else
        set_rx_rdy_flag <= '0';
      end if;
    end if;
  end if;
end process rx_buffer_register;

rx_flag:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rx_rdy_flag <= '0';
    else
      if set_rx_rdy_flag='1' then
        rx_rdy_flag <= '1';
      else
        if read_rx = '1' then
          rx_rdy_flag <= '0';
        end if;
      end if;
    end if;
  end if;
end process rx_flag;

-- RX shifter control: shift in any state other than idle state (0)
do_shift <= state(0) or state(1) or state(2) or state(3);

rx_shift_register:
process(clk)
begin
  if clk'event and clk='1' then
    if reset='1' then
      rx_shift_reg <= "1111111111";
    else
      if tick_ctr_enable='1' then
        if tick_ctr="1010" and do_shift='1' then
          rx_shift_reg(9) <= sampled_bit;
          rx_shift_reg(8 downto 0) <= rx_shift_reg(9 downto 1);
        end if;
      end if;
    end if;
  end if;
end process rx_shift_register;

    
-- Transmitter ----------------------------------------------------------------


main_tx_process:
process(clk)
begin
if clk'event and clk='1' then
  
  if reset='1' then
    tx_data <= "10111111111";
    tx_busy <= '0';
    tx_ctr_bit <= "0000";
    tx_counter <= (others => '0');
  elsif load_tx_reg='1' and tx_busy='0' then
    tx_data <= "1"&data_i&"01";
    tx_busy <= '1';
  else
    if tx_busy='1' then
      if tx_counter = bit_period_reg then
        tx_counter <= (others => '0');
        tx_data(9 downto 0) <= tx_data(10 downto 1);
        tx_data(10) <= '1';
        if tx_ctr_bit = "1010" then
           tx_busy <= '0';
           tx_ctr_bit <= "0000";
        else
           tx_ctr_bit <= tx_ctr_bit + 1;
        end if;
      else
        tx_counter <= tx_counter + 1;
      end if;
    end if;
  end if;
end if;
end process main_tx_process;

txd_o <= tx_data(0);

end hardwired;
