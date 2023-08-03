/**
 * (A)rimetic (L)ogic (U)nit (add, sub, and and or).
 *
 */

`include "defines.v"

module ALU(input wire [`DATA_SIZE - 1:0] da,             // data A.
           input wire [`DATA_SIZE - 1:0] db,             // data B.
           input wire [`DATA_SIZE - 1:0] inm,            // offset.
           input wire [`INSTRUCTION_OP_WIDTH - 1:0] op,  // ALU operation selector.
           output wire [`DATA_SIZE-1:0] dout);           // output.

    assign dout = 
    (op == `ADD) ? da + db :
    (op == `SUB) ? da - db :
    (op == `MUL) ? da * db :
    (op == `OR) ? da | db :
    (op == `AND) ? da & db :
    (op == `LDB || op == `LDW) ? da + inm :
    (op == `STB || op == `STW) ? db + inm :
    (op == `MOV) ? da :
    db;

endmodule
