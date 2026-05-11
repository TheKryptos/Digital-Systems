// Take a snapshot of the input and selects which value
// to display
// Parameters:
// WIDTH = 1
//
// Ports :
// clk
// hold
// d
// q
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  logic [WIDTH-1:0] prev_d = '0;


  // Holds the previous d value
  always_ff @(posedge clk) if (!hold) prev_d <= d;

  always_comb begin
    if (hold) q = prev_d;
    else q = d;
  end

endmodule
