----------------------------------------------------------------------------------
-- Company: HES-SO AGSL
-- Engineer: https://github.com/nematoli/SPI-FPGA-VHDL, with edits from John Biselx
--
-- Create Date: 08/28/2025 10:03:43 AM
-- Design Name:
-- Module Name: spi_slave - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use IEEE.STD_LOGIC_ARITH.all;

entity spi_slave is
    generic (
        data_length : integer := 16 -- Data length in bits
    );
    port (
        reset_n   : in  std_logic;                                                     -- Asynchronous active low reset
        cpol      : in  std_logic;                                                     -- Clock polarity mode
        cpha      : in  std_logic;                                                     -- Clock phase mode
        sclk      : in  std_logic;                                                     -- Spi clk
        ss_n      : in  std_logic;                                                     -- Slave select
        mosi      : in  std_logic;                                                     -- Master out slave in
        miso      : out std_logic;                                                     -- Master in slave out
        rx_enable : in  std_logic;                                                     -- Enable signal to wire rxBuffer to outside
        tx        : in  std_logic_vector(data_length - 1 downto 0);                    -- Data to transmit
        rx        : out std_logic_vector(data_length - 1 downto 0) := (others => '0'); -- Data received
        busy      : out std_logic                                  := '0'              -- Slave busy signal
    );
end spi_slave;

architecture Behavioral of spi_slave is
    signal mode        : std_logic; -- According to CPOL and CPHA
    signal clk         : std_logic;
    signal bit_counter : std_logic_vector(data_length downto 0);                        -- Active bit indicator
    signal rxBuffer    : std_logic_vector(data_length - 1 downto 0) := (others => '0'); -- Receiver buffer
    signal txBuffer    : std_logic_vector(data_length - 1 downto 0) := (others => '0'); -- Transmit buffer
begin
    busy <= not ss_n;

    mode <= cpol xor cpha;

    process (mode, ss_n, sclk)
    begin
        if (ss_n = '1') then
            clk <= '0';
        else
            if (mode = '1') then
                clk <= sclk;
            else
                clk <= not sclk;
            end if;
        end if;
    end process;

    -- Where is the active bit
    process (ss_n, clk)
    begin
        if (ss_n = '1' or reset_n = '0') then
            bit_counter <= (conv_integer(not cpha) => '1', others => '0'); -- Reset active bit indicator
        else
            if (rising_edge(clk)) then
                bit_counter <= bit_counter(data_length - 1 downto 0) & '0'; -- Left shift active bit indicator
            end if;
        end if;
    end process;

    process (ss_n, clk, rx_enable, reset_n)
    begin
        -- Receive mosi bit
        if (cpha = '0') then
            if (reset_n = '0') then -- Reset the buffer
                rxBuffer <= (others => '0');
            elsif (bit_counter /= "00000000000000010" and falling_edge(clk)) then
                rxBuffer(data_length - 1 downto 0) <= rxBuffer(data_length - 2 downto 0) & mosi; -- Shift in the received bit
            end if;
        else
            if (reset_n = '0') then -- Reset the buffer
                rxBuffer <= (others => '0');
            elsif (bit_counter /= "00000000000000001" and falling_edge(clk)) then
                rxBuffer(data_length - 1 downto 0) <= rxBuffer(data_length - 2 downto 0) & mosi; -- Shift in the received bit
            end if;
        end if;

        -- If user wants the received data output it
        if (reset_n = '0') then
            rx <= (others => '0');
        elsif (ss_n = '1' and rx_enable = '1') then
            rx <= rxBuffer;
        end if;

        -- Transmit registers
        if (reset_n = '0') then
            txBuffer <= (others => '0');
        elsif (ss_n = '1') then
            txBuffer <= tx;
        elsif (bit_counter(data_length) = '0' and rising_edge(clk)) then
            txBuffer(data_length - 1 downto 0) <= txBuffer(data_length - 2 downto 0) & txBuffer(data_length - 1); -- Shift through tx data
        end if;

        -- Transmit miso bit
        if (ss_n = '1' or reset_n = '0') then
            miso <= 'Z';
        elsif (rising_edge(clk)) then
            miso <= txBuffer(data_length - 1);
        end if;
    end process;
end Behavioral;
