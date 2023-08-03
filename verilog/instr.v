/*
 * Utility functions to work with instruction codes.
 *
 */

`include "defines.v"

/**
 * Get the OP of an instruction.
 */
function [`INSTRUCTION_OP_WIDTH - 1:0] get_op(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        get_op = instr[`INSTRUCTION_OP];
    end
endfunction

/*
 * Return 1 if instr has rs, 0 otherwise.
 */
function [0:0] has_rs(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        has_rs = instr != `MOV;
    end
endfunction

/*
 * Return 1 if instr has rs, 0 otherwise.
 */
function [0:0] has_rt(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        has_rt = (get_op(instr) == `ADD || get_op(instr) == `SUB || 
                get_op(instr) == `MUL || get_op(instr) == `OR  || 
                get_op(instr) == `AND || 
                get_op(instr) == `ITLBWRITE || get_op(instr) == `DTLBWRITE);
    end
endfunction

/**
 * Return 1 if instr has rw, 0 otherwise.
 */
function [0:0] has_rw(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        has_rw = (get_op(instr) == `ADD || get_op(instr) == `SUB || 
                get_op(instr) == `MUL || get_op(instr) == `OR  || 
                get_op(instr) == `AND || get_op(instr) == `LDB || 
                get_op(instr) == `LDW || get_op(instr) == `MOV);
    end
endfunction

/**
 * Return 1 if instr is a arithmetic.
 */
function [0:0] is_arithmetics(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        is_arithmetics = get_op(instr) == `ADD ||
                   get_op(instr) == `SUB ||
                   get_op(instr) == `MUL ||
                   get_op(instr) == `OR  ||
                   get_op(instr) == `AND;
    end
endfunction

/**
 * Return 1 if instr is a privileged instruction.
 */
function [0:0] is_privileged(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        is_privileged = is_tlbwrite(instr) || get_op(instr) == `IRET;
    end
endfunction

/**
 * Return 1 if instr is a mul.
 */
function [0:0] is_mul(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        is_mul = get_op(instr) == `MUL;
    end
endfunction

/**
 * Return 1 if instr is a store.
 */
function [0:0] is_store(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        is_store = get_op(instr) == `STB || get_op(instr) == `STW;
    end
endfunction

/**
 * Return 1 if instr is a load.
 */
function [0:0] is_load(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        is_load = get_op(instr) == `LDB || get_op(instr) == `LDW;
    end
endfunction

/**
 * Return 1 if instr is a TLBWRITE.
 */
function [0:0] is_tlbwrite(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        is_tlbwrite = get_op(instr) == `ITLBWRITE || get_op(instr) == `DTLBWRITE;
    end
endfunction

/**
 * Return 1 if instr access memory.
 */
function [0:0] access_mem(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        access_mem = is_store(instr) || is_load(instr);
    end
endfunction

/**
 * Get the rs of instr. Undefined behaviour if instr has no rs.
 */
function [`INSTRUCTION_REGISTER_WIDTH - 1:0] get_rs(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        get_rs = instr[`INSTRUCTION_RS];
    end
endfunction

/**
 * Get the rt of instr. Undefined behaviour if instr has no rt.
 */
function [`INSTRUCTION_REGISTER_WIDTH - 1:0] get_rt(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        get_rt = instr[`INSTRUCTION_RT_OFFSETM];
    end
endfunction

/**
 * Get the rw of instr. Undefined behaviour if instr has no rw.
 */
function [`INSTRUCTION_REGISTER_WIDTH - 1:0] get_rw(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        get_rw = instr[`INSTRUCTION_RW_OFFSETHI];
    end
endfunction

/**
 * Returns 1 if INSTR goes into the ROB. 0 otherwise.
 */
function [0:0] goes_into_ROB(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        goes_into_ROB = (get_op(instr) == `ADD || get_op(instr) == `SUB ||
                         get_op(instr) == `MUL || get_op(instr) == `OR  || 
                         get_op(instr) == `AND || get_op(instr) == `LDB ||
                         get_op(instr) == `LDW || get_op(instr) == `STB ||
                         get_op(instr) == `STW || get_op(instr) == `MOV || 
                         get_op(instr) == `ITLBWRITE || get_op(instr) == `DTLBWRITE ||
                         instr == `FULL_NOP_ROB);
    end
endfunction

/**
 * Returns 1 if INSTR can commit in EX stage.
 */
function [0:0] finishes_in_EX(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        finishes_in_EX = (get_op(instr) == `ADD || get_op(instr) == `SUB ||
                          get_op(instr) == `OR  || get_op(instr) == `AND || 
                          get_op(instr) == `MOV || 
                          get_op(instr) == `ITLBWRITE || get_op(instr) == `DTLBWRITE);
    end
endfunction

/**
 * Returns 1 if INSTR can commit in MEM stage.
 */
function [0:0] finishes_in_MEM(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        finishes_in_MEM = is_load(instr) || is_store(instr);
    end
endfunction

/**
 * Returns 1 if INSTR can commit in MUL5 stage.
 */
function [0:0] finishes_in_MUL5(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        finishes_in_MUL5 = (get_op(instr) == `MUL);
    end
endfunction

/**
 * Returns 1 if INSTR writtes into the register file.
 */
function [0:0] writes_reg(input [`INSTRUCTION_WIDTH - 1:0] instr);
    begin
        writes_reg = (get_op(instr) == `ADD || get_op(instr) == `SUB ||
                      get_op(instr) == `MUL ||
                      get_op(instr) == `OR  || get_op(instr) == `AND ||
                      get_op(instr) == `LDB || get_op(instr) == `LDW ||
                      get_op(instr) == `MOV);
    end
endfunction
