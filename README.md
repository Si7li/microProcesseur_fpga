# microProcesseur_fpga

A simple 16-bit accumulator-based microprocessor written in VHDL and implemented on a
**Digilent Nexys 3** board (Xilinx Spartan-6 `xc6slx16-2csg324`) using Xilinx ISE.

## Architecture

- **16-bit data bus, 12-bit address bus** (4096 words of memory)
- **Instruction format**: `[15:12] opcode | [11:0] address`
- **3-state control unit**: `FETCH → DECODE → EXECUTE`

| File                  | Description                                          |
|-----------------------|------------------------------------------------------|
| `microprocesseur.vhd` | CPU top level (structural)                           |
| `machine_etat.vhd`    | Control unit (FSM)                                   |
| `ual.vhd`             | ALU (add, sub, and, or, xor, not, pass)              |
| `acc.vhd`             | Accumulator with zero / sign flags                   |
| `pc.vhd`              | Program counter                                      |
| `ir.vhd`              | Instruction register                                 |
| `muxa.vhd`            | Address mux (PC or IR address)                       |
| `muxb.vhd`            | ALU operand mux                                      |
| `memory.vhd`          | RAM, preloaded with the demo program                 |
| `top_fpga.vhd`        | Nexys 3 wrapper (clock divider, buttons, 7-segment)  |
| `top.ucf`             | Pin constraints for the Nexys 3                      |

## Instruction set

| Opcode | Mnemonic | Operation                     |
|--------|----------|-------------------------------|
| `0000` | LOAD     | `ACC ← mem[addr]`             |
| `0001` | STORE    | `mem[addr] ← ACC`             |
| `0010` | ADD      | `ACC ← ACC + mem[addr]`       |
| `0011` | SUB      | `ACC ← ACC - mem[addr]`       |
| `0100` | AND      | `ACC ← ACC and mem[addr]`     |
| `0101` | OR       | `ACC ← ACC or mem[addr]`      |
| `0110` | JMP      | `PC ← addr`                   |
| `0111` | JZ       | `if ACC = 0  then PC ← addr`  |
| `1000` | JN       | `if ACC < 0  then PC ← addr`  |
| `1001` | JLE      | `if ACC <= 0 then PC ← addr`  |
| `1010` | JGE      | `if ACC >= 0 then PC ← addr`  |

## Demo program

The memory is preloaded with an integer division by repeated subtraction:
`C = A / B`, with `A = 9`, `B = 2` stored at `0x100` and `0x101`.
When the program halts, `C` (`0x102`) holds the quotient **4** and `A` holds the remainder **1**.

## Running on the Nexys 3

1. Open `microProcesseur_fpga.xise` in Xilinx ISE 14.7.
2. Run **Generate Programming File** on `top_fpga`.
3. Program the board with `top_fpga.bit` (Digilent Adept or iMPACT).

| Control       | Function                                                       |
|---------------|----------------------------------------------------------------|
| `BTNS`        | Reset                                                          |
| `SW7` down    | CPU runs freely (~6 Hz)                                        |
| `SW7` up      | Manual mode: each `BTNU` press executes one instruction        |
| 7-segment     | Right to left: `PC`, `A`, `B`, `C` (dot on PC during FETCH)    |
| `LD7`         | `RnW` (read / write)                                           |
| `LD6`–`LD0`   | Address bus                                                    |
