/**
 * MIPS CPU.
 *
 */

`include "defines.v"
`include "ROB.v"
`include "RAM.v"
`include "cache.v"

module MIPS(input wire clk,          // Clock.
            input wire reset,        // Reset; 1 -> reset MIPS.
            output wire [31:0] out); // Unused.

    `include "instr.v"
    
    /*
     *
     * MIPS wires/regs declarations (needed for control signals).
     *
     */

    /*
     * ROB
     */
     
    wire load_ROB_head;
    wire [`ROB_WIDTH - 1:0] next_ROB_head;
    wire [`ROB_WIDTH - 1:0] ROB_head;

    wire load_ROB_tail;
    wire [`ROB_WIDTH - 1:0] next_ROB_tail;
    wire [`ROB_WIDTH - 1:0] ROB_tail;

    wire [`ROB_WIDTH:0] ROB_empty_entries;

    wire [`ROB_STATE_WIDTH - 1:0] ROB_state_head;
    wire [`VIRTUAL_ADDR_WIDTH - 1:0] ROB_addr_head;
    wire [`DATA_SIZE - 1:0] ROB_value_head;
    wire [`VIRTUAL_ADDR_WIDTH - 1:0] ROB_PC_head;
    wire [`INSTRUCTION_WIDTH - 1:0] ROB_instr_head;
    wire [`MODE_WIDTH-1:0] ROB_mode_head;

    wire [`BYPASS_STATE_WIDTH - 1:0] ROB_rs_state;
    wire [`BYPASS_STATE_WIDTH - 1:0] ROB_rt_state;

    wire [`DATA_SIZE - 1:0] ROB_rs_value;
    wire [`DATA_SIZE - 1:0] ROB_rt_value;

    /*
     * Special registers.
     */

    wire [`DATA_SIZE-1:0] rm0_out;
    wire [`DATA_SIZE-1:0] rm1_out;
    wire [`DATA_SIZE-1:0] rm2_out;

    /*
     * iTBL
     */

    wire iTLB_hit_IF;
    wire [`PHYSICAL_ADDR_WIDTH - 1:0] paddr_IF;

    /*
     * dTLB
     */

    wire [`PHYSICAL_ADDR_WIDTH - 1:0] paddr_LU;
    wire hit_dTLB_LU;
    /*
     * iCache
     */

    wire hit_iCache_IF;

    /*
     * dCache
     */
    
    wire hit_dCache_LU;

    /*
     * RAM
     */
                    
    wire read_rw_RAM;                                   
    wire read_r_RAM;                                    
    wire write_rw_RAM;    
                              
    wire [`RAM_PORT_STATE_WIDTH - 1:0] port_rw_state_RAM;
    wire [`RAM_PORT_STATE_WIDTH - 1:0] port_r_state_RAM;

    wire [`PHYSICAL_ADDR_WIDTH-1:0]addr_r_out_RAM;
    wire [`PHYSICAL_ADDR_WIDTH-1:0]addr_rw_out_RAM;

    wire [`CACHE_LINE_WIDTH - 1:0] dout_rw_RAM;         
    wire [`CACHE_LINE_WIDTH - 1:0] dout_r_RAM;

    /*
     * IF
     */

    wire [`VIRTUAL_ADDR_WIDTH - 1:0] PC_out_IF;
    wire [`CACHE_LINE_WIDTH-1:0] dout_iCache_IF;

    /*
     * ID
     */
    wire [`VIRTUAL_ADDR_WIDTH-1:0] PC_ID;
    wire [`DATA_SIZE-1 :0] instruction_ID;

    wire [`DATA_SIZE-1:0] ext_inm_ID;

    wire [`DATA_SIZE-1:0] bus_rs_ID;
    wire [`DATA_SIZE-1:0] bus_rt_ID;

    wire [`DATA_SIZE-1:0] bus_rs_out_ID;
    wire [`DATA_SIZE-1:0] bus_rt_out_ID;

    wire iTLB_hit_ID;

    wire wait_bypass_ID;

    /*
     * EX
     */
    
    wire [`INSTRUCTION_WIDTH-1:0] instruction_EX;

    wire [`DATA_SIZE-1:0] bus_rs_EX;
    wire [`DATA_SIZE-1:0] bus_rt_EX;

    wire [`DATA_SIZE-1:0] PC_EX;
    wire [`DATA_SIZE-1:0] ext_inm_EX;

    wire [`MODE_WIDTH-1:0] mode_EX;

    wire iTLB_hit_EX;

    wire [`DATA_SIZE-1:0] ALU_out_EX;

    /*
     * LU
     */
    wire [`VIRTUAL_ADDR_WIDTH-1:0] instruction_LU;

    wire [`DATA_SIZE-1:0] ALU_out_LU;

    wire [`ROB_WIDTH - 1:0] tag_LU;
    wire [`CACHE_LINE_WIDTH-1:0] dout_dCache_LU;
    wire [`PHYSICAL_ADDR_WIDTH-1:0] dout_addr_dCache_LU;
    wire dirty_LU;

    wire [`MODE_WIDTH-1:0] mode_LU;

    wire [`DATA_SIZE-1:0] rs_bus_LU;

    /*
     * MEM
     */

    wire [`PHYSICAL_ADDR_WIDTH-1:0] paddr_MEM;
    wire [`INSTRUCTION_WIDTH-1:0] instruction_MEM;
    wire [`ROB_WIDTH - 1:0] tag_MEM;
    wire [`DATA_SIZE-1:0] ALU_out_MEM;
    wire [`CACHE_LINE_WIDTH-1:0] dout_dCache_MEM;
    wire [`DATA_SIZE-1:0] rs_bus_MEM;
    wire hit_dTLB_MEM;
    wire hit_dCache_MEM;

    /*
     * MUL4
     */
    
    wire [`INSTRUCTION_WIDTH-1:0] instruction_MUL4;
    wire [`ROB_WIDTH - 1:0] tag_MUL4;

    /*
     * MUL5
     */

    wire [`INSTRUCTION_WIDTH-1:0] instruction_MUL5;
    wire [`DATA_SIZE - 1:0] ALU_out_MUL4;
    wire [`DATA_SIZE - 1:0] ALU_out_MUL5;
    wire [`ROB_WIDTH - 1:0] tag_MUL5;

    /*
     * Register banks.
     */

    wire load_MUL4_MUL5;
    wire load_MEM_MUL4;
    wire load_LU_MEM;
    wire load_EX_LU;
    wire load_ID_EX;
    wire load_IF_ID;

    /*
     *
     * Control signals.
     *
     */

    /*
     * ROB
     */

    wire ROB_full = ROB_empty_entries == 0;
    wire ROB_emtpty = ROB_empty_entries == `ROB_NUM_ENTRIES;

    wire ROB_commit_head = (ROB_state_head == `ROB_STATE_COMPLETE);
    wire ROB_exception_head = (ROB_state_head == `ROB_STATE_EXCEPTION);
    wire ROB_head_to_LU = (ROB_state_head == `ROB_STATE_WAITING_CACHE);

    // When there is an exception -> clean the ROB (reset).
    wire clean_ROB = reset || ROB_exception_head;

    // head = (head + 1) % N when the instruction in the head commits.
    assign load_ROB_head = ROB_commit_head;
    assign next_ROB_head = (ROB_head + 1) % `ROB_NUM_ENTRIES;
    
    // tail = (tail + 1) % N when the instruction in EX is inserted in the ROB.
    assign load_ROB_tail = !ROB_full && goes_into_ROB(instruction_EX) && load_EX_LU;
    assign next_ROB_tail = (ROB_tail + 1) % `ROB_NUM_ENTRIES;

    // The instruction in ALU goes into the ROB, there is space in the ROB?
    // Then write STATE, PC, VALUE and INSTR into the tail.
    // Is the instruction is privileged but we are not in supervisor mode, then
    // do not write anything.
    wire [`ROB_WRITE_ENABLE_WIDTH-1:0] ROB_write_EX_MASK = 
        (!ROB_full && goes_into_ROB(instruction_EX) && 
        (!is_privileged(instruction_EX) || 
        (is_privileged(instruction_EX) && mode_EX == `SUPERVISOR_MODE))) ?
        `ROB_WRITE_ENABLE_STATE_MASK | `ROB_WRITE_ENABLE_MODE_MASK |
        `ROB_WRITE_ENABLE_PC_MASK | `ROB_WRITE_ENABLE_INSTR_MASK | 
        `ROB_WRITE_ENABLE_ADDR_MASK | `ROB_WRITE_ENABLE_VALUE_MASK
        : 0;
    
    // If the instruction in EX has an iTLB miss, state = EXCEPTION.
    // If the instruction finishes in EX, state = COMPLETE.
    // If the instruction is a load or a store, state = WAITING TO ACCESS MEMORY.
    // Otherwise, state = BUSY.
    wire [`ROB_STATE_WIDTH-1:0] ROB_state_EX = 
        (!iTLB_hit_EX) ? `ROB_STATE_EXCEPTION 
        : (finishes_in_EX(instruction_EX)) ? `ROB_STATE_COMPLETE
        : (access_mem(instruction_EX)) ? `ROB_STATE_WAITING_CACHE
        : `ROB_STATE_BUSY;
    
    // If the instruction in EX has an iTLB miss, 
    // value = 0 (type of exception = iTLB miss)
    // If the instruction in EX is a TLBWRITE, value = rs.
    // Else, value = ALU-out.
    wire [`DATA_SIZE-1:0] ROB_value_EX = 
        (!iTLB_hit_EX) ? `iTLB_EXCEPTION 
        : (is_store(instruction_EX) || is_tlbwrite(instruction_EX)) ? bus_rs_EX 
        : ALU_out_EX;

    // If the instruction in EX has an iTLB miss, 
    // addr = PC
    // Else, value = ALU-out (@ for ld/st).
    wire [`VIRTUAL_ADDR_WIDTH-1:0] ROB_addr_EX = !iTLB_hit_EX ? PC_EX : ALU_out_EX;

    // The instruction in MEM finishes in MEM or has had an dTLB miss?
    // Then update ROB state and value.
    wire [`ROB_WRITE_ENABLE_WIDTH-1:0] ROB_write_MEM_MASK = 
        (!hit_dTLB_MEM && access_mem(instruction_MEM)) || finishes_in_MEM(instruction_MEM) ? 
        `ROB_WRITE_ENABLE_STATE_MASK | `ROB_WRITE_ENABLE_VALUE_MASK
        : 0;

    // If the instruction in MEM has a dTLB miss, satate = EXCEPTION
    // Else if the instruction finishes in MEM, state = COMPLETE.
    wire [`ROB_STATE_WIDTH-1:0] ROB_state_MEM = 
        (!hit_dTLB_MEM && access_mem(instruction_MEM)) ? `ROB_STATE_EXCEPTION 
        : `ROB_STATE_COMPLETE;

    // If the instruction in MEM has a dTLB miss,
    // value = 1 (type of exception = dTLB miss)
    // Else, value = dout_dCache.
    wire [`DATA_SIZE-1:0] ROB_value_MEM = 
        (!hit_dTLB_MEM && access_mem(instruction_MEM)) ? 
        `dTLB_EXCEPTION : dout_dCache_MEM[`DATA_SIZE-1:0];

    // The instruction in MUL5 has finished? Then update the ROB entry.
    wire [`ROB_WRITE_ENABLE_WIDTH-1:0] ROB_write_MUL5_MASK = 
        (finishes_in_MUL5(instruction_MUL5)) ? 
        `ROB_WRITE_ENABLE_STATE_MASK | `ROB_WRITE_ENABLE_VALUE_MASK
        : 0;
    
    // Update the head of the ROB state when it is a ld/st and can be
    // forwarded to LU stage.
    wire [`ROB_WRITE_ENABLE_WIDTH-1:0] ROB_write_head_MASK = 
        ROB_head_to_LU || ROB_commit_head ? `ROB_WRITE_ENABLE_STATE_MASK 
        : 0;

    // Update the head of the ROB state to ACCESSING_CACHE when it is a ld/st and can be
    // forwarded to LU stage. If the instruction in the head of the ROB is a ld/st
    // and has performed its access to mem, state = COMPLETE.
    wire [`ROB_STATE_WIDTH-1:0] ROB_state_head_write = ROB_head_to_LU ?
        `ROB_STATE_ACCESSING_CACHE : `ROB_STATE_UNUSED;

    /*
     * Special registers.
     */

    // Load the special registers when there is an exception.
    wire load_rm0 = ROB_exception_head;
    wire load_rm1 = ROB_exception_head;
    wire load_rm2 = ROB_exception_head;
    // Load the mode-register when there is an exception or when returning from one.
    wire load_rm4 = ROB_exception_head || get_op(instruction_ID) == `IRET;

    // PC the OS should return to on exceptions
    wire [`DATA_SIZE-1:0] din_rm0 = ROB_PC_head;
    // @ for TLB exceptions.
    wire [`DATA_SIZE-1:0] din_rm1 = ROB_value_head == `iTLB_EXCEPTION ? ROB_PC_head : ROB_addr_head;
    // The exception type.
    wire [`DATA_SIZE-1:0] din_rm2 = ROB_value_head;
    // Supervisor mode when there is an exception. User mode when returning from exception.
    wire [`MODE_WIDTH-1:0] din_rm4 = ROB_exception_head ? `SUPERVISOR_MODE : `USER_MODE;

    /*
     * Branches.
     */

    // If the instruction in ID is a BEQ and rs.value == rt.value -> Jump
    // If the instruction in ID is a JUMP -> Jump
    // If the instruction in ID is a IREQ -> Jump
    wire jump_ID = (get_op(instruction_ID) == `BEQ && !wait_bypass_ID && bus_rs_out_ID == bus_rt_out_ID) || 
                    get_op(instruction_ID) == `JUMP ||
                    get_op(instruction_ID) == `IRET;

    // inm * 4
    wire [`DATA_SIZE-1:0] ext_inm_x4_ID;
    assign ext_inm_x4_ID[1:0] = 0;
    assign ext_inm_x4_ID[`DATA_SIZE-1:2] = ext_inm_ID[29:0];
    
    // Compute @branch
    // INM + PC when the instruction in ID is a BEQ or JUMP or 
    // RM0 is the instruction in ID is a IREQ.
    wire [`VIRTUAL_ADDR_WIDTH-1:0] addr_branch_ID = 
        (get_op(instruction_ID) == `BEQ || get_op(instruction_ID) == `JUMP) ?
        ext_inm_x4_ID + PC_ID 
        : rm0_out;
    
    /*
     * iTLB
     */

    // Write into the dTLB when the head of the ROB is a ITLBWRITE and can commit.
    wire write_iTLB_IF = ROB_commit_head && get_op(ROB_instr_head) == `ITLBWRITE;

    // When the instruction in the ROB head is a ITLBWRITE and can commit, the new paddr
    // is the addr of the ROB head.
    wire [`PHYSICAL_ADDR_WIDTH-1:0] iTLB_paddr_new = ROB_value_head[`PHYSICAL_ADDR_WIDTH-1:0];

    // If the instruction in the ROB head is a ITLBWRITE and the ROB head can cammit,
    // use the vaddr in the value of the ROB-head. Else the vaddr passes to the dTLB is PC.
    wire [`VIRTUAL_ADDR_WIDTH-1:0] iTLB_vaddr = (write_iTLB_IF) ? ROB_addr_head : PC_out_IF;

    /*
     * dTLB
     */

    // Write into the dTLB when the head of the ROB is a DTLBWRITE and can commit.
    wire write_dTLB_LU = ROB_commit_head && get_op(ROB_instr_head) == `DTLBWRITE;

    // When the instruction in the ROB head is a DTLBWRITE and can commit, the new paddr
    // is the addr of the ROB head.
    wire [`PHYSICAL_ADDR_WIDTH-1:0] dTLB_paddr_new = ROB_value_head[`PHYSICAL_ADDR_WIDTH-1:0];

    // If the instruction in the ROB head is a DTLBWRITE and the ROB head can cammit,
    // use the vaddr in the value of the ROB-head. Else the vaddr passes to the dTLB is ALU-out.
    wire [`VIRTUAL_ADDR_WIDTH-1:0] dTLB_vaddr = (write_dTLB_LU) ? ROB_addr_head : ALU_out_LU;

    /*
     * iCache
     */

    // Write into the iCache stage when the RAM has our data ready.
    wire write_iCache_IF = port_r_state_RAM == `RAM_PORT_STATE_DONE_READING;

    wire [`PHYSICAL_ADDR_WIDTH-1:0] iCache_paddr = 
        write_iCache_IF ? addr_r_out_RAM : paddr_IF;

    // Write a full cache-line into the dCache or read a word (instruction) from the iCache.
    wire [`CACHE_OP_TYPE_WIDTH-1:0] load_type_iCache_IF = (write_iCache_IF) ? 
        `CACHE_OP_CACHE_LINE : `CACHE_OP_WORD;

    /*
     * dCache
     */ 

    // Write into the dCache in LU stage when the RAM has our data ready.
    wire write_dCache_LU = 
        (port_rw_state_RAM == `RAM_PORT_STATE_DONE_READING ||
         port_rw_state_RAM == `RAM_PORT_STATE_DONE_WRITING) && 
         access_mem(instruction_LU);

    wire [`PHYSICAL_ADDR_WIDTH-1:0] iCache_paddr_LU = 
        write_dCache_LU && port_rw_state_RAM == `RAM_PORT_STATE_DONE_READING ? 
        addr_rw_out_RAM : paddr_LU;

    // Write into the dCache in MEM stage if the instruction in MEM is an store and
    // there was a dTLB/dCache hit in LU stage.
    wire write_dCache_MEM = is_store(instruction_MEM) && hit_dCache_MEM && hit_dTLB_MEM;

    // Read a byte from the dCache if the instruction in MEM is LDB or STB
    // if the instruction in MEM is LDW or STW, read a full word.
    wire [`CACHE_OP_TYPE_WIDTH-1:0] op_type_dCache_MEM = 
        ((get_op(instruction_MEM) == `STW || get_op(instruction_MEM) == `LDW) ?
        `CACHE_OP_WORD : `CACHE_OP_BYTE);
        
    /*
     * RAM
     */

    // Read using the only-read port of the RAM when there is a iTLB hit 
    // and a iCache miss and the RAM is not busy.
    assign read_r_RAM = iTLB_hit_IF && !hit_iCache_IF &&
                        port_r_state_RAM == `RAM_PORT_STATE_NONE &&
                        !reset;
    
    // Write using the R/W port of the RAM when there is a dTLB hit 
    // and a dirty miss in the dCache and the RAM is not busy.
    assign write_rw_RAM = access_mem(instruction_LU) && 
                          hit_dTLB_LU && !hit_dCache_LU && dirty_LU && 
                          port_rw_state_RAM == `RAM_PORT_STATE_NONE &&
                          !reset;

    // Read using the R/W port of the RAM when there is a dTLB hit 
    // and a clean cache miss in the dCache and the RAM is not busy.
    assign read_rw_RAM = !write_rw_RAM && 
                          access_mem(instruction_LU) &&
                          hit_dTLB_LU && !hit_dCache_LU &&
                          port_rw_state_RAM == `RAM_PORT_STATE_NONE &&
                          !reset;

    // Read from RAM in LU stage using the dout of the dTLB.
    // If writting (dirty eviction), use the dout of the tag-dCache.
    wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_rw_RAM = 
        write_rw_RAM ? dout_addr_dCache_LU : paddr_LU;
    
    // Read from RAM in IF stage using the dout of the iTLB.
    wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_r_RAM = paddr_IF;

    /*
     * Register File
     */

    // Write into the register file if the head of the ROB can commit and the head's
    // instruction writes into the register file.
    assign register_file_write = ROB_commit_head && writes_reg(ROB_instr_head);

    /*
     * Register Banks
     */

    assign load_MUL4_MUL5 = 1;

    // Forward the instruction in MEM if we can forward the instruction in MUL4
    assign load_MEM_MUL4 = load_MUL4_MUL5;

    // Forward the instruction in LU if we can forward the instruction in MEM
    assign load_LU_MEM = load_MEM_MUL4;

    // Forward the instruction in EX if we can forward the instruction in LU AND
    // and hits in dCache if it access to mem.
    assign load_EX_LU = load_LU_MEM &&
                        !(hit_dTLB_LU && !hit_dCache_LU && access_mem(instruction_LU));

    // Forward the instruction in ID if we can forward the instruction in ID AND
    // the ROB is not full (the instruction in EX is in the ROB) AND TODO: OJO, SI UNA INSTRUCCION ESTABA YA EN EL ANTERIOR CICLO EN EX ESTO NO TIENE QUE COMPROBARSE
    // the instruction in EX is substituted by the one in the head of the ROB but does not finish in EX.
    assign load_ID_EX = load_EX_LU && 
        !(ROB_full && goes_into_ROB(instruction_EX)) &&
        !(ROB_head_to_LU && !finishes_in_EX(instruction_EX) && goes_into_ROB(instruction_EX) && !access_mem(instruction_EX));
        
    // Forward the instruction in IF if we can forward the instruction in ID and we are not
    // waiting for operands.
    assign load_IF_ID = load_ID_EX && !wait_bypass_ID;

    // If the instruction in ID is a type of branch or we are waiting for data from RAM ->
    // forward a NOP to ID stage.
    wire NOP_IF_ID = jump_ID || (iTLB_hit_IF && !hit_iCache_IF);
    // Forward a NOP to EX stage if we are waiting for operands.
    wire NOP_ID_EX = wait_bypass_ID;
    // Forward a NOP to MEM if we are managing a dirty eviction or getting data from RAM.
    wire NOP_LU_MEM = (hit_dTLB_LU && !hit_dCache_LU && access_mem(instruction_LU));

    // If reset of the head of the ROB is an exception -> clean the pipeline.
    wire clean_MUL4_MUL5 = reset || ROB_exception_head;
    wire clean_MEM_MUL4 = reset || ROB_exception_head;
    wire clean_LU_MEM = reset || ROB_exception_head;
    wire clean_EX_LU = reset || ROB_exception_head;
    wire clean_ID_EX = reset || ROB_exception_head;
    wire clean_IF_ID = reset || ROB_exception_head;

    // Instruction to forward to ID stage
    // A NOP if NOP_IF_ID
    // A NOP that goes into the ROB is we have an iTLB miss
    // The actual instruction if we have it
    wire [`INSTRUCTION_WIDTH-1:0] instruction_IF_out = 
        NOP_IF_ID ? `FULL_NOP 
        : !iTLB_hit_IF ? `FULL_NOP_ROB 
        : dout_iCache_IF[`INSTRUCTION_WIDTH-1:0];
    
    // If the ROB of the head is a ld/st that is waiting to access to memery ->
    // forward it to LU stage.
    // Avoid forwarning not-ready to commit load/stores (insert a NOP into LU).
    wire [`INSTRUCTION_WIDTH-1:0] instruction_EX_out = 
        ROB_head_to_LU ? ROB_instr_head
        : (access_mem(instruction_EX)) ? `FULL_NOP 
        : instruction_EX;

    wire [`DATA_SIZE-1:0] ALU_out_EX_out = ROB_head_to_LU ? ROB_addr_head : ALU_out_EX;
    wire [`DATA_SIZE-1:0] rs_bus_EX_out = ROB_head_to_LU ? ROB_value_head : bus_rs_EX;
    wire [`ROB_WIDTH-1:0] tag_EX_out = ROB_head_to_LU ? ROB_head : next_ROB_tail;
    wire [`MODE_WIDTH-1:0] mode_EX_out = ROB_head_to_LU ? ROB_mode_head : mode_EX;

    /*
     * PC
     */
    
    // Load PC when we can forward the instruction AND 
    // (We have a TLB miss OR TLB hit AND iCache hit)
    // 
    // OR we have to jump (exception in the head of the ROB or jump in ID)
    wire load_PC =
        (load_IF_ID && (!iTLB_hit_IF || (iTLB_hit_IF && hit_iCache_IF))) ||
        jump_ID || ROB_exception_head;

    // PC+4 signal.
    wire [`VIRTUAL_ADDR_WIDTH-1:0] PC4_IF = PC_out_IF + 4;

    // Select between PC+4, @branch or @EXCEPTION_HANDLER.
    wire [`VIRTUAL_ADDR_WIDTH-1:0] PC_in_IF = 
        (jump_ID) ? addr_branch_ID 
        : (ROB_exception_head) ? `EXCEPTION_HANDLER_ADDR
        : PC4_IF;
    
    /*
     * Components and connections.
     */

    //------------------------------------------------------------------------------------
    // General
    //------------------------------------------------------------------------------------
    

    // "C:/Users/Ian/Documents/REPOS/PA/pa_mips/RAMS/RAM_LDB_UNALIGNED.list"
    // _user_mode
    // RAM #(.INITIAL_VALUES_FILE("C:/Users/Lorien/Desktop/pa_mips/RAMS/RAM_add_bypass_user_mode.list"))
    // RAM #(.INITIAL_VALUES_FILE("D:/Lorien/Repos/pa_mips/RAMS/RAM_PERFORMANCE_BENCH_BUFFER_SUM.list"))
    // RAM #(.INITIAL_VALUES_FILE("C:/Users/Ian/Documents/REPOS/PA/pa_mips/RAMS/RAM_PERFORMANCE_BENCH_BUFFER_SUM.list"))
    // RAM #(.INITIAL_VALUES_FILE("C:/Users/Ian/Documents/REPOS/PA/pa_mips/RAMS/RAM_PERFORMANCE_BENCH_MEM_COPY.list"))
    // RAM #(.INITIAL_VALUES_FILE("C:/Users/Ian/Documents/REPOS/PA/pa_mips/RAMS/RAM_PERFORMANCE_BENCH_MATRIX_MUL_128x128.list"))
    RAM #(.INITIAL_VALUES_FILE("C:/Users/Ian/Documents/REPOS/PA/pa_mips/RAMS/RAM_TEST_FIBO.list"))
    RAM(.clk(clk),

        .addr_rw(addr_rw_RAM),
        .addr_r(addr_r_RAM),

        .din(dout_dCache_LU),

        .read_rw(read_rw_RAM),
        .read_r(read_r_RAM),

        .write_rw(write_rw_RAM),

        .port_rw_state(port_rw_state_RAM),
        .port_r_state(port_r_state_RAM),

        .addr_rw_out(addr_rw_out_RAM),
        .addr_r_out(addr_r_out_RAM),

        .dout_rw(dout_rw_RAM),
        .dout_r(dout_r_RAM));

    // Register that holds the ROB head.
    register #(.WIDTH(`ROB_WIDTH))
    ROB_head_reg(.clk(clk),
                 .reset(clean_ROB),
                 .load(load_ROB_head),
                 .din(next_ROB_head),
                 .dout(ROB_head));

    // Register that holds the ROB tail.
    register #(.WIDTH(`ROB_WIDTH), .INITIAL_VALUE(-1))
    ROB_tail_reg(.clk(clk),
                 .reset(clean_ROB),
                 .load(load_ROB_tail),
                 .din(next_ROB_tail),
                 .dout(ROB_tail));

    ROB ROB(.clk(clk),
            .reset(clean_ROB),

            .write_EX(ROB_write_EX_MASK),
            .tag_EX(next_ROB_tail),
            .state_EX(ROB_state_EX),
            .mode_EX(mode_EX),
            .addr_EX(ROB_addr_EX),
            .value_EX(ROB_value_EX),
            .PC_EX(PC_EX),
            .instr_EX(instruction_EX),

            .write_MEM(ROB_write_MEM_MASK),
            .tag_MEM(tag_MEM),
            .state_MEM(ROB_state_MEM),
            .mode_MEM(`MODE_WIDTH'd 0),
            .addr_MEM(0),
            .value_MEM(ROB_value_MEM),
            .PC_MEM(0),
            .instr_MEM(0),
        
            .write_MUL5(ROB_write_MUL5_MASK),
            .tag_MUL5(tag_MUL5),
            .state_MUL5(`ROB_STATE_COMPLETE),
            .mode_MUL5(`MODE_WIDTH'd 0),
            .addr_MUL5(0),
            .value_MUL5(ALU_out_MUL5),
            .PC_MUL5(0),
            .instr_MUL5(0),

            .write_head(ROB_write_head_MASK),
            .state_head_write(ROB_state_head_write),
            .mode_head_write(`MODE_WIDTH'd 0),
            .addr_head_write(0),
            .value_head_write(0),
            .PC_head_write(0),
            .instr_head_write(0),

            .head(ROB_head),
            .tail(ROB_tail),
    
            .instruction_ID(instruction_ID),
            .rs_state(ROB_rs_state),
            .rt_state(ROB_rt_state),
            .rs_value(ROB_rs_value),
            .rt_value(ROB_rt_value),
    
            .state_head(ROB_state_head),
            .mode_head(ROB_mode_head),
            .addr_head(ROB_addr_head),
            .value_head(ROB_value_head),
            .PC_head(ROB_PC_head),
            .instr_head(ROB_instr_head),
    
            .empty_entries(ROB_empty_entries));

    // PC the OS should return to on exceptions
    register rm0(.clk(clk), 
                 .reset(reset), 
                 .load(load_rm0), 
                 .din(din_rm0), 
                 .dout(rm0_out));
    
    // @ for TLB exceptions.
    register rm1(.clk(clk), 
                 .reset(reset), 
                 .load(load_rm1), 
                 .din(din_rm1), 
                 .dout(rm1_out));

    // The exception type.
    register rm2(.clk(clk), 
                 .reset(reset), 
                 .load(load_rm2),
                 .din(din_rm2),
                 .dout(rm2_out));

    // Mode of the CPU.
    register #(.INITIAL_VALUE(`USER_MODE), .WIDTH(`MODE_WIDTH))
    rm4(.clk(clk), 
        .reset(reset),
        .load(load_rm4), 
        .din(din_rm4),
        .dout(rm4_out));

    //------------------------------------------------------------------------------------
    // IF
    //------------------------------------------------------------------------------------
    
    // PC
    register #(.INITIAL_VALUE(32'h 0))
    PC(.clk(clk), 
       .reset(reset), 
       .load(load_PC), 
       .din(PC_in_IF), 
       .dout(PC_out_IF));

    // Instruction TLB
    TLB iTLB(.clk(clk),
             .reset(reset),
             .write(write_iTLB_IF),
             .mode(rm4_out),
             .vaddr(iTLB_vaddr),
             .paddr_new(iTLB_paddr_new),
             .paddr(paddr_IF),
             .hit(iTLB_hit_IF));
    
    cache iCache(.clk(clk),
                 .reset(reset),
                 .addr_tag(iCache_paddr),
                 .addr_data(iCache_paddr),
                 .write_tag(1'd 0),
                 .write_data(write_iCache_IF),
                 .op_type_data(load_type_iCache_IF),
                 .din_data(dout_r_RAM),
                 .din_tag(),
                 .dout_data(dout_iCache_IF),
                 .dout_tag(),
                 .dout_addr_tag(),
                 .hit(hit_iCache_IF),
                 .dirty());

    //------------------------------------------------------------------------------------
    // IF - ID REGISTER BANK
    //------------------------------------------------------------------------------------
    
    bank_IF_ID bank_IF_ID(.clk(clk),
                          .reset(clean_IF_ID),
                          .load(load_IF_ID),
                          .instruction_IF(instruction_IF_out),
                          .PC_IF(PC_out_IF),
                          .iTLB_hit_IF(iTLB_hit_IF),
                          .instruction_ID(instruction_ID),
                          .PC_ID(PC_ID),
                          .iTLB_hit_ID(iTLB_hit_ID));      

    //------------------------------------------------------------------------------------
    // ID
    //------------------------------------------------------------------------------------
    
    // Register bank
    register_bank register_bank(.clk(clk),
                                .reset(reset),
                                .rs(get_rs(instruction_ID)),
                                .rt(get_rt(instruction_ID)),
                                .rw(get_rw(ROB_instr_head)),
                                .bus_rw(ROB_value_head),
                                .reg_write(register_file_write),
                                .bus_rs(bus_rs_ID),
                                .bus_rt(bus_rt_ID));
    
    // 16 bits to 32 bits inm sign extender.
    sign_extender inm_sign_extender(.instruction(instruction_ID), 
                                    .out(ext_inm_ID));

    // FORWARD UNIT
    FU forward_unit(.instruction_ID(instruction_ID),
                    .rs_state_ROB(ROB_rs_state),
                    .rt_state_ROB(ROB_rt_state),
                    .rs_value_ROB(ROB_rs_value),
                    .rt_value_ROB(ROB_rt_value),
                    .bus_rs_ID(bus_rs_ID),
                    .bus_rt_ID(bus_rt_ID),
                    .rm0(rm0_out),
                    .rm1(rm1_out),
                    .rm2(rm2_out),
                    .rm4(rm4_out),
                    .bus_rs_out(bus_rs_out_ID),
                    .bus_rt_out(bus_rt_out_ID),
                    .stop(wait_bypass_ID));

    //------------------------------------------------------------------------------------
    // ID-EX REGISTER BANK.
    //------------------------------------------------------------------------------------

    bank_ID_EX bank_ID_EX(.clk(clk),
                          .reset(clean_ID_EX),
                          .load(load_ID_EX),
                          .instruction_ID(NOP_ID_EX ? `FULL_NOP : instruction_ID),
                          .mode_ID(rm4_out),
                          .bus_rs_ID(bus_rs_out_ID),
                          .bus_rt_ID(bus_rt_out_ID),
                          .PC_ID(PC_ID),
                          .iTLB_hit_ID(iTLB_hit_ID),
                          .inm_ext_ID(ext_inm_ID),
                          .instruction_EX(instruction_EX),
                          .mode_EX(mode_EX),
                          .bus_rs_EX(bus_rs_EX),
                          .bus_rt_EX(bus_rt_EX),
                          .PC_EX(PC_EX),
                          .iTLB_hit_EX(iTLB_hit_EX),
                          .inm_ext_EX(ext_inm_EX));
    //------------------------------------------------------------------------------------
    // EX
    //------------------------------------------------------------------------------------

    // ALU
    ALU ALU(.da(bus_rs_EX),
            .db(bus_rt_EX),
            .inm(ext_inm_EX),
            .op(get_op(instruction_EX)),
            .dout(ALU_out_EX));

    
    //------------------------------------------------------------------------------------
    // EX-LU REGISTER BANK.
    //------------------------------------------------------------------------------------
    
    bank_EX_LU bank_EX_LU(.clk(clk),
                          .reset(clean_EX_LU),
                          .load(load_EX_LU),
                          .instruction_EX(instruction_EX_out),
                          .mode_EX(mode_EX_out),
                          .ALU_out_EX(ALU_out_EX_out),
                          .rs_bus_EX(rs_bus_EX_out),
                          .tag_EX(tag_EX_out),
                          .instruction_LU(instruction_LU),
                          .mode_LU(mode_LU),
                          .ALU_out_LU(ALU_out_LU),
                          .rs_bus_LU(rs_bus_LU),
                          .tag_LU(tag_LU));

    //------------------------------------------------------------------------------------
    // LU/MUL2
    //------------------------------------------------------------------------------------

    TLB dTLB(.clk(clk),
             .reset(reset),
             .mode(mode_LU),
             .write(write_dTLB_LU),
             .vaddr(dTLB_vaddr),
             .paddr_new(dTLB_paddr_new),
             .paddr(paddr_LU),
             .hit(hit_dTLB_LU)); 
    
    cache dCache(.clk(clk),
                 .reset(reset),
                 .addr_tag(iCache_paddr_LU),
                 .addr_data(paddr_MEM),
                 .write_data(write_dCache_MEM),
                 .write_tag(write_dCache_LU),
                 .op_type_data(op_type_dCache_MEM),
                 .din_data({96'd 0, rs_bus_MEM}),
                 .din_tag(dout_rw_RAM),
                 .dout_data(dout_dCache_MEM),
                 .dout_tag(dout_dCache_LU),
                 .dout_addr_tag(dout_addr_dCache_LU),
                 .hit(hit_dCache_LU),
                 .dirty(dirty_LU));

    //------------------------------------------------------------------------------------
    // LU-MEM REGISTER BANK.
    //------------------------------------------------------------------------------------
    
    bank_LU_MEM bank_LU_MEM(.clk(clk),
                            .reset(clean_LU_MEM),
                            .load(load_LU_MEM),
                            .instruction_LU((NOP_LU_MEM) ? `FULL_NOP : instruction_LU),
                            .paddr_LU(paddr_LU),
                            .ALU_out_LU(ALU_out_LU),
                            .rs_bus_LU(rs_bus_LU),
                            .tag_LU(tag_LU),
                            .hit_dTLB_LU(hit_dTLB_LU),
                            .hit_dCache_LU(hit_dCache_LU),
                            .instruction_MEM(instruction_MEM),
                            .paddr_MEM(paddr_MEM),
                            .ALU_out_MEM(ALU_out_MEM),
                            .rs_bus_MEM(rs_bus_MEM),
                            .tag_MEM(tag_MEM),
                            .hit_dTLB_MEM(hit_dTLB_MEM),
                            .hit_dCache_MEM(hit_dCache_MEM));

    //------------------------------------------------------------------------------------
    // MEM/MUL3
    //------------------------------------------------------------------------------------

    // dCache instantiated in LU.

    //------------------------------------------------------------------------------------
    // MEM-MUL4 REGISTER BANK.
    //------------------------------------------------------------------------------------

    bank_MEM_MUL4 bank_MEM_MUL4(.clk(clk),
                                .reset(clean_MEM_MUL4),
                                .load(load_MEM_MUL4),
                                .instruction_MEM(instruction_MEM),
                                .ALU_out_MEM(ALU_out_MEM),
                                .tag_MEM(tag_MEM),
                                .instruction_MUL4(instruction_MUL4),
                                .ALU_out_MUL4(ALU_out_MUL4),
                                .tag_MUL4(tag_MUL4));

    //------------------------------------------------------------------------------------
    // MUL4
    //------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------
    // MUL4-MUL5 REGISTER BANK.
    //------------------------------------------------------------------------------------

    bank_MUL4_MUL5 bank_MUL4_MUL5(.clk(clk),
                                  .reset(clean_MUL4_MUL5),
                                  .load(load_MUL4_MUL5),
                                  .instruction_MUL4(instruction_MUL4),
                                  .ALU_out_MUL4(ALU_out_MUL4),
                                  .tag_MUL4(tag_MUL4),
                                  .instruction_MUL5(instruction_MUL5),
                                  .ALU_out_MUL5(ALU_out_MUL5),
                                  .tag_MUL5(tag_MUL5));

    //------------------------------------------------------------------------------------
    // MUL5
    //------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------
    // Unused. Just to prevent a warning.
    assign out = instruction_ID;
    
endmodule
