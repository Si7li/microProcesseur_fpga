library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity PC is

    port (

        clk   : in  STD_LOGIC;

        reset : in  STD_LOGIC;

        pc_ld : in  STD_LOGIC;

        selA  : in  STD_LOGIC;                    

        D     : in  STD_LOGIC_VECTOR(11 downto 0);

        Q     : out STD_LOGIC_VECTOR(11 downto 0)

    );

end entity PC;

architecture Comportementale of PC is

    signal reg : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

begin

    process(clk)

    begin

        if rising_edge(clk) then

            if reset = '1' then

                reg <= (others => '0');

            elsif pc_ld = '1' then

                if selA = '1' then

                    -- incrementer PC

                    reg <= STD_LOGIC_VECTOR(unsigned(reg) + 1);

                else

                    -- charger adresse depuis IR

                    reg <= D;

                end if;

            end if;

        end if;

    end process;

    Q <= reg;

end architecture Comportementale;
