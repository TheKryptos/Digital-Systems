// Hold button enters editing mode
// In editing mode, each push shifts the mode
// Mode remains '000 outside editing mode
//
// Parameters:
// HOLD_CYCLES = 50_000_000
//
// Ports :
// clk
// button
// mode_enable
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable  // determine which mode we are in
);

  // Instantiate button_hold_pulse
  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)  // long_press enters editing mode
  );

  // Instantiate rising_edge_detector
  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)  // outputs a single press pulse for 1 clk cycle
  );

  // Instantiate arming_latch
  logic armed;
  logic disarm;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  // Instantiate mod_n_counter
  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  // Counter runs only while armed; resets when disarmed
  assign enable_counter = press && armed;
  // reset takes priority when both counter is high
  assign reset_counter = !armed;

  // Disarm on the press that steps past the last mode
  assign disarm = press && (count == 2'(2));

  // Output logic
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;


endmodule
