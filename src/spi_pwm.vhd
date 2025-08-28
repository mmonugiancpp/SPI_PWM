----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 08/28/2025 10:42:54 AM
-- Design Name:
-- Module Name: spi_pwm - Behavioral
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_pwm is
    port (
        reset_n   : in  std_logic;                           -- Asynchronous active low reset
        cpol      : in  std_logic;                           -- Clock polarity mode
        cpha      : in  std_logic;                           -- Clock phase mode
        sclk      : in  std_logic;                           -- Spi clk
        ss_n      : in  std_logic;                           -- Slave select
        mosi      : in  std_logic;                           -- Master out slave in
        miso      : out std_logic;                           -- Master in slave out
        rx_enable : in  std_logic;                           -- Enable signal to wire rxBuffer to outside
        tx        : in  std_logic_vector((32 - 1) downto 0); -- Data to transmit
        rx        : out std_logic_vector((32 - 1) downto 0); -- Data received
        busy      : out std_logic := '0';                    -- Slave busy signal
        pwm_clk   : in  std_logic;
        pwm_out   : out std_logic_vector ((3 - 1) downto 0)
    );
end spi_pwm;

architecture Behavioral of spi_pwm is
    signal rx_buffer : std_logic_vector((32 - 1) downto 0) := (others => '0');

    -- PWM Registers
    signal pwm_enable : std_logic                           := '0';
    signal duty_cycle : std_logic_vector((24 - 1) downto 0) := (others => '0');
    signal frequency  : std_logic_vector((32 - 1) downto 0) := (others => '0');
begin
    rx <= rx_buffer;

    process (rx_buffer)
    begin
        case rx_buffer(31 downto 30) is
            when "00" =>
                pwm_enable <= rx_buffer(0);
            when "01" =>
                duty_cycle <= rx_buffer(23 downto 0);
            when "10" =>
                frequency <= "00" & rx_buffer(29 downto 0);
            when others =>
        end case;
    end process;

    -- SPI slave
    spi_slave : entity work.spi_slave(Behavioral)
        generic map(
            data_length => 32
        )
        port map(
            reset_n   => reset_n,
            cpol      => cpol,
            cpha      => cpha,
            sclk      => sclk,
            ss_n      => ss_n,
            mosi      => mosi,
            miso      => miso,
            rx_enable => rx_enable,
            tx        => tx,
            rx        => rx_buffer,
            busy      => busy
        );

    -- PWM Logic
    pwm_module : entity work.PWM(Behavioral)
        port map(
            duty_cycle => duty_cycle,
            frequency  => frequency,
            clk        => pwm_clk,
            reset_n    => reset_n,
            enable     => pwm_enable,
            pwm_out    => pwm_out
        );

end Behavioral;
