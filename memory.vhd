library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Memory is
    port (
        clk      : in    STD_LOGIC;
        RnW      : in    STD_LOGIC;
        addr     : in    STD_LOGIC_VECTOR(11 downto 0);
        bus_data : inout STD_LOGIC_VECTOR(15 downto 0)
    );
end entity Memory;

architecture Comportementale of Memory is

    type mem_t is array (0 to 4095) of STD_LOGIC_VECTOR(15 downto 0);

    -- opcode 4 bits -- adresse 12 bits
    -- OP_LOAD  = "0000" ACC = mem[addr]
    -- OP_STORE = "0001" mem[addr] = ACC
    -- OP_ADD   = "0010" ACC = ACC + mem[addr]
    -- OP_SUB   = "0011" ACC = ACC - mem[addr]
    -- OP_JMP   = "0110" PC = addr
    -- OP_JZ    = "0111" if ACC=0  then PC = addr
    -- OP_JN    = "1000" if ACC<0  then PC = addr
    -- OP_JLE   = "1001" if ACC<=0 then PC = addr
    -- OP_JGE   = "1010" if ACC>=0 then PC = addr

    signal mem : mem_t := (


        -- 0x000 : LOAD  0x100    ACC = A
        0 => "0000" & x"100",

        -- 0x001 : SUB   0x101    ACC = A - B
        1 => "0011" & x"101",

        -- 0x002 : JGE   0x004    if A-B >= 0 ? continue loop body
        2 => "1010" & x"004",

        -- 0x003 : JMP   0x009    else ? exit
        3 => "0110" & x"009",

        -- 0x004 : STORE 0x100    A = A - B
        4 => "0001" & x"100",

        -- 0x005 : LOAD  0x102    ACC = C
        5 => "0000" & x"102",

        -- 0x006 : ADD   0x103    ACC = C + 1
        6 => "0010" & x"103",

        -- 0x007 : STORE 0x102    C = C + 1
        7 => "0001" & x"102",

        -- 0x008 : JMP   0x000    goto LOOP
        8 => "0110" & x"000",

        -- 0x009 : JMP   0x009    HALT
        9 => "0110" & x"009",
        16#100# => x"0009",   -- A = 9
        16#101# => x"0002",   -- B =  2
        16#102# => x"0000",   -- C =  0
        16#103# => x"0001",   -- D =  1

        others => x"0000"
    );

begin


    process(clk)
    begin
        if rising_edge(clk) then
            if RnW = '0' then
                mem(to_integer(unsigned(addr))) <= bus_data;
            end if;
        end if;
    end process;


    bus_data <= mem(to_integer(unsigned(addr))) when RnW = '1'
                else (others => 'Z');

end architecture Comportementale;