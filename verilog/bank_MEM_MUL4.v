/**
 * MEM-MUL4 register bank.
 *
 */

`include "defines.v"
`include "ROB.v"

module bank_MEM_MUL4(input wire clk,                                       // Clock.
                     input wire reset,                                     // 1 -> bank = 0.
                     input wire load,                                      // Overwrite data; 1 -> yes, 0 -> no.
                     input wire [`INSTRUCTION_WIDTH-1:0] instruction_MEM,  // The instruction in MEM.
                     input wire [`DATA_SIZE-1:0] ALU_out_MEM,              // The ALU-out in MEM.
                     input wire [`ROB_WIDTH-1:0] tag_MEM,                  // The ROB-tag in MEM.
                     output reg [`INSTRUCTION_WIDTH-1:0] instruction_MUL4, // The instruction in MUL4.
                     output reg [`DATA_SIZE-1:0] ALU_out_MUL4,             // The ALU-out in MUL4.
                     output reg [`ROB_WIDTH-1:0] tag_MUL4);                // The ROB-tag in MUL4.

    initial begin
        instruction_MUL4 <= 0;

        ALU_out_MUL4     <= 0;
        tag_MUL4         <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_MUL4 <= 0;

            ALU_out_MUL4     <= 0;
            tag_MUL4         <= 0;
        end
        else if (load) begin
            instruction_MUL4 <= instruction_MEM;

            ALU_out_MUL4     <= ALU_out_MEM;
            tag_MUL4         <= tag_MEM;
        end
    end
    
endmodule
