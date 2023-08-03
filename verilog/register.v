/**
 * Register.
 *
 */

module register #(parameter WIDTH = 32,         // Bits of the register.
                  parameter INITIAL_VALUE = 0)  // Initial value of the register.
                 (input wire clk,               // Clock.
                  input wire reset,             // 1 -> register = 0.
                  input wire load,              // Overwrite data; 1 -> yes, 0 -> no.
                  input wire [WIDTH-1:0] din,   // Input.
                  output reg [WIDTH-1:0] dout); // Output.
    
    initial begin
        dout <= INITIAL_VALUE;
    end

    always @(posedge clk) begin
        if (reset) begin
            dout <= INITIAL_VALUE;
        end
        else if (load) begin
            dout <= din;
        end
    end
    
endmodule
