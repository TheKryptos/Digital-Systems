// Output
// Converts continuous state into single clk edge
// Holding the button for a set period enters
// edit mode
// Parameters:
// HOLD_CYCLES = 50_000_000
//
// Ports :
// clk
// button
// pulse
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  // Instantiate 3 mod_n_counter for each count //

  logic [W0-1:0] counting0;

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_count0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(counting0)
  );

  logic [W1-1:0] counting1;
  logic enable1;

  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_count1 (
      .clk(clk),
      .rst(rst),
      .enable(enable1),
      .count(counting1)
  );

  logic [W2-1:0] counting2;
  logic enable2;

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_count2 (
      .clk(clk),
      .rst(rst),
      .enable(enable2),
      .count(counting2)
  );

  // Next-State Logic
  assign enable1 = (counting0 == W0'(N0 - 1)) && enable;
  assign enable2 = (counting1 == W1'(N1 - 1)) && enable1;

  // Output Logic
  assign count0  = W0'(counting0);
  assign count1  = W1'(counting1);
  assign count2  = W2'(counting2);


endmodule
