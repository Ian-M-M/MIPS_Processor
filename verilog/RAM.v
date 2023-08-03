/**
 * RAM with delay.
 *
 */

`include "defines.v"

// Possible states of a RAM operation.
`define RAM_PORT_STATE_WIDTH 3
`define RAM_PORT_STATE_NONE 0
`define RAM_PORT_STATE_READING 1
`define RAM_PORT_STATE_WRITING 2
`define RAM_PORT_STATE_DONE_READING 3
`define RAM_PORT_STATE_DONE_WRITING 4

module RAM(input wire clk,                                         // Clock.
           input wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_rw,        // port r/w @addr.
           input wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_r,         // port r @addr.
           input wire [`CACHE_LINE_WIDTH - 1:0] din,               // port r/w data bus.
           input wire read_rw,                                     // port r/w read enable.
           input wire read_r,                                      // port r read enable.
           input wire write_rw,                                    // port r/w write enable.
           output reg [`RAM_PORT_STATE_WIDTH - 1:0] port_rw_state, // port r/w state (none, reading, writing, done-reading, done writing).
           output reg [`RAM_PORT_STATE_WIDTH - 1:0] port_r_state,  // por r state (none, reading, writing, done-reading, done writing).
           output wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_rw_out,   // Addr of the last data read/write from port r/w.
           output wire [`PHYSICAL_ADDR_WIDTH - 1:0] addr_r_out,    // Addr of the last data read from port r.
           output reg [`CACHE_LINE_WIDTH - 1:0] dout_rw,           // Output data bus for r/w port.
           output reg [`CACHE_LINE_WIDTH - 1:0] dout_r);           // Output data bus for r port.
    
    parameter INITIAL_VALUES_FILE;
    
    parameter DELAY = 10; // 10 cycles of delay.
    
    localparam NUM_ENTRIES = 2 ** `PHYSICAL_ADDR_WIDTH; // Num of RAM entries.
    
    reg [`DATA_SIZE - 1:0] DATA[NUM_ENTRIES - 1:0]; // RAM.
    
    integer current_delay_rw; // Variables for simulating delay for read/write port.
    integer current_delay_r;

    reg [`CACHE_LINE_WIDTH-1:0] last_data_rw; // Last task addr port r/w.
    reg [`CACHE_LINE_WIDTH-1:0] last_data_r; // Last task addr port r.

    reg [`PHYSICAL_ADDR_WIDTH-4-1:0] last_addr_rw; // Last task r/w addr.
    reg [`PHYSICAL_ADDR_WIDTH-4-1:0] last_addr_r; // Last task r addr.

    wire [`PHYSICAL_ADDR_WIDTH-4-1:0] addr_rw_line = addr_rw[`PHYSICAL_ADDR_WIDTH - 1:4];
    wire [`PHYSICAL_ADDR_WIDTH-4-1:0] addr_r_line = addr_r[`PHYSICAL_ADDR_WIDTH - 1:4];

    assign addr_rw_out = {last_addr_rw, 4'b 0};
    assign addr_r_out = {last_addr_r, 4'b 0};

    initial begin
        current_delay_rw <= 0;
        current_delay_r  <= 0;

        last_addr_rw <= 0;
        last_addr_r  <= 0;

	    port_rw_state <= `RAM_PORT_STATE_NONE;
	    port_r_state  <= `RAM_PORT_STATE_NONE;

        dout_rw <= 0;
        dout_r  <= 0;

        $readmemh(INITIAL_VALUES_FILE, DATA); // Read the initial RAM values.
    end
    
    always @(posedge clk) begin
        /*
         * R/W port
         */

        // No task in progress.
        if (port_rw_state == `RAM_PORT_STATE_NONE || 
            port_rw_state == `RAM_PORT_STATE_DONE_READING || 
            port_rw_state == `RAM_PORT_STATE_DONE_WRITING) begin
        
            current_delay_rw <= 0;

            // New task.
            if (write_rw || read_rw) begin
    
                last_addr_rw <= addr_rw_line;

                if (write_rw) begin
                    last_data_rw <= din;

                    port_rw_state <= `RAM_PORT_STATE_WRITING;
                end
                else begin // Read
                    last_data_rw <= {DATA[addr_rw_line * 4 + 3], DATA[addr_rw_line * 4 + 2],
                                     DATA[addr_rw_line * 4 + 1], DATA[addr_rw_line * 4]};
                    
                    port_rw_state <= `RAM_PORT_STATE_READING;
                end
            end
            else begin
                port_rw_state <= `RAM_PORT_STATE_NONE;
            end
        end  
        // Job in progress.
        else begin

            current_delay_rw <= current_delay_rw + 1;

            // Job finished.
            if (current_delay_rw == DELAY) begin

                if (port_rw_state == `RAM_PORT_STATE_READING) begin
                    port_rw_state <= `RAM_PORT_STATE_DONE_READING;

                    dout_rw <= last_data_rw;
                end
                else begin
                    port_rw_state <= `RAM_PORT_STATE_DONE_WRITING;

                    DATA[last_addr_rw * 4 + 0] <= last_data_rw[31:0];
                    DATA[last_addr_rw * 4 + 1] <= last_data_rw[63:32];
                    DATA[last_addr_rw * 4 + 2] <= last_data_rw[95:64];
                    DATA[last_addr_rw * 4 + 3] <= last_data_rw[127:96];
                end
            end
        end

        /*
         * R port
         */

        // No task in progress.
        if (port_r_state == `RAM_PORT_STATE_NONE || 
            port_r_state == `RAM_PORT_STATE_DONE_READING) begin

            current_delay_r <= 0;

            last_addr_r <= addr_r_line;

            // New task.
            if (read_r) begin
                last_data_r <= {DATA[addr_r_line * 4 + 3], DATA[addr_r_line * 4 + 2],
                                DATA[addr_r_line * 4 + 1], DATA[addr_r_line * 4 + 0]};

                port_r_state <= `RAM_PORT_STATE_READING;
            end
            else begin
                port_r_state <= `RAM_PORT_STATE_NONE;
            end
        end

        // Job in progress.
        else begin

            current_delay_r <= current_delay_r + 1;

            // Job finished.
            if (current_delay_r == DELAY) begin
                dout_r <= last_data_r;

                port_r_state <= `RAM_PORT_STATE_DONE_READING;
            end
        end
    end
    
endmodule

