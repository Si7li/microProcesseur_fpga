
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IR is
    port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;                 
        ir_ld  : in  STD_LOGIC;               
        D      : in  STD_LOGIC_VECTOR(15 downto 0); 
        opcode : out STD_LOGIC_VECTOR(3 downto 0);  
        adresse: out STD_LOGIC_VECTOR(11 downto 0) 
    );
end entity IR;

architecture Comportementale of IR is
    signal reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg <= (others => '0');
            elsif ir_ld = '1' then
                reg <= D;                
            end if;
        end if;
    end process;


    opcode  <= reg(15 downto 12);  
    adresse <= reg(11 downto 0);  

end architecture Comportementale;
