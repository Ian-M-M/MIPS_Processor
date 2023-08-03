/**
 * 
 * Register Bank.
 *
 */

`include "defines.v"

module register_bank(input wire clk,                                    // Clock.
                     input wire reset,                                  // Reset (1 -> registers = 0).
                     input wire [`INSTRUCTION_REGISTER_WIDTH-1:0] rs,   // Register selector for read port S.
                     input wire [`INSTRUCTION_REGISTER_WIDTH-1:0] rt,   // Register selector for read port T.
                     input wire [`INSTRUCTION_REGISTER_WIDTH-1:0] rw,   // Register selector for write port.
                     input wire [`DATA_SIZE-1:0] bus_rw,                // Data input of the writting port.
                     input wire reg_write,                              // Write port enabled? (1 -> yes, 0 -> no).
                     output wire [`DATA_SIZE-1:0] bus_rs,               // Data output of the read port S.
                     output wire [`DATA_SIZE-1:0] bus_rt);              // Data output of the read port T.
    
    // 2^INSTRUCTION_REGISTER_WIDTH registers of DATA_SIZE bits.
    localparam NUM_REGS = 2 ** `INSTRUCTION_REGISTER_WIDTH;
    reg [`DATA_SIZE-1:0] reg_file[NUM_REGS - 1:0];
    
    integer i;

    initial begin
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            // reg_file[i] <= i + 1;
            // reg_file[i] <= i;
            reg_file[i] = 0;
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                //reg_file[i] <= i + 1;
                // reg_file[i] <= i;
                reg_file[i] <= 0;
            end
        end
        // if reg_write is 1, write bus_rw data in register rw.
        else if (reg_write == 1 && rw != 0) begin
            reg_file[rw] <= bus_rw;
        end
    end
    // //get data stored at registers rs and rt.
    assign bus_rs = reg_file[rs];
    assign bus_rt = reg_file[rt];
    
endmodule
