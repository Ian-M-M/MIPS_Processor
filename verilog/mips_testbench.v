/**
 * MIPS testbench.
 *
 */

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module mips_testbench();
    
    localparam CLK_period = 20;
    
    reg clk, reset;
    
    wire [31:0] out;
    
    MIPS mips(clk, reset, out);
    
    initial begin
        reset = 1;
    end
    
    always begin
        clk = 1; // high edge

        #(CLK_period / 2); // wait for period
        reset = 0;

        clk = 0; // low edge
        #(CLK_period / 2); // wait for period

    end
endmodule
