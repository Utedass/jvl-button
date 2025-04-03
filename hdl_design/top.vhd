library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk  : in std_logic;
        rstn : in std_logic;
        en   : in std_logic;
        btn1 : in std_logic;
        btn2 : in std_logic
    );
end entity;

architecture beh of top is
    component generic_clk_en_divider is
        generic (
            divider_bits : integer := 8
        );
        port (
            clk    : in std_logic;
            rstn   : in std_logic;
            en     : in std_logic;
            en_out : out unsigned (divider_bits - 1 downto 0)
        );
    end component;

    component generic_counter is
        generic (
            counter_bits : integer := 8
        );
        port (
            clk       : in std_logic;
            rstn      : in std_logic;
            en        : in std_logic;
            up        : in std_logic;
            down      : in std_logic;
            rst_value : in unsigned (counter_bits - 1 downto 0);
            cnt       : out unsigned (counter_bits - 1 downto 0)
        );
    end component;

    type t_btn_state is (reset, idle, press, pressed, pressed_debounce, release, released, released_debounce);

    signal i_current_state : t_btn_state; -- Registered
    signal i_last_state    : t_btn_state; -- Registered
    signal i_next_state    : t_btn_state; -- Combinatorial

    signal i_en             : std_logic;
    signal i_counter_val    : unsigned (7 downto 0);
    signal i_enable_signals : unsigned (7 downto 0);
    signal i_enable_counter : std_logic;
begin
    -- Combinatorial and connections

    i_enable_counter <= i_enable_signals(4);
    i_en             <= i_enable_signals(7);

    -- Instances

    my_divider : generic_clk_en_divider
    generic map(
        divider_bits => 8
    )
    port map(
        clk    => clk,
        rstn   => rstn,
        en     => '1',
        en_out => i_enable_signals
    );

    my_counter : generic_counter
    generic map(
        counter_bits => 8
    )
    port map(
        clk  => clk,
        rstn => rstn,
        en   => '1',
        up   => '0',
        down => '1',
        rst_value => (others => '0'), -- Starts from zero
        cnt  => i_counter_val
    );

    -- Concurrent process, determine next state
    -- (reset, idle, press, pressed, pressed_debounce, release, released, released_debounce);
    process (i_current_state, btn1, i_cnt) is
    begin
        case i_current_state is
            when idle =>
                if wr = '1' then
                    i_next_state      <= send_start;
                else i_next_state <= i_current_state;
                end if;
            when send_start =>
                i_next_state <= send_data;
            when send_data =>
                if i_cnt = to_unsigned(7, 4) then
                    i_next_state      <= send_stop;
                else i_next_state <= i_current_state;
                end if;
            when send_stop =>
                if wr = '1' then
                    i_next_state      <= send_start;
                else i_next_state <= idle;
                end if;
            when others =>
                reset;
        end case;

    end process;

    process (clk) is
    begin
        if rising_edge(clk) then
            i_last_state    <= i_current_state;
            i_current_state <= i_next_state;
        end if;
    end process;

end architecture;
