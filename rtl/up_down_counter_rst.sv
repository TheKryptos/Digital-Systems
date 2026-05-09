// Counter counts up when enable and counts down when !enable
// rst high, count = 0 on next rising edge
//
// Parameters:
// MAX - 2
// WIDTH -2
//
// Ports :
//
//
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  logic [WIDTH-1:0] next_count;
  initial count = WIDTH'(0);

  // Flip-Flop
  always_ff @(posedge clk) begin
    // Stores count when enable is high
    if (enable) count <= next_count;
    // Resets count to 0 when rst is high
    if (rst) count <= '0;
  end

  // Next-State Logic
  always_comb begin
    next_count = count;
    // If up is high, counts up
    if (up) begin
      next_count = (count < WIDTH'(MAX)) ? count + WIDTH'(1) : WIDTH'(0);
      // If up is low, counts down
    end else begin
      next_count = (count > WIDTH'(0)) ? count - WIDTH'(1) : WIDTH'(MAX);
    end
  end

endmodule
