library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MicroProcesseur is
    port (
        clk      : in    STD_LOGIC;
        reset    : in    STD_LOGIC;
        bus_addr : out   STD_LOGIC_VECTOR(11 downto 0);
        bus_data : inout STD_LOGIC_VECTOR(15 downto 0);
        RnW      : out   STD_LOGIC
    );
end entity MicroProcesseur;

architecture Structurelle of MicroProcesseur is

    signal sig_selA    : STD_LOGIC;
    signal sig_selB    : STD_LOGIC;
    signal sig_pc_ld   : STD_LOGIC;
    signal sig_ir_ld   : STD_LOGIC;
    signal sig_acc_ld  : STD_LOGIC;
    signal sig_acc_oe  : STD_LOGIC;
    signal sig_alufs   : STD_LOGIC_VECTOR(2 downto 0);
    signal sig_opcode  : STD_LOGIC_VECTOR(3 downto 0);
    signal sig_accZ    : STD_LOGIC;
    signal sig_acc15   : STD_LOGIC;

    signal sig_pc_q    : STD_LOGIC_VECTOR(11 downto 0);
    signal sig_ir_addr : STD_LOGIC_VECTOR(11 downto 0);
    signal sig_muxa_s  : STD_LOGIC_VECTOR(11 downto 0);
    signal sig_muxb_s  : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_acc_q   : STD_LOGIC_VECTOR(15 downto 0);
    signal sig_ual_s   : STD_LOGIC_VECTOR(15 downto 0);

    component MUXA is
        port (
            entree0 : in  STD_LOGIC_VECTOR(11 downto 0);
            entree1 : in  STD_LOGIC_VECTOR(11 downto 0);
            selA    : in  STD_LOGIC;
            sortie  : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    component MUXB is
        port (
            entree0 : in  STD_LOGIC_VECTOR(15 downto 0);
            entree1 : in  STD_LOGIC_VECTOR(15 downto 0);
            selB    : in  STD_LOGIC;
            sortie  : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component UAL is
        port (
            A     : in  STD_LOGIC_VECTOR(15 downto 0);
            B     : in  STD_LOGIC_VECTOR(15 downto 0);
            alufs : in  STD_LOGIC_VECTOR(2 downto 0);
            S     : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    -- PC mis a jour avec port selA
    component PC is
        port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            pc_ld : in  STD_LOGIC;
            selA  : in  STD_LOGIC;
            D     : in  STD_LOGIC_VECTOR(11 downto 0);
            Q     : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    component IR is
        port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            ir_ld  : in  STD_LOGIC;
            D      : in  STD_LOGIC_VECTOR(15 downto 0);
            opcode : out STD_LOGIC_VECTOR(3 downto 0);
            adresse: out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    component ACC is
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
    end component;

    component MachineEtat is
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
    end component;

begin

    U_ME : MachineEtat port map (
        clk    => clk,      reset  => reset,
        opcode => sig_opcode, accZ => sig_accZ, acc15 => sig_acc15,
        RnW    => RnW,      selA   => sig_selA,  selB  => sig_selB,
        pc_ld  => sig_pc_ld, ir_ld => sig_ir_ld,
        acc_ld => sig_acc_ld, acc_oe => sig_acc_oe,
        alufs  => sig_alufs
    );

    -- MUXA : selA='1' => PC value sur bus_addr (FETCH)
    --        selA='0' => IR address sur bus_addr (EXECUTE data access)
    U_MUXA : MUXA port map (
        entree0 => sig_ir_addr,
        entree1 => sig_pc_q,
        selA    => sig_selA,
        sortie  => sig_muxa_s
    );

    -- PC : reçoit maintenant selA pour savoir s'il faut incrementer ou sauter
    U_PC : PC port map (
        clk   => clk,   reset => reset,
        pc_ld => sig_pc_ld,
        selA  => sig_selA,
        D     => sig_ir_addr,   -- adresse de saut (JMP/JZ)
        Q     => sig_pc_q
    );

    U_IR : IR port map (
        clk     => clk,       reset   => reset,
        ir_ld   => sig_ir_ld,
        D       => bus_data,
        opcode  => sig_opcode,
        adresse => sig_ir_addr
    );

    U_MUXB : MUXB port map (
        entree0 => bus_data,
        entree1 => sig_acc_q,
        selB    => sig_selB,
        sortie  => sig_muxb_s
    );

    U_UAL : UAL port map (
        A     => sig_acc_q,
        B     => sig_muxb_s,
        alufs => sig_alufs,
        S     => sig_ual_s
    );

    U_ACC : ACC port map (
        clk      => clk,       reset  => reset,
        acc_ld   => sig_acc_ld, acc_oe => sig_acc_oe,
        D        => sig_ual_s,
        Q        => sig_acc_q,
        accZ     => sig_accZ,
        acc15    => sig_acc15,
        bus_data => bus_data
    );

    bus_addr <= sig_muxa_s;

end architecture Structurelle;
