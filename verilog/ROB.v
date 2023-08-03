/**
 * ROB
 *
 */

`include "defines.v"

`define ROB_STATE_WIDTH 3

// Possible states of a ROB entry.
`define ROB_STATE_UNUSED `ROB_STATE_WIDTH'd 0
`define ROB_STATE_BUSY `ROB_STATE_WIDTH'd 1
`define ROB_STATE_EXCEPTION `ROB_STATE_WIDTH'd 2
`define ROB_STATE_WAITING_CACHE `ROB_STATE_WIDTH'd 3
`define ROB_STATE_ACCESSING_CACHE `ROB_STATE_WIDTH'd 4
`define ROB_STATE_COMPLETE `ROB_STATE_WIDTH'd 5

`define ROB_WRITE_ENABLE_WIDTH 6 // Write enable signal bits.

// Meaning of each bit of the write enable signal.
`define ROB_WRITE_ENABLE_STATE_BIT 5
`define ROB_WRITE_ENABLE_MODE_BIT 4
`define ROB_WRITE_ENABLE_ADDR_BIT 3
`define ROB_WRITE_ENABLE_VALUE_BIT 2
`define ROB_WRITE_ENABLE_PC_BIT 1
`define ROB_WRITE_ENABLE_INSTR_BIT 0

// Bit mask for the write enable signal.
`define ROB_WRITE_ENABLE_STATE_MASK 6'b 100000
`define ROB_WRITE_ENABLE_MODE_MASK  6'b 010000
`define ROB_WRITE_ENABLE_ADDR_MASK  6'b 001000
`define ROB_WRITE_ENABLE_VALUE_MASK 6'b 000100
`define ROB_WRITE_ENABLE_PC_MASK    6'b 000010
`define ROB_WRITE_ENABLE_INSTR_MASK 6'b 000001

`define BYPASS_STATE_WIDTH 2 // Bypass state.

`define BYPASS_STATE_MISS 0 // No need to bypass.
`define BYPASS_STATE_WAIT 1 // Bypass needed but value not prepared.
`define BYPASS_STATE_HIT 2  // Bypass needed and value prepared.

`define ROB_WIDTH 3 // NUM_ENTRIES = 2 ** ROB_WIDTH
`define ROB_NUM_ENTRIES (2 ** `ROB_WIDTH)

module ROB(input wire clk,
           input wire reset,
           input wire [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_EX,    // Write mask for the ALU instruction.
           input wire [`ROB_WIDTH - 1:0] tag_EX,                   // Tag (entry of the rob to overwrite) of the ALU instruction.
           input wire [`ROB_STATE_WIDTH - 1:0] state_EX,           // State of the ALU instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] addr_EX,         // Tag of the ALU instruction.
           input wire [`DATA_SIZE - 1:0] value_EX,                 // Value of the ALU instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] PC_EX,           // PC of the ALU instruction.
           input wire [`INSTRUCTION_WIDTH - 1:0] instr_EX,         // Instruction code of the ALU instruction.
           input wire [`MODE_WIDTH - 1:0] mode_EX,                 // Execution mode of the ALU instruction.

           input wire [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_MEM,   // Write mask for the MEM instruction.
           input wire [`ROB_WIDTH - 1:0] tag_MEM,                  // Tag (entry of the rob to overwrite) of the MEM instruction.
           input wire [`ROB_STATE_WIDTH - 1:0] state_MEM,          // State of the MEM instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] addr_MEM,        // Tag of the MEM instruction.
           input wire [`DATA_SIZE - 1:0] value_MEM,                // Value of the MEM instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] PC_MEM,          // PC of the MEM instruction.
           input wire [`INSTRUCTION_WIDTH - 1:0] instr_MEM,        // Instruction code of the MEM instruction.
           input wire [`MODE_WIDTH - 1:0] mode_MEM,                // Execution mode of the ALU instruction.

           input wire [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_MUL5,  // Write mask for the MUL5 instruction.
           input wire [`ROB_WIDTH - 1:0] tag_MUL5,                 // Tag (entry of the rob to overwrite) of the MUL5 instruction.
           input wire [`ROB_STATE_WIDTH - 1:0] state_MUL5,         // State of the MUL5 instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] addr_MUL5,       // Tag of the MUL5 instruction.
           input wire [`DATA_SIZE - 1:0] value_MUL5,               // Value of the MUL5 instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] PC_MUL5,         // PC of the MUL5 instruction.
           input wire [`INSTRUCTION_WIDTH - 1:0] instr_MUL5,       // Instruction code of the MUL5 instruction.
           input wire [`MODE_WIDTH - 1:0] mode_MUL5,               // Execution mode of the ALU instruction.

           input wire [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_head,  // Write mask for the head instruction.
           input wire [`ROB_STATE_WIDTH - 1:0] state_head_write,   // State of the head instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] addr_head_write, // Tag of the head instruction.
           input wire [`DATA_SIZE - 1:0] value_head_write,         // Value of the head instruction.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] PC_head_write,   // PC of the head instruction.
           input wire [`INSTRUCTION_WIDTH - 1:0] instr_head_write, // Instruction code of the head instruction.
           input wire [`MODE_WIDTH - 1:0] mode_head_write,         // Execution mode code of the ALU instruction.

           input wire [`ROB_WIDTH - 1:0] head,                     // Head of the ROB.
           input wire [`ROB_WIDTH - 1:0] tail,                     // Tail of the ROB.

           input wire [`INSTRUCTION_WIDTH - 1:0] instruction_ID,   // The instruction in ID.
           output reg [`BYPASS_STATE_WIDTH - 1:0] rs_state,        // Bypass state of the RS register.
           output reg [`BYPASS_STATE_WIDTH - 1:0] rt_state,        // Bypass state of the RT register.
           output reg [`DATA_SIZE - 1:0] rs_value,                 // Output RS value of bypasses.
           output reg [`DATA_SIZE - 1:0] rt_value,                 // Output RT value of bypasses.

           output wire [`ROB_STATE_WIDTH - 1:0] state_head,        // State of the head of the ROB.
           output wire [`VIRTUAL_ADDR_WIDTH - 1:0] addr_head,      // Addr of the head of the ROB.
           output wire [`DATA_SIZE - 1:0] value_head,              // Value of the head of the ROB.
           output wire [`VIRTUAL_ADDR_WIDTH - 1:0] PC_head,        // PC of the head of the ROB.
           output wire [`INSTRUCTION_WIDTH - 1:0] instr_head,      // Instruction code of the head of the ROB.
           output wire [`MODE_WIDTH - 1:0] mode_head,              // Execution mode of the ALU instruction.
           
           output wire [`ROB_WIDTH:0] empty_entries);              // Number of remaining empty entries.

    `include "instr.v"
    
    reg [`ROB_STATE_WIDTH - 1:0] ROB_states [`ROB_NUM_ENTRIES - 1:0];
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] ROB_addrs [`ROB_NUM_ENTRIES - 1:0];
    reg [`DATA_SIZE - 1:0] ROB_values [`ROB_NUM_ENTRIES - 1:0];
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] ROB_pcs [`ROB_NUM_ENTRIES - 1:0];
    reg [`INSTRUCTION_WIDTH - 1:0] ROB_instrs [`ROB_NUM_ENTRIES - 1:0];
    reg [`MODE_WIDTH - 1:0] ROB_modes [`ROB_NUM_ENTRIES - 1:0];
    
    integer used_entries;

    /**
     * Write into the ROB.
     */
    task write(input [`ROB_WRITE_ENABLE_WIDTH - 1:0] write_mask, // Write mask.
                     [`ROB_WIDTH - 1:0] tag,                     // New tag.
                     [`ROB_STATE_WIDTH - 1:0] state,             // New state.
                     [`VIRTUAL_ADDR_WIDTH - 1:0] addr,           // New addr.
                     [`DATA_SIZE - 1:0] value,                   // New value.
                     [`VIRTUAL_ADDR_WIDTH - 1:0] pc,             // New PC.
                     [`INSTRUCTION_WIDTH - 1:0] instr,           // New instruction code.
                     [`INSTRUCTION_WIDTH - 1:0] mode);           // New execution mode.
        begin
            if (write_mask[`ROB_WRITE_ENABLE_STATE_BIT]) begin
                if (state != `ROB_STATE_UNUSED && ROB_states[tag] == `ROB_STATE_UNUSED) begin
                    used_entries = used_entries + 1;
                end
                else if (state == `ROB_STATE_UNUSED && ROB_states[tag] != `ROB_STATE_UNUSED) begin
                    used_entries = used_entries - 1;
                end
                ROB_states[tag] <= state;
            end
            if (write_mask[`ROB_WRITE_ENABLE_MODE_BIT])  ROB_modes[tag]  <= mode;
            if (write_mask[`ROB_WRITE_ENABLE_ADDR_BIT])  ROB_addrs[tag]  <= addr;
            if (write_mask[`ROB_WRITE_ENABLE_VALUE_BIT]) ROB_values[tag] <= value;
            if (write_mask[`ROB_WRITE_ENABLE_PC_BIT])    ROB_pcs[tag]    <= pc;
            if (write_mask[`ROB_WRITE_ENABLE_INSTR_BIT]) ROB_instrs[tag] <= instr;
        end
    endtask

    /**
     * Compute bypass.
     */
    task rx_bypass(input [`INSTRUCTION_REGISTER_WIDTH - 1:0] rx, // Register to search for bypasses in the ROB.
                   output [`BYPASS_STATE_WIDTH - 1:0] rx_state,  // State of the bypass (hit, miss, wait)
                          [`DATA_SIZE - 1:0] rx_value);          // Value of the bypass.

        integer i;
        integer idx;
        reg [`INSTRUCTION_WIDTH - 1:0] instr;

        begin

            rx_state = `BYPASS_STATE_MISS;
            rx_value = 0;

            if (write_EX[`ROB_WRITE_ENABLE_STATE_BIT] && 
                has_rw(instr_EX) && rx == get_rw(instr_EX)) begin
                
                rx_state = (state_EX == `ROB_STATE_COMPLETE) ? 
                    `BYPASS_STATE_HIT : 
                    `BYPASS_STATE_WAIT;

                rx_value = value_EX;
            end
            else if (write_MEM[`ROB_WRITE_ENABLE_STATE_BIT] && 
                     has_rw(ROB_instrs[tag_MEM]) && rx == get_rw(ROB_instrs[tag_MEM])) begin
                
                rx_state = (state_MEM == `ROB_STATE_COMPLETE) ? 
                    `BYPASS_STATE_HIT : 
                    `BYPASS_STATE_WAIT;
    
                rx_value = value_MEM;
            end
            else if (write_MUL5[`ROB_WRITE_ENABLE_STATE_BIT] && 
                     has_rw(ROB_instrs[tag_MUL5]) && rx == get_rw(ROB_instrs[tag_MUL5])) begin
                
                rx_state = (state_MUL5 == `ROB_STATE_COMPLETE) ? 
                    `BYPASS_STATE_HIT : 
                    `BYPASS_STATE_WAIT;

                rx_value = value_MUL5;
            end
            else begin
                for (i = 0; i > -used_entries; i = i - 1) begin
                    idx = (i + tail) % `ROB_NUM_ENTRIES;
                    instr = ROB_instrs[idx];

                    if (has_rw(instr) && rx == get_rw(instr)) begin
                        rx_state = (ROB_states[idx] == `ROB_STATE_COMPLETE) ? 
                            `BYPASS_STATE_HIT : 
                            `BYPASS_STATE_WAIT;

                        rx_value = ROB_values[idx];

                        i = -used_entries; 
                    end
                end
            end
        end
    endtask

    /**
     * Cleans the ROB.
     */
    task clean();
        integer i;

        begin
            used_entries = 0;

            for (i = 0; i < `ROB_NUM_ENTRIES; i = i + 1) begin
                ROB_states[i] <= `ROB_STATE_UNUSED;
                ROB_modes[i]  <= 0;
                ROB_addrs[i]  <= 0;
                ROB_values[i] <= 0;
                ROB_pcs[i]    <= 0;
                ROB_instrs[i] <= 0;
            end
        end
    endtask
    
    initial begin
        clean();
    end
    
    // Read from the head.
    assign state_head = ROB_states[head];
    assign mode_head  = ROB_modes[head];
    assign addr_head  = ROB_addrs[head];
    assign value_head = ROB_values[head];
    assign PC_head    = ROB_pcs[head];
    assign instr_head = ROB_instrs[head];

    // Number of empty entries?
    assign empty_entries = `ROB_NUM_ENTRIES - used_entries;

    always @(write_EX, instr_EX, state_EX, value_EX,
             write_MEM, state_MEM, value_MEM,
             write_MUL5, state_MUL5, value_MUL5,
             ROB_instrs, ROB_states, ROB_values, 
             tail, used_entries,
             instruction_ID) begin
        // Bypasses.
        rx_bypass(get_rs(instruction_ID), rs_state, rs_value);
        rx_bypass(get_rt(instruction_ID), rt_state, rt_value);
    end

    always @(posedge clk) begin
        if (reset == 1) begin
            clean();
        end
        else begin
            // Write into the ROB.
            write(write_EX, tag_EX, state_EX, addr_EX, value_EX, PC_EX, instr_EX, mode_EX);
            write(write_MEM, tag_MEM, state_MEM, addr_MEM, value_MEM, PC_MEM, instr_MEM, mode_MEM);
            write(write_MUL5, tag_MUL5, state_MUL5, addr_MUL5, value_MUL5, PC_MUL5, instr_MUL5, mode_MUL5);
            write(write_head, head, state_head_write, addr_head_write, value_head_write, PC_head_write, instr_head_write, mode_head_write);
        end
    end

endmodule
    
