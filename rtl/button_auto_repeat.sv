// Brief press produce immediate pulse (rise)
// Hold button produce pulse train (pulse train)
// Parameters:
// HOLD_CYCLES = 50_000_000
// REPEAT_CYCLES = 5_000_000
//
// Ports :
// clk
// button
// pulse
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic rise;
  logic held;
  logic pulse_train;

  // Instantiate rising_edge_detector
  rising_edge_detector u_rising_edge (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  // Instantiate button_hold_detect
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_button_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // Instantiate restartable rate_generator
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

  // Output Logic
  assign pulse = rise | (button & pulse_train);

endmodule
