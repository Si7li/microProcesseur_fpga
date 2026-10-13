
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ACC is
    port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;                   
        acc_ld  : in  STD_LOGIC;                    
        acc_oe  : in  STD_LOGIC;                     
        D       : in  STD_LOGIC_VECTOR(15 downto 0); 
        Q       : out STD_LOGIC_VECTOR(15 downto 0); 
        accZ    : out STD_LOGIC;                      
        acc15   : out STD_LOGIC;                     
        bus_data: out STD_LOGIC_VECTOR(15 downto 0)  
    );
end entity ACC;

architecture Comportementale of ACC is
    signal reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin


    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg <= (others => '0');
            elsif acc_ld = '1' then
                reg <= D;  
            end if;
        end if;
    end process;


    Q     <= reg;
    accZ  <= '1' when reg = (reg'range => '0') else '0';
    acc15 <= reg(15);                                      

    bus_data <= reg when acc_oe = '1' else (others => 'Z');

end architecture Comportementale;
