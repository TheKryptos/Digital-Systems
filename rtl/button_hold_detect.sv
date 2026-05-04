// Holding the button for a set period enters
// edit mode
// Parameters:
// HOLD_CYCLES = 50_000_000
//
// Ports :
// clk
// button
// held
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  // Instantiate mod_n_counter
  localparam int CountMax = 32'(HOLD_CYCLES);
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  // Once button is released, reset counter
  assign count_rst = !button;
  // When button is pressed, stop counting
  assign count_enable = button & !held;

  // Output asserted once counter reaches maximum value
  assign held = (count == CountWidth'(CountMax));

endmodule
