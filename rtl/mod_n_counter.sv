// Description
//
// Parameters:
// MAX - 2
// WIDTH -2
//
// Ports :
// clk
// rst
// enable
// count [1:0]
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(N - 1);
  logic [WIDTH-1:0] next_count;
  initial count = WIDTH'(0);

  always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else if (enable) count <= next_count;
  end

  always_comb begin
    next_count = count;
    next_count = (count < WIDTH'(Max)) ? count + WIDTH'(1) : WIDTH'(0);
  end

endmodule
