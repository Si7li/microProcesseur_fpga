----------------------------------------------------------------------
-- Nexys 3 wrapper for the MicroProcesseur project
--
--   display, right to left :  PC | A (0x100) | B (0x101) | C (0x102)
--   sw7 down  : CPU free-runs at about 6 Hz
--   sw7 up    : manual mode, BTNU steps one instruction per press
--   btnS      : reset      LD7 : RnW      LD6..LD0 : address bus
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_fpga is
  port (
    clk  : in  std_logic;
    btns : in  std_logic;                     -- centre button : reset
    btnu : in  std_logic;                     -- up button     : single step
    sw   : in  std_logic_vector(7 downto 0);
    led  : out std_logic_vector(7 downto 0);
    seg  : out std_logic_vector(7 downto 0);
    an   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of top_fpga is

  component MicroProcesseur is
    port (clk      : in    std_logic;
          reset    : in    std_logic;
          bus_addr : out   std_logic_vector(11 downto 0);
          bus_data : inout std_logic_vector(15 downto 0);
          RnW      : out   std_logic);
  end component;

  component Memory is
    port (clk      : in    std_logic;
          RnW      : in    std_logic;
          addr     : in    std_logic_vector(11 downto 0);
          bus_data : inout std_logic_vector(15 downto 0));
  end component;

  constant PRESCALE_BIT  : integer := 23;   -- free-run speed, ~6 Hz
  constant DEBOUNCE_BITS : integer := 20;   -- ~10 ms at 100 MHz

  constant ADDR_A : std_logic_vector(11 downto 0) := x"100";
  constant ADDR_B : std_logic_vector(11 downto 0) := x"101";
  constant ADDR_C : std_logic_vector(11 downto 0) := x"102";

  signal prescale : unsigned(25 downto 0) := (others => '0');
  signal cpu_clk  : std_logic := '0';

  -- step button: synchronise, debounce, detect the press edge
  signal btn_sync   : std_logic_vector(1 downto 0) := "00";
  signal db_cnt     : unsigned(DEBOUNCE_BITS-1 downto 0) := (others => '0');
  signal btn_db     : std_logic := '0';
  signal btn_db_d   : std_logic := '0';
  signal step_press : std_logic := '0';

  -- one press = three CPU cycles = one complete instruction
  signal pulses_left : unsigned(1 downto 0) := "00";
  signal gap         : unsigned(3 downto 0) := (others => '0');
  signal step_clk    : std_logic := '0';

  signal bus_addr : std_logic_vector(11 downto 0);
  signal bus_data : std_logic_vector(15 downto 0);
  signal rnw      : std_logic;

  signal phase  : unsigned(1 downto 0) := "00";   -- 0 FETCH, 1 DECODE, 2 EXECUTE
  signal pc_reg : std_logic_vector(11 downto 0) := (others => '0');
  signal pc_show: std_logic_vector(11 downto 0);
  signal a_reg  : std_logic_vector(15 downto 0) := (others => '0');
  signal b_reg  : std_logic_vector(15 downto 0) := (others => '0');
  signal c_reg  : std_logic_vector(15 downto 0) := (others => '0');

  signal sel    : unsigned(1 downto 0);
  signal nibble : std_logic_vector(3 downto 0);
  signal segs   : std_logic_vector(0 to 6);

begin

  ----------------------------------------------------------------
  -- 100 MHz housekeeping: prescaler, button debounce, step pulses
  ----------------------------------------------------------------
  process (clk)
  begin
    if rising_edge(clk) then
      prescale <= prescale + 1;

      btn_sync <= btn_sync(0) & btnu;
      if btn_sync(1) /= btn_db then
        db_cnt <= db_cnt + 1;
        if db_cnt = (db_cnt'range => '1') then
          btn_db <= btn_sync(1);
          db_cnt <= (others => '0');
        end if;
      else
        db_cnt <= (others => '0');
      end if;

      btn_db_d   <= btn_db;
      step_press <= btn_db and not btn_db_d;     -- one pulse per press

      step_clk <= '0';
      if step_press = '1' and pulses_left = 0 then
        pulses_left <= "01";                     -- three cycles to come
        gap         <= (others => '0');
      elsif pulses_left /= 0 then
        gap <= gap + 1;
        if gap = 15 then
          step_clk    <= '1';
          pulses_left <= pulses_left - 1;
        end if;
      end if;

      if sw(7) = '1' then
        cpu_clk <= step_clk;                     -- manual
      else
        cpu_clk <= prescale(PRESCALE_BIT);       -- free-running
      end if;
    end if;
  end process;

  U_CPU : MicroProcesseur
    port map (clk => cpu_clk, reset => btns,
              bus_addr => bus_addr, bus_data => bus_data, RnW => rnw);

  U_MEM : Memory
    port map (clk => cpu_clk, RnW => rnw,
              addr => bus_addr, bus_data => bus_data);

  ----------------------------------------------------------------
  -- Watch the bus.  'phase' mirrors the CPU's three-state cycle:
  -- in FETCH the address bus carries the PC, in the other two it
  -- carries the operand address, so A, B and C can be captured
  -- from the data bus as the program touches them.
  ----------------------------------------------------------------
  process (cpu_clk)
  begin
    if rising_edge(cpu_clk) then
      if btns = '1' or phase = 2 then
        phase <= "00";
      else
        phase <= phase + 1;
      end if;

      if phase = 0 then
        pc_reg <= bus_addr;
      else
        case bus_addr is
          when ADDR_A => a_reg <= bus_data;
          when ADDR_B => b_reg <= bus_data;
          when ADDR_C => c_reg <= bus_data;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  led(7)          <= rnw;
  led(6 downto 0) <= bus_addr(6 downto 0);

  sel <= prescale(17 downto 16);

  -- PC digit: follow the bus during FETCH, hold it for the rest of the instruction
  pc_show <= bus_addr when phase = 0 else pc_reg;

  -- an(0) is the rightmost digit
  with sel select
    nibble <= pc_show(3 downto 0) when "00",   -- right : program counter
              a_reg(3 downto 0)  when "01",   --         A
              b_reg(3 downto 0)  when "10",   --         B
              c_reg(3 downto 0)  when others; -- left  : C, the result

  with sel select
    an <= "1110" when "00", "1101" when "01", "1011" when "10", "0111" when others;

  with nibble select
    segs <= "0000001" when "0000", "1001111" when "0001", "0010010" when "0010",
            "0000110" when "0011", "1001100" when "0100", "0100100" when "0101",
            "0100000" when "0110", "0001111" when "0111", "0000000" when "1000",
            "0000100" when "1001", "0001000" when "1010", "1100000" when "1011",
            "0110001" when "1100", "1000010" when "1101", "0110000" when "1110",
            "0111000" when others;

  seg(0) <= segs(0); seg(1) <= segs(1); seg(2) <= segs(2); seg(3) <= segs(3);
  seg(4) <= segs(4); seg(5) <= segs(5); seg(6) <= segs(6);  seg(7) <= '0' when (phase = 0 and sel = "00") else '1';   -- dot on the PC digit during FETCH

end architecture;