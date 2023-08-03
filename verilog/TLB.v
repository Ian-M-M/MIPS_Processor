/**
 * Direct-mapped TLB.
 *
 */

`include "defines.v"

module TLB(input wire clk,                                    // Clock.
           input wire reset,                                  // 1 -> tlb.valid = 0.
           input wire [`MODE_WIDTH-1:0] mode,                 // Execution mode.
           input wire write,                                  // 1 when you want to write on the TLB.
           input wire [`VIRTUAL_ADDR_WIDTH - 1:0] vaddr,      // Virtual addr.
           input wire [`PHYSICAL_ADDR_WIDTH - 1:0] paddr_new, // New physical address (when write == 1).
           output wire [`PHYSICAL_ADDR_WIDTH - 1:0] paddr,    // Physical addr.
           output wire hit);                                  // The vaddr translation is on the TLB? (when the processor is in supervisor mode => always 1).
    
    
    parameter ENTRY_BITS = 2; // Number of bits of the entries.
    
    localparam NUM_ENTRIES = 2 ** ENTRY_BITS; // Number of entries.
    localparam VENTRY_SIZE = `VIRTUAL_ADDR_WIDTH - `PAGE_SIZE; // Size of each virtual enty.
    localparam PENTRY_SIZE = `PHYSICAL_ADDR_WIDTH - `PAGE_SIZE; // Size of each physical enty.

    // TLB declaration.
    reg [VENTRY_SIZE - 1:0] tlb_vpages[NUM_ENTRIES - 1:0]; // Virtual pages.
    reg [PENTRY_SIZE - 1:0] tlb_ppages[NUM_ENTRIES - 1:0]; // Physical pages.
    reg tlb_valid[NUM_ENTRIES - 1:0]; // Valid bit.
    
    wire [VENTRY_SIZE - 1:0] vpage       = vaddr[`VIRTUAL_ADDR_WIDTH - 1:`PAGE_SIZE]; // Virtual page of vaddr.
    wire [PENTRY_SIZE - 1:0] ppage_new   = paddr_new[`PHYSICAL_ADDR_WIDTH - 1:`PAGE_SIZE]; // Virtual page of paddr_new.
    wire [`PAGE_SIZE - 1:0] displacement = vaddr[`PAGE_SIZE - 1 - 1:0]; // Displacement of vaddr.

    // Entry of the TLB (direct-mapped).
    wire [ENTRY_BITS - 1:0] entry = vpage[ENTRY_BITS - 1:0];

    assign hit = (mode == `SUPERVISOR_MODE) ? 1 : tlb_valid[entry] && tlb_vpages[entry] == vpage;
    assign paddr = (mode == `SUPERVISOR_MODE) ? vaddr : {tlb_ppages[entry], displacement};

    // Local variables.
    integer i;
    
    initial begin
        // Clean valid bits.
        for (i = 0; i < NUM_ENTRIES; i = i + 1) begin
            tlb_valid[i] <= 0;

            tlb_vpages[i] <= 0; 
            tlb_ppages[i] <= 0;
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            // Clean valid bits.
            for (i = 0; i < NUM_ENTRIES; i = i + 1) begin
                tlb_valid[i] <= 0;
            end
        end
        else if (write) begin
            tlb_valid[entry] <= 1;
                
            tlb_ppages[entry] <= ppage_new;
            tlb_vpages[entry] <= vpage;
        end
    end 
endmodule
