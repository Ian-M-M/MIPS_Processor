/**
 * ROB testbench.
 *
 */

`include "defines.v"
`include "ROB.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module ROB_testbench();
    
    localparam CLK_period = 20;
    
    reg clk, reset;
    
    reg [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_ALU = 0;
    reg [`ROB_WIDTH - 1:0] tag_ALU;
    reg [`ROB_STATE_WIDTH - 1:0] state_ALU;
    reg [`PHYSICAL_ADDR_WIDTH - 1:0] addr_ALU;
    reg [`DATA_SIZE - 1:0] value_ALU;
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] pc_ALU;
    reg [`INSTRUCTION_WIDTH - 1:0] instr_ALU;
    
    reg [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_LU = 0;
    reg [`ROB_WIDTH - 1:0] tag_LU;
    reg [`ROB_STATE_WIDTH - 1:0] state_LU;
    reg [`PHYSICAL_ADDR_WIDTH - 1:0] addr_LU;
    reg [`DATA_SIZE - 1:0] value_LU;
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] pc_LU;
    reg [`INSTRUCTION_WIDTH - 1:0] instr_LU;
    
    reg [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_MUL4 = 0;
    reg [`ROB_WIDTH - 1:0] tag_MUL4;
    reg [`ROB_STATE_WIDTH - 1:0] state_MUL4;
    reg [`PHYSICAL_ADDR_WIDTH - 1:0] addr_MUL4;
    reg [`DATA_SIZE - 1:0] value_MUL4;
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] pc_MUL4;
    reg [`INSTRUCTION_WIDTH - 1:0] instr_MUL4;
    
    reg [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_WB = 0;
    reg [`ROB_WIDTH - 1:0] tag_WB;
    reg [`ROB_STATE_WIDTH - 1:0] state_WB;
    reg [`PHYSICAL_ADDR_WIDTH - 1:0] addr_WB;
    reg [`DATA_SIZE - 1:0] value_WB;
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] pc_WB;
    reg [`INSTRUCTION_WIDTH - 1:0] instr_WB;

    reg [`INSTRUCTION_REGISTER_WIDTH - 1:0] rs;
    reg [`INSTRUCTION_REGISTER_WIDTH - 1:0] rt;
    wire [`BYPASS_STATE_WIDTH - 1:0] rs_state;
    wire [`BYPASS_STATE_WIDTH - 1:0] rt_state;
    wire [`DATA_SIZE - 1:0] rs_value;
    wire [`DATA_SIZE - 1:0] rt_value;
    
    reg  [`ROB_WIDTH - 1:0] tag_read;
    wire [`ROB_STATE_WIDTH - 1:0] state_read;
    wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_read;
    wire [`DATA_SIZE - 1:0] value_read;
    wire [`VIRTUAL_ADDR_WIDTH - 1:0] pc_read;
    wire [`INSTRUCTION_WIDTH - 1:0] instr_read;
   
    reg [`ROB_WIDTH - 1:0] head;
    reg [`ROB_WIDTH - 1:0] tail;

    wire [`ROB_WIDTH:0] empty_entries;
    
    ROB rob(
    .clk(clk),
    .reset(reset),
    .write_ALU(write_ALU),
    .tag_ALU(tag_ALU),
    .state_ALU(state_ALU),
    .addr_ALU(addr_ALU),
    .value_ALU(value_ALU),
    .pc_ALU(pc_ALU),
    .instr_ALU(instr_ALU),
    
    .write_LU(write_LU),
    .tag_LU(tag_LU),
    .state_LU(state_LU),
    .addr_LU(addr_LU),
    .value_LU(value_LU),
    .pc_LU(pc_LU),
    .instr_LU(instr_LU),
    
    .write_MUL4(write_MUL4),
    .tag_MUL4(tag_MUL4),
    .state_MUL4(state_MUL4),
    .addr_MUL4(addr_MUL4),
    .value_MUL4(value_MUL4),
    .pc_MUL4(pc_MUL4),
    .instr_MUL4(instr_MUL4),
    
    .write_WB(write_WB),
    .tag_WB(tag_WB),
    .state_WB(state_WB),
    .addr_WB(addr_WB),
    .value_WB(value_WB),
    .pc_WB(pc_WB),
    .instr_WB(instr_WB),

    .head(head),
    .tail(tail),

    .rs(rs),
    .rt(rt),
    .rs_state(rs_state),
    .rt_state(rt_state),
    .rs_value(rs_value),
    .rt_value(rt_value),
    
    .tag_read(tag_read),
    .state_read(state_read),
    .addr_read(addr_read),
    .value_read(value_read),
    .pc_read(pc_read),
    .instr_read(instr_read),
    
    .empty_entries(empty_entries));
    
    initial begin
        reset = 0;
    end
    
    always begin
        clk = 1; // high edge
        #(CLK_period / 2); // wait for period
        
        clk = 0; // low edge
        #(CLK_period / 2); // wait for period
    end
    
    always @(posedge clk) begin
        head = 0;
        tail = 0;

        rs = 0;
        rt = 1;
        
        // Write ALU
        write_ALU = 
        `ROB_WRITE_ENABLE_STATE_MASK |
        `ROB_WRITE_ENABLE_ADDR_MASK  |
        `ROB_WRITE_ENABLE_VALUE_MASK |
        `ROB_WRITE_ENABLE_PC_MASK    |
        `ROB_WRITE_ENABLE_INSTR_MASK;
        
        tag_ALU   = 0;
        state_ALU = `ROB_STATE_BUSY;
        addr_ALU  = 1;
        value_ALU = 1;
        pc_ALU    = 1;
        instr_ALU = 32'b 0000001_00000_00001_00010_0000000000; // ADD r0 <- r1 + r2
        
        // Write LU
        write_LU = 
        `ROB_WRITE_ENABLE_STATE_MASK |
        `ROB_WRITE_ENABLE_ADDR_MASK  |
        `ROB_WRITE_ENABLE_VALUE_MASK |
        `ROB_WRITE_ENABLE_PC_MASK    |
        `ROB_WRITE_ENABLE_INSTR_MASK;
        
        tag_LU   = 1;
        state_LU = `ROB_STATE_BUSY;
        addr_LU  = 2;
        value_LU = 2;
        pc_LU    = 2;
        instr_LU    = 2;
        
        // Write MUL4
        write_MUL4 = 
        `ROB_WRITE_ENABLE_STATE_MASK |
        `ROB_WRITE_ENABLE_ADDR_MASK  |
        `ROB_WRITE_ENABLE_VALUE_MASK |
        `ROB_WRITE_ENABLE_PC_MASK    |
        `ROB_WRITE_ENABLE_INSTR_MASK;
        
        tag_MUL4   = 2;
        state_MUL4 = `ROB_STATE_BUSY;
        addr_MUL4  = 3;
        value_MUL4 = 3;
        pc_MUL4    = 3;
        instr_MUL4    = 3;
        
        // Write WB
        write_WB = 
        `ROB_WRITE_ENABLE_STATE_MASK |
        `ROB_WRITE_ENABLE_ADDR_MASK  |
        `ROB_WRITE_ENABLE_VALUE_MASK |
        `ROB_WRITE_ENABLE_PC_MASK    |
        `ROB_WRITE_ENABLE_INSTR_MASK;
        
        tag_WB   = 3;
        state_WB = `ROB_STATE_BUSY;
        addr_WB  = 4;
        value_WB = 4;
        pc_WB    = 4;
        instr_WB    = 4;
        
        // Read the WB entry.
        tag_read = 3;
        tail = 3;
        
        #(CLK_period * 2);
    
        write_ALU  = 0;
        write_LU   = 0;
        write_MUL4 = 0;
        write_WB   = 0;
        
        #(CLK_period * 10);
        
        // Write state only in WB entry.
        write_WB = `ROB_WRITE_ENABLE_STATE_MASK;
        
        tag_WB   = 3;
        state_WB = 0;
        addr_WB  = 10;
        value_WB = 10;
        pc_WB    = 10;
        instr_WB    = 10;

        tail = 2;

        // Complete ALU instruction
        write_ALU = `ROB_WRITE_ENABLE_STATE_MASK;
        tag_ALU = 0;
        state_ALU = `ROB_STATE_COMPLETE;
        
        #(CLK_period * 100000);
    end
endmodule
