----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/28/2025 02:54:02 PM
-- Design Name:
-- Module Name: pwm - Behavioral
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

entity PWM is
    port (
        duty_cycle : in  std_logic_vector ((24 - 1) downto 0);
        frequency  : in  std_logic_vector ((32 - 1) downto 0);
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        enable     : in  std_logic;
        pwm_out    : out std_logic_vector ((3 - 1) downto 0)
    );
end PWM;

architecture Behavioral of PWM is
    signal counter0       : integer := 0;
    signal counter1       : integer := 0;
    signal counter2       : integer := 0;
    signal prescaler0     : integer := 0;
    signal prescaler1     : integer := 0;
    signal prescaler2     : integer := 0;
    constant counterValue : integer := 255;

    --    signal duty_cycle: std_logic_vector ( ( 24-1 ) downto 0 );
    --    signal frequency:  std_logic_vector ( ( 32-1 ) downto 0 );
    --    signal reset_n:    std_logic;
    --    signal enable:     std_logic;

    --    component vio_0 is
    --    port (
    --        clk       : in std_logic;
    --        probe_out0: out	std_logic_vector ( ( 24-1 ) downto 0 );
    --        probe_out1: out	std_logic_vector ( ( 32-1 ) downto 0 );
    --        probe_out2: out	std_logic;
    --        probe_out3: out std_logic
    --    );
    --    end component;

begin
    --    vio: vio_0 port map (
    --        clk => clk,
    --        probe_out0 => duty_cycle,
    --        probe_out1 => frequency,
    --        probe_out2 => reset_n,
    --        probe_out3 => enable
    --    );

    red : process (reset_n, clk)
    begin
        if (reset_n = '0') then
            pwm_out(0) <= '0';
            counter0   <= 0;
        elsif rising_edge(clk) then
            if (enable = '1') then
                if (prescaler0 >= to_integer(unsigned(frequency))) then
                    prescaler0 <= 0;

                    if (counter0 >= counterValue) then
                        counter0 <= 0;
                    else
                        counter0 <= counter0 + 1;
                    end if;
                else
                    prescaler0 <= prescaler0 + 1;
                end if;

                if (counter0 < to_integer(unsigned(duty_cycle(23 downto 20)))) then
                    pwm_out(0) <= '1';
                else
                    pwm_out(0) <= '0';
                end if;
            else
                prescaler0 <= 0;
                counter0   <= 0;
                pwm_out(0) <= '0';
            end if;
        end if;
    end process;

    green : process (reset_n, clk)
    begin
        if (reset_n = '0') then
            pwm_out(1) <= '0';
            counter1   <= 0;
        elsif rising_edge(clk) then
            if (enable = '1') then
                if (prescaler1 >= to_integer(unsigned(frequency))) then
                    prescaler1 <= 0;

                    if (counter1 >= counterValue) then
                        counter1 <= 0;
                    else
                        counter1 <= counter1 + 1;
                    end if;
                else
                    prescaler1 <= prescaler1 + 1;
                end if;

                if (counter1 < to_integer(unsigned(duty_cycle(15 downto 12)))) then
                    pwm_out(1) <= '1';
                else
                    pwm_out(1) <= '0';
                end if;
            else
                prescaler1 <= 0;
                counter1   <= 0;
                pwm_out(1) <= '0';
            end if;
        end if;
    end process;

    blue : process (reset_n, clk)
    begin
        if (reset_n = '0') then
            pwm_out(2) <= '0';
            counter2   <= 0;
        elsif rising_edge(clk) then
            if (enable = '1') then
                if (prescaler2 >= to_integer(unsigned(frequency))) then
                    prescaler2 <= 0;

                    if (counter2 >= counterValue) then
                        counter2 <= 0;
                    else
                        counter2 <= counter2 + 1;
                    end if;
                else
                    prescaler2 <= prescaler2 + 1;
                end if;

                if (counter2 < to_integer(unsigned(duty_cycle(7 downto 4)))) then
                    pwm_out(2) <= '1';
                else
                    pwm_out(2) <= '0';
                end if;
            else
                prescaler2 <= 0;
                counter2   <= 0;
                pwm_out(2) <= '0';
            end if;
        end if;
    end process;
end Behavioral;
