/**
 * (F)orward (U)nit.
 *
 */

`include "defines.v"
`include "ROB.v"

module FU(input wire [`INSTRUCTION_WIDTH-1:0] instruction_ID, // The instruction in ID.
          input wire [`BYPASS_STATE_WIDTH-1:0] rs_state_ROB,  // Rs register ROB-state (HIT, MISS, WAIT).
          input wire [`BYPASS_STATE_WIDTH-1:0] rt_state_ROB,  // Rt register ROB-state (HIT, MISS, WAIT).
          input wire [`DATA_SIZE-1:0] rs_value_ROB,           // Rs bypass value from the ROB.
          input wire [`DATA_SIZE-1:0] rt_value_ROB,           // Rt bypass value from the ROB.
          input wire [`DATA_SIZE-1:0] bus_rs_ID,              // The bus-rs in ID.
          input wire [`DATA_SIZE-1:0] bus_rt_ID,              // The bus-rt in ID.
          input wire [`DATA_SIZE-1:0] rm0,                    // Rm0 special register.
          input wire [`DATA_SIZE-1:0] rm1,                    // Rm1 special register.
          input wire [`DATA_SIZE-1:0] rm2,                    // Rm2 special register.
          input wire [`MODE_WIDTH-1:0] rm4,                   // Rm4 special register.
          output reg [`DATA_SIZE-1:0] bus_rs_out,             // Rs-out value of the FU.
          output reg [`DATA_SIZE-1:0] bus_rt_out,             // Rt-out value of the FU.
          output wire stop);                                  // Some bypass value is not ready.

      // The data is in the ROB but its not ready.
      assign stop = (has_rs(instruction_ID) && rs_state_ROB == `BYPASS_STATE_WAIT) ||
                    (has_rt(instruction_ID) && rt_state_ROB == `BYPASS_STATE_WAIT);

      always @(*) begin
            // RS out
            if (get_op(instruction_ID) == `MOV) begin
                  if (get_rs(instruction_ID) == 0) begin
                        bus_rs_out = rm0;
                  end
                  else if (get_rs(instruction_ID) == 1) begin
                        bus_rs_out = rm1;
                  end
                  else if (get_rs(instruction_ID) == 2) begin
                        bus_rs_out = rm2;
                  end
                  else if (get_rs(instruction_ID) == 4) begin
                        bus_rs_out = rm4;
                  end
                  else begin
                        bus_rs_out = 0;
                  end
            end
            else begin
                  if (get_rs(instruction_ID == 0)) begin
                        bus_rs_out = 0;
                  end
                  else if (rs_state_ROB == `BYPASS_STATE_HIT) begin
                        bus_rs_out = rs_value_ROB;
                  end
                  else begin
                        bus_rs_out = bus_rs_ID;
                  end
            end

            // RT out
            if (get_rt(instruction_ID == 0)) begin
                  bus_rt_out = 0;
            end
            else if (rt_state_ROB == `BYPASS_STATE_HIT) begin
                  bus_rt_out = rt_value_ROB;
            end
            else begin
                  bus_rt_out = bus_rt_ID;
            end
      end

endmodule
