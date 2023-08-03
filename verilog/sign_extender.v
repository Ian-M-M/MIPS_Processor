/**
 * Immediate sign extender.
 */

`include "defines.v"

module sign_extender(input wire [`INSTRUCTION_WIDTH-1:0] instruction,    // instruction.
                     output reg [`DATA_SIZE-1:0] out);                   // 32b sign-extended offset.
    
    always @(*) begin
        if (is_load(instruction)) begin
            out[14:0]  = {instruction[`INSTRUCTION_RT_OFFSETM], instruction[`INSTRUCTION_OFFSETLO]};
            out[31:15] = instruction[14] == 0 ? 17'b 00000000000000000 : 17'b 11111111111111111;
        end
        else if (is_store(instruction)) begin
            out[14:0]  = {instruction[`INSTRUCTION_RW_OFFSETHI], instruction[`INSTRUCTION_OFFSETLO]};
            out[31:15] = instruction[14] == 0 ? 17'b 00000000000000000 : 17'b 11111111111111111;
        end
        else if ((instruction[`INSTRUCTION_OP]) == `BEQ) begin
            out[14:0]  = {instruction[`INSTRUCTION_RW_OFFSETHI], instruction[`INSTRUCTION_OFFSETLO]};
            out[31:15] = out[14] == 0 ? 17'b 00000000000000000 : 17'b 11111111111111111;
        end
        else if ((instruction[`INSTRUCTION_OP]) == `JUMP) begin
            out [19:0]  = {instruction[`INSTRUCTION_RW_OFFSETHI],
                           instruction[`INSTRUCTION_RT_OFFSETM],
                           instruction[`INSTRUCTION_OFFSETLO]};
            out [31:20] = out[19] == 0 ? 12'b 000000000000 : 12'b 111111111111;
        end
        else begin
            out = instruction [`INSTRUCTION_OFFSETLO];
        end
    end
endmodule