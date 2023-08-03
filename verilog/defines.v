/**
 * Processor defines.
 *
 */

// ISA.
`define INSTRUCTION_WIDTH 32          // Bits of the instructions.
`define INSTRUCTION_OP_WIDTH 7        // Bits of the opcode.
`define INSTRUCTION_OP 31:25          // opcode
`define INSTRUCTION_REGISTER_WIDTH 5  // Bits of the registers.
`define INSTRUCTION_RW_OFFSETHI 24:20 // RW/OffsetHi
`define INSTRUCTION_RS 19:15          // RS
`define INSTRUCTION_RT_OFFSETM 14:10  // RT/OffsetM
`define INSTRUCTION_OFFSETLO 9:0      // OffsetLo

// Operation.
`define NOP 7'b 0000000
// A NOP with a 0 at the end of the instruction is not inserted into the ROB.
// A NOP with a 1 at the end of the instruction is inserted into the ROB.
`define FULL_NOP `INSTRUCTION_WIDTH'b 0
`define FULL_NOP_ROB `INSTRUCTION_WIDTH'b 1

`define ADD 7'b 0000001
`define SUB 7'b 0000010
`define MUL 7'b 0000011
`define OR  7'b 0000100
`define AND 7'b 0000101

`define LDB 7'b 0010000
`define LDW 7'b 0010001
`define STB 7'b 0010010
`define STW 7'b 0010011
`define MOV 7'b 0010100

`define BEQ 7'b 0011000
`define JUMP 7'b 0011001

`define ITLBWRITE 7'b 0100010
`define DTLBWRITE 7'b 0100000
`define IRET 7'b 0100001

// Memory
`define DATA_SIZE 32

`define VIRTUAL_ADDR_WIDTH 32 // 32 Bits
`define PHYSICAL_ADDR_WIDTH 20 // 20 Bits

`define CACHE_LINES_WIDTH 2 // 4 cache lines.
`define CACHE_LINE_WIDTH 128

`define PAGE_SIZE 12 // bits. 4 KB pages.

`define MASK2BITS  32'h00000003
`define MASK1BYTE  32'h000000ff
`define MASK32BITS 32'hffffffff

// Modes.
`define MODE_WIDTH 1
`define SUPERVISOR_MODE 1
`define USER_MODE 0 

// Exceptions.
`define iTLB_EXCEPTION 0
`define dTLB_EXCEPTION 1

`define EXCEPTION_HANDLER_ADDR `PHYSICAL_ADDR_WIDTH'h 2000
