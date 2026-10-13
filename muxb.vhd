
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUXB is
    port (
        entree0 : in  STD_LOGIC_VECTOR(15 downto 0); 
        entree1 : in  STD_LOGIC_VECTOR(15 downto 0);
        selB    : in  STD_LOGIC;                     
        sortie  : out STD_LOGIC_VECTOR(15 downto 0) 
    );
end entity MUXB;

architecture Combinatoire of MUXB is
begin


    sortie <= entree1 when selB = '1' else entree0;

end architecture Combinatoire;
