// run is low - tick goes low
// run is high:
// -if run high for CYCLE_COUNT-1, tick high for 1 clk cycle
// -if run high for CYCLE_COUNT rising edges, tick high for 1 clk cycle
// If CYCLE_COOUNT = 50_000_000 => tick goes high once per second
//
// Parameters:
// CYCLE_COUNT = 2
//
// Ports :
// clk
// run
// tick
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
  logic [WIDTH-1:0] prev_d;
  initial prev_d = '0;

  always_ff @(posedge clk) if (!hold) prev_d <= d;

  always_comb begin
    if (hold) q = prev_d;
    else q = d;
  end

endmodule
