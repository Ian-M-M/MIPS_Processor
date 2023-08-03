/**
 * TLB testbench.
 *
 */

`include "defines.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module TLB_testbench();
    
    localparam CLK_period = 20;
    
    reg clk, reset;
    
    reg tlb_write = 0;
    reg tlb_read  = 0;
    
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] vaddr;
    reg [`VIRTUAL_ADDR_WIDTH - 1:0] paddr_new;
    
    wire [`PHYSICAL_ADDR_WIDTH - 1:0] paddr;
    wire hit;
    
    TLB tlb(
    .clk(clk),
    .reset(reset),
    .read(tlb_read),
    .write(tlb_write),
    .vaddr(vaddr),
    .paddr_new(paddr_new),
    .paddr(paddr),
    .hit(hit));
    
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
        #(CLK_period * 10);
        
        // Read
        
        // Should miss.

        tlb_read = 1;

        vaddr = 32'h 00001014;

        #(CLK_period);
        
        if (hit != 0) begin
            $display("Error 1: hit == 1");
        end

        tlb_read = 0;

        // Write

        tlb_write = 1;
        
        vaddr = 32'h 00001012;
        paddr_new = 20'h f1012;

        #(CLK_period);

        tlb_write = 0;

        // Read

        tlb_read = 1;

        // Should hit

        vaddr = 32'h 00001012;

        #(CLK_period);

        if (hit != 1) begin
            $display("Error 2: hit == 0");
        end
        if (paddr != 20'h f1012) begin
            $display("Error 3: paddr != 20'h f1012");
        end

        // Should miss

        vaddr = 32'h 00002123;

        #(CLK_period);

        if (hit != 0) begin
            $display("Error 4: hit == 1");
        end

        tlb_read = 0;
        
        #(CLK_period * 10000);
    end
endmodule
