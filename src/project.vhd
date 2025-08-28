-- tt_um_pwm_block.vhd
-- Converted from Verilog
-- Copyright (c) 2024 Your Name
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tt_um_pwm_block is
  port (
    ui_in   : in  std_logic_vector(7 downto 0);  -- Dedicated inputs
    uo_out  : out std_logic_vector(7 downto 0);  -- Dedicated outputs
    uio_in  : in  std_logic_vector(7 downto 0);  -- IOs: Input path
    uio_out : out std_logic_vector(7 downto 0);  -- IOs: Output path
    uio_oe  : out std_logic_vector(7 downto 0);  -- IOs: Enable path (active high: 0=input, 1=output)
    ena     : in  std_logic;                     -- always 1 when the design is powered, so you can ignore it
    clk     : in  std_logic;                     -- clock
    rst_n   : in  std_logic                      -- reset_n - low to reset
  );
end entity tt_um_pwm_block;

architecture rtl of tt_um_pwm_block is

  -- Component declaration for spi_pwm (kept as in Verilog instantiation)
  component spi_pwm
    port (
      reset_n   : in  std_logic;
      cpol      : in  std_logic;
      cpha      : in  std_logic;
      sclk      : in  std_logic;
      ss_n      : in  std_logic;
      mosi      : in  std_logic;
      miso      : out std_logic;
      rx_enable : in  std_logic;
      tx        : in  std_logic_vector(31 downto 0);
      rx        : out std_logic_vector(7 downto 0);
      busy      : out std_logic;
      pwm_clk   : in  std_logic;
      pwm_out   : out std_logic_vector(2 downto 0)
    );
  end component;

  -- Internal signals for connecting the spi_pwm component to entity ports
  signal spi_miso_sig   : std_logic;
  signal spi_rx_sig     : std_logic_vector(7 downto 0);
  signal spi_busy_sig   : std_logic;
  signal spi_tx_sig     : std_logic_vector(31 downto 0) := (others => '0');
  signal spi_pwm_out_sig: std_logic_vector(2 downto 0);

  -- Dummy signal to reference otherwise-unused inputs (avoids some lint warnings)
  signal _unused : std_logic;

begin

  -- Default direction mask for the IOs (same bit order as the Verilog string "10001111")
  uio_oe <= "10001111";

  -- Assign unused output bits to zero
  uio_out(6 downto 0) <= (others => '0');
  uo_out(7 downto 3)  <= (others => '0');

  -- Connect SPI pwm outputs to the top-level outputs
  uio_out(7)          <= spi_miso_sig;         -- spi miso connected to uio_out[7]
  uo_out(2 downto 0)  <= spi_pwm_out_sig;      -- pwm outputs mapped to lower 3 bits

  -- Instantiate spi_pwm
  spi_inst : spi_pwm
    port map (
      reset_n   => rst_n,
      cpol      => '0',
      cpha      => '0',
      sclk      => uio_in(4),
      ss_n      => uio_in(5),
      mosi      => uio_in(6),
      miso      => spi_miso_sig,
      rx_enable => '1',
      tx        => spi_tx_sig,
      rx        => spi_rx_sig,
      busy      => spi_busy_sig,
      pwm_clk   => clk,
      pwm_out   => spi_pwm_out_sig
    );

  -- Create a combined unused signal so synthesis/lint tools see the inputs referenced
  -- Mirrors Verilog's reduction-and including a literal 0 (so result is '0' like the original)
  _unused <= ena and ui_in(0) and uio_in(0) and uio_in(1) and uio_in(2) and uio_in(3) and uio_in(7) and '0';

  -- Prevent unused-signal optimization (some tools require this pattern)
  -- Tie to itself in a null process (no effect at runtime)
  unused_block: process(all)
  begin
    -- read-only reference to _unused so compiler considers it used
    if (_unused = '1') then
      null;
    end if;
  end process unused_block;

end architecture rtl;
