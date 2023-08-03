/**
 * EX-LU register bank.
 *
 */

`include "ROB.v"

module bank_EX_LU(input wire clk,                                     // Clock.
                  input wire reset,                                   // 1 -> bank = 0.
                  input wire load,                                    // Overwrite data; 1 -> yes, 0 -> no.
                  input wire [`INSTRUCTION_WIDTH-1:0] instruction_EX, // The instruction code in EX.
                  input wire [`MODE_WIDTH-1:0] mode_EX,               // The mode in EX.
                  input wire [`DATA_SIZE-1:0] ALU_out_EX,             // The ALU_out in EX.
                  input wire [`ROB_WIDTH-1:0] tag_EX,                 // The tag in EX.
                  input wire [`DATA_SIZE-1:0] rs_bus_EX,              // The rs_bus in EX.
                  output reg [`INSTRUCTION_WIDTH-1:0] instruction_LU, // The instruction code in LU.
                  output reg [`MODE_WIDTH-1:0] mode_LU,               // The mode in LU.
                  output reg [`DATA_SIZE-1:0] ALU_out_LU,             // The ALU_out in LU.
                  output reg [`ROB_WIDTH-1:0] tag_LU,                 // The tag in LU.
                  output reg [`DATA_SIZE-1:0] rs_bus_LU);             // The rs_bus in LU.   

    initial begin
        instruction_LU <= 0;

        ALU_out_LU <= 0;
        mode_LU    <= 0;
        rs_bus_LU  <= 0;
        tag_LU     <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_LU <= 0;

            ALU_out_LU <= 0;
            mode_LU    <= 0;
            rs_bus_LU  <= 0;
            tag_LU     <= 0;
        end
        else if (load) begin
            instruction_LU <= instruction_EX;

            ALU_out_LU <= ALU_out_EX;
            mode_LU    <= mode_EX;
            rs_bus_LU  <= rs_bus_EX;
            tag_LU     <= tag_EX;
        end
    end
    
endmodule
