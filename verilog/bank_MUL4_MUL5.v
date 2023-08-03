/**
 * MUL4_MUL5 register bank.
 *
 */
`include "defines.v"
`include "ROB.v"

module bank_MUL4_MUL5(input wire clk,                               // Clock.
                      input wire reset,                             // 1 -> bank = 0.
                      input wire load,                              // Overwrite data; 1 -> yes, 0 -> no.
                      input wire [`DATA_SIZE-1:0] instruction_MUL4, // The instrunction in MUL4.
                      input wire [`DATA_SIZE-1:0] ALU_out_MUL4,     // The ALU-out in MUL4.
                      input wire [`ROB_WIDTH-1:0] tag_MUL4,         // The ROB-tag in MUL4.
                      output reg [`DATA_SIZE-1:0] instruction_MUL5, // The instrunction in MUL5
                      output reg [`DATA_SIZE-1:0] ALU_out_MUL5,     // The ALU-out in MUL5.
                      output reg [`ROB_WIDTH-1:0] tag_MUL5);        // The ROB-tag in MUL5.

    initial begin
        instruction_MUL5 <= 0;
        
        ALU_out_MUL5 <= 0;
        tag_MUL5     <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_MUL5 <= 0;
            
            ALU_out_MUL5 <= 0;
            tag_MUL5     <= 0;
        end
        else if (load) begin
            instruction_MUL5 <= instruction_MUL4;
            
            ALU_out_MUL5 <= ALU_out_MUL4;
            tag_MUL5     <= tag_MUL4;
        end
    end
    
endmodule
