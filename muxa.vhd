
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUXA is
    port (
        entree0 : in  STD_LOGIC_VECTOR(11 downto 0);  
        entree1 : in  STD_LOGIC_VECTOR(11 downto 0);
        selA    : in  STD_LOGIC;                 
        sortie  : out STD_LOGIC_VECTOR(11 downto 0) 
    );
end entity MUXA;

architecture Combinatoire of MUXA is
begin


    sortie <= entree1 when selA = '1' else entree0;

end architecture Combinatoire;
