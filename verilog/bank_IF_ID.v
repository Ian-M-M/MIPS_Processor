/**
 * IF-ID register bank.
 *
 */

`include "defines.v"

module bank_IF_ID(input wire clk,                                     // Clock.
                  input wire reset,                                   // 1 -> bank = 0.
                  input wire load,                                    // Overwrite data; 1 -> yes, 0 -> no.
                  input wire [`INSTRUCTION_WIDTH-1:0] instruction_IF, // The instruction in IF.
                  input wire [`VIRTUAL_ADDR_WIDTH-1:0] PC_IF,         // The PC in IF.
                  input wire iTLB_hit_IF,                             // The instrunction in IF has hit on the iTLB?
                  output reg [`INSTRUCTION_WIDTH-1:0] instruction_ID, // The instruction in ID.
                  output reg [`VIRTUAL_ADDR_WIDTH-1:0] PC_ID,         // The PC in IF.
                  output reg iTLB_hit_ID);                            // The instrunction in IF has hit on the iTLB?

    initial begin
        instruction_ID <= 0;

        PC_ID   <= 0;
        iTLB_hit_ID <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_ID <= 0;

            PC_ID   <= 0;
            iTLB_hit_ID <= 0;
        end
        else if (load) begin
            instruction_ID <= instruction_IF;

            PC_ID   <= PC_IF;
            iTLB_hit_ID <= iTLB_hit_IF;
        end
    end
    
endmodule
