/**
 * ID-EX register bank.
 *
 */

`include "defines.v"

module bank_ID_EX(input wire clk,                                     // Clock.
                  input wire reset,                                   // 1 -> bank = 0.
                  input wire load,                                    // Overwrite data; 1 -> yes, 0 -> no.
                  input wire [`INSTRUCTION_WIDTH-1:0] instruction_ID, // The instrunction in ID.
                  input wire [`MODE_WIDTH-1:0] mode_ID,               // The mode in ID.
                  input wire [`DATA_SIZE-1:0] bus_rs_ID,              // The bus-rs in ID.
                  input wire [`DATA_SIZE-1:0] bus_rt_ID,              // the bus-rt in ID.
                  input wire [`VIRTUAL_ADDR_WIDTH-1:0] PC_ID,         // The PC in ID.
                  input wire iTLB_hit_ID,                             // The instrunction in ID has hit on the iTLB?
                  input wire [`DATA_SIZE-1:0] inm_ext_ID,             // The extended inm in ID.
                  output reg [`INSTRUCTION_WIDTH-1:0] instruction_EX, // The instrunction in EX.
                  output reg [`MODE_WIDTH-1:0] mode_EX,               // The mode in EX.
                  output reg [`DATA_SIZE-1:0] bus_rs_EX,              // The bus-rs in EX.
                  output reg [`DATA_SIZE-1:0] bus_rt_EX,              // the bus-rt in EX.
                  output reg [`VIRTUAL_ADDR_WIDTH-1:0] PC_EX,         // The PC in EX.
                  output reg iTLB_hit_EX,                             // The instrunction in EX has hit on the iTLB?
                  output reg [`DATA_SIZE-1:0] inm_ext_EX);            // The extended inm in EX.
                
    initial begin
        instruction_EX <= 0;

        mode_EX      <= 0;
        bus_rs_EX    <= 0;
        bus_rt_EX    <= 0;
        PC_EX        <= 0;
        iTLB_hit_EX  <= 0;
        inm_ext_EX   <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_EX <= 0;

            mode_EX      <= 0;
            bus_rs_EX    <= 0;
            bus_rt_EX    <= 0;
            PC_EX        <= 0;
            iTLB_hit_EX  <= 0;
            inm_ext_EX   <= 0;
        end
        else if (load) begin
            instruction_EX <= instruction_ID;

            mode_EX      <= mode_ID;
            bus_rs_EX    <= bus_rs_ID;
            bus_rt_EX    <= bus_rt_ID;
            PC_EX        <= PC_ID;
            iTLB_hit_EX  <= iTLB_hit_ID;
            inm_ext_EX   <= inm_ext_ID;
        end
    end
    
endmodule
