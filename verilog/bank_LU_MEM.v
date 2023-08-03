/**
 * LU-MEM register bank.
 *
 */

`include "defines.v"
`include "ROB.v"

module bank_LU_MEM(input wire clk,                                      // Clock.
                   input wire reset,                                    // 1 -> bank = 0.
                   input wire load,                                     // Overwrite data; 1 -> yes, 0 -> no.
                   input wire [`INSTRUCTION_WIDTH-1:0] instruction_LU,  // The instruction code in LU.
                   input wire [`PHYSICAL_ADDR_WIDTH-1:0] paddr_LU,      // The paddr in LU.
                   input wire [`DATA_SIZE-1:0] ALU_out_LU,              // The ALU-out in LU.
                   input wire [`DATA_SIZE-1:0] rs_bus_LU,               // The rs-bus in LU.
                   input wire [`ROB_WIDTH-1:0] tag_LU,                  // The ROB-tag of the instruction in LU.
                   input wire hit_dTLB_LU,                              // The instrunction in LU has hit on the dTLB?
                   input wire hit_dCache_LU,                            // The instrunction in LU has hit on dCache?
                   output reg [`INSTRUCTION_WIDTH-1:0] instruction_MEM, // The instruction code in MEM.
                   output reg [`PHYSICAL_ADDR_WIDTH-1:0] paddr_MEM,     // The paddr in MEM.
                   output reg [`DATA_SIZE-1:0] ALU_out_MEM,             // The ALU-out in MEM.
                   output reg [`DATA_SIZE-1:0] rs_bus_MEM,              // The rs-bus in MEM.
                   output reg [`ROB_WIDTH-1:0] tag_MEM,                 // The ROB-tag of the instruction in MEM.
                   output reg hit_dTLB_MEM,                             // The instrunction in MEM has hit on the dTLB?
                   output reg hit_dCache_MEM);                          // The instrunction in MEM has hit on dCache?

    initial begin
        instruction_MEM <= 0;

        hit_dCache_MEM  <= 0;
        paddr_MEM       <= 0;
        ALU_out_MEM     <= 0;
        rs_bus_MEM      <= 0;
        tag_MEM         <= 0;
        hit_dTLB_MEM    <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_MEM <= 0;

            hit_dCache_MEM  <= 0;
            paddr_MEM       <= 0;
            ALU_out_MEM     <= 0;
            rs_bus_MEM      <= 0;
            tag_MEM         <= 0;
            hit_dTLB_MEM    <= 0;
        end
        else if (load) begin
            instruction_MEM <= instruction_LU;

            hit_dCache_MEM  <= hit_dCache_LU;
            paddr_MEM       <= paddr_LU;
            ALU_out_MEM     <= ALU_out_LU;
            rs_bus_MEM      <= rs_bus_LU;
            tag_MEM         <= tag_LU;
            hit_dTLB_MEM    <= hit_dTLB_LU;
        end
    end
    
endmodule
