library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MachineEtat is
    port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;

        opcode : in  STD_LOGIC_VECTOR(3 downto 0);
        accZ   : in  STD_LOGIC; 
        acc15  : in  STD_LOGIC; 

        RnW    : out STD_LOGIC;
        selA   : out STD_LOGIC;  
        selB   : out STD_LOGIC; 
        pc_ld  : out STD_LOGIC;  
        ir_ld  : out STD_LOGIC;  
        acc_ld : out STD_LOGIC;  
        acc_oe : out STD_LOGIC;  
        alufs  : out STD_LOGIC_VECTOR(2 downto 0)
    );
end entity MachineEtat;

architecture FSM of MachineEtat is

    type etat_t is (FETCH, DECODE, EXECUTE);
    signal etat : etat_t := FETCH;

    constant OP_LOAD  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant OP_STORE : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant OP_ADD   : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant OP_SUB   : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    constant OP_AND   : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant OP_OR    : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    constant OP_JMP   : STD_LOGIC_VECTOR(3 downto 0) := "0110";
    constant OP_JZ    : STD_LOGIC_VECTOR(3 downto 0) := "0111";
    constant OP_JN    : STD_LOGIC_VECTOR(3 downto 0) := "1000"; 
    constant OP_JLE   : STD_LOGIC_VECTOR(3 downto 0) := "1001"; 
    constant OP_JGE   : STD_LOGIC_VECTOR(3 downto 0) := "1010"; 
    constant UAL_ADD  : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant UAL_SUB  : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant UAL_AND  : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant UAL_OR   : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant UAL_PASS : STD_LOGIC_VECTOR(2 downto 0) := "110";
    constant UAL_NOP  : STD_LOGIC_VECTOR(2 downto 0) := "111";

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                etat <= FETCH;
            else
                case etat is
                    when FETCH   => etat <= DECODE;
                    when DECODE  => etat <= EXECUTE;
                    when EXECUTE => etat <= FETCH;
                    when others  => etat <= FETCH;
                end case;
            end if;
        end if;
    end process;

    process(etat, opcode, accZ)
    begin

        RnW    <= '1';           
        selA   <= '0';
        selB   <= '0';
        pc_ld  <= '0';
        ir_ld  <= '0';
        acc_ld <= '0';
        acc_oe <= '0';
        alufs  <= UAL_NOP;

        case etat is
            when FETCH =>
                RnW   <= '1'; 
                selA  <= '1';  
                ir_ld <= '1';  
                pc_ld <= '1';  


            when DECODE =>
                selA <= '0';    
                RnW  <= '1';    

                if opcode = OP_STORE then
                    RnW    <= '0';   
                    acc_oe <= '1'; 
                end if;

                if opcode = OP_JMP or opcode = OP_JZ or opcode = OP_JN or opcode = OP_JLE or opcode = OP_JGE then
                    RnW <= '1';   
                end if;

            -- te7sb UAL + mise a jour ACC ou PC

            when EXECUTE =>
                case opcode is
                    when OP_LOAD =>
                        selB   <= '0';      
                        alufs  <= UAL_PASS;
                        acc_ld <= '1';     

                    --mem[addr] ? ACC
                    when OP_STORE =>
                        acc_oe <= '1';     
                        RnW    <= '0';

                   --ACC ? ACC + mem[addr]
  
                    when OP_ADD =>
                        selB   <= '0';
                        alufs  <= UAL_ADD;
                        acc_ld <= '1';

                    --ACC ? ACC - mem[addr]
                    when OP_SUB =>
                        selB   <= '0';
                        alufs  <= UAL_SUB;
                        acc_ld <= '1';

                    --ACC ? ACC AND mem[addr]
                    when OP_AND =>
                        selB   <= '0';
                        alufs  <= UAL_AND;
                        acc_ld <= '1';

                    --ACC ? ACC OR mem[addr]
                    when OP_OR =>
                        selB   <= '0';
                        alufs  <= UAL_OR;
                        acc_ld <= '1';

                    -- PC ? addr

                    when OP_JMP =>
                        selA  <= '0';
                        pc_ld <= '1';

                    --PC addr seulement si ACC = 0
                    when OP_JZ =>
                        if accZ = '1' then
                            selA  <= '0';
                            pc_ld <= '1';
                        end if;

                    --PC addr seulement si ACC < 0 (bit15 = 1)
                    when OP_JN =>
                        if acc15 = '1' then
                            selA  <= '0';
                            pc_ld <= '1';
                        end if;

                    --PC ? addr si ACC <= 0 (acc15=1 ou accZ=1)
                    when OP_JLE =>
                        if acc15 = '1' or accZ = '1' then
                            selA  <= '0';
                            pc_ld <= '1';
                        end if;

                    --PC ? addr si ACC >= 0 (acc15=0)
                    when OP_JGE =>
                        if acc15 = '0' then
                            selA  <= '0';
                            pc_ld <= '1';
                        end if;

                    when others => null;

                end case;

            when others => null;

        end case;
    end process;

end architecture FSM;
