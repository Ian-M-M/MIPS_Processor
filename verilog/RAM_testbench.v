/**
 * MIPS testbench.
 *
 */

`include "defines.v"

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module RAM_testbench();
    
    localparam CLK_period = 20;
    
    reg clk, reset;
    
    reg [`PHYSICAL_ADDR_WIDTH - 1:0] addr;
    reg [`DATA_SIZE - 1:0] din;
    reg mem_write = 0;
    reg mem_read = 0;
    
    wire done;
    wire [`CACHE_LINE_WIDTH - 1:0] dout;
    
    
    RAM
    #(.INITIAL_VALUES_FILE("RAM_benchmark.list"))
    ram(
    .clk(clk),
    .addr(addr),
    .din(din),
    .write(mem_write),
    .read(mem_read),
    .done(done),
    .dout(dout)
    );
    
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

        // Write
        
        // Should write 10 on bytes 0-3.

        addr = 1; 
        din = 10;
        mem_write = 1;

        #(CLK_period);

        mem_write = 0;

        if (done == 1) begin
            $display("Error: done 0 on cycle 1");
        end

        #(CLK_period * 9);

        if (done != 1) begin
            $display("Error: done != 1");
        end

        #(CLK_period * 10);

        // Read

        // Should read 10,2,3,4 on bytes 0-3, 4-7, 8-11, 12-15.

        addr = 2;
        mem_read = 1;

        #(CLK_period);

        mem_read = 0;

        if (done == 1) begin
            $display("Error: done 0 on cycle 1");
        end

        #(CLK_period * 9);

        if (done != 1 || dout != {32'd 4, 32'd 3, 32'd 2, 32'd 10}) begin
            $display("Error: done != 1 || dout != X on cycle 10, %h", dout);
        end

        #(CLK_period * 10);

        // Should read 10,2,3,4 on bytes 0-3, 4-7, 8-11, 12-15.

        addr = 0;
        mem_read = 1;

        #(CLK_period);

        mem_read = 0;

        if (done == 1) begin
            $display("Error: done 0 on cycle 1");
        end

        #(CLK_period * 9);

        if (done != 1 || dout != {32'd 4, 32'd 3, 32'd 2, 32'd 10}) begin
            $display("Error: done != 1 || dout != X on cycle 10, %h", dout);
        end

        #(CLK_period * 10000);
    end
endmodule
