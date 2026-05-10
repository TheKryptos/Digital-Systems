// FSM for implementing stopwatch modes
//
// Ports :
// clk
// rise_start_stop
// rise_lap
// counter_rst
// counter_enable
// lap_hold
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module stopwatch_control (
    input logic clk,
    input logic rise_start_stop,  // button[0]: toggles between Start/Stop
    input logic rise_lap,  // button[1]: Lap (while running) / Reset (while stopped)
    output logic counter_rst,  // Triggers reset
    output logic counter_enable,  // Controls Running / Stopped
    output logic lap_hold  // Controls Live / Frozen Display
);
  // State Encoding // states map to {counter_rst, counter_enable, lap_hold} //
  // localparam logic [2:0] StoppedLive = 3'b000;
  // localparam logic [2:0] StoppedFrozen = 3'b001;
  // localparam logic [2:0] RunningLive = 3'b010;
  // localparam logic [2:0] RunningFrozen = 3'b011;
  // localparam logic [2:0] Resetting = 3'b100;

  // Initialise outputs
  initial begin
    counter_rst = '0;
    counter_enable = '0;
    lap_hold = '0;
  end

  // Next-State Declaration
  logic next_rst;
  logic next_enable;
  logic next_lap_hold;

  // State Register
  always_ff @(posedge clk) begin
    counter_rst <= next_rst;
    counter_enable <= next_enable;
    lap_hold <= next_lap_hold;
  end

  // Simultaneous Presses ignore
  logic valid_start = rise_start_stop && !rise_lap;
  logic valid_lap = !rise_start_stop && rise_lap;

  // Next-State Logic counter_rst //
  // Resets when state = StoppedLive
  assign next_rst = !counter_rst && !counter_enable && !lap_hold && valid_lap;

  // Next-State Logic counter_enable //
  // Toggles when start/stop is pressed, except when resetting
  assign next_enable = valid_start ? !counter_enable : counter_enable;

  // Next-State Logic lap_hold
  always_comb begin
    next_lap_hold = lap_hold;
    // When Valid_lap is pressed
    if (valid_lap) begin
      // StoppedLive State (000)
      if (!counter_enable && !lap_hold) begin
        // Pressing lap transitions to Resetting Mode
        next_lap_hold = '0;
      end else begin
        // Other States (RunningLive, RunningFrozen, StoppedFrozen)
        // Pressing Lap toggles Frozen display
        next_lap_hold = !lap_hold;
      end
    end
  end

endmodule
