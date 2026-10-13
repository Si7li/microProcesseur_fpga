

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UAL is
    port (
        A     : in  STD_LOGIC_VECTOR(15 downto 0);  
        B     : in  STD_LOGIC_VECTOR(15 downto 0);  
        alufs : in  STD_LOGIC_VECTOR(2 downto 0);   
        S     : out STD_LOGIC_VECTOR(15 downto 0)  
    );
end entity UAL;

architecture Combinatoire of UAL is

    constant UAL_ADD  : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant UAL_SUB  : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant UAL_AND  : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant UAL_OR   : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant UAL_XOR  : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant UAL_NOT  : STD_LOGIC_VECTOR(2 downto 0) := "101";
    constant UAL_PASS : STD_LOGIC_VECTOR(2 downto 0) := "110";
    constant UAL_PASSA: STD_LOGIC_VECTOR(2 downto 0) := "111";

begin

    process(A, B, alufs)
    begin
        case alufs is
            when UAL_ADD   => S <= STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
            when UAL_SUB   => S <= STD_LOGIC_VECTOR(unsigned(A) - unsigned(B));
            when UAL_AND   => S <= A AND B;
            when UAL_OR    => S <= A OR  B;
            when UAL_XOR   => S <= A XOR B;
            when UAL_NOT   => S <= NOT A;
            when UAL_PASS  => S <= B;
            when UAL_PASSA => S <= A;
            when others    => S <= (others => '0');
        end case;
    end process;

end architecture Combinatoire;
