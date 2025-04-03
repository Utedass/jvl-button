library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end entity;

architecture beh of top_tb is
    component top is
        port (
            clk  : in std_logic;
            rstn : in std_logic;
            en   : in std_logic;
            btn1 : in std_logic;
            btn2 : in std_logic
        );
    end component;

    constant freq           : integer := 50; -- MHz
    constant period         : time    := 1000 / freq * 1 ns;
    constant half_period    : time    := period / 2;
    signal num_rising_edges : integer := 0;

    signal clock  : std_logic := '0';
    signal enable : std_logic;
    signal resetn : std_logic;

    signal btn1 : std_logic;
    signal btn2 : std_logic;

    signal running : boolean := true;
begin
    running <= true, false after 530 * period;

    resetn <= '1', '0' after 2 * period, '1' after 3 * period;

    enable <= '0', '1' after 5 * period;

    DUT : top
    port map(
        clk  => clock,
        rstn => resetn,
        en   => enable,
        btn1 => btn1,
        btn2 => btn2
    );

    -- clock process
    process is
    begin
        if running then
            wait for half_period;
            clock <= not clock;
        else report "End of simulation!";
            wait;
        end if;
    end process;
    process (clock) is
    begin
        if rising_edge(clock) then
            if resetn = '0' then
                num_rising_edges <= 0;
            elsif enable = '1' then
                num_rising_edges <= num_rising_edges + 1;
            else -- Explicit no change
                num_rising_edges <= num_rising_edges;
            end if;
        end if;
    end process;

    -- Automated checks
    process (clock) is
    begin
        if rising_edge(clock) then
            --and num_rising_edges > 1 then
            --assert (divided_en and divided_en_last) = 0 report "Enable signal longer than one clock signal detected!" severity error;
        end if;
    end process;
end architecture;
