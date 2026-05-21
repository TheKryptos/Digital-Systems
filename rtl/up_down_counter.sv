// Counter counts up when enable and counts down when !enable
//
// Parameters:
// MAX - 2 (Max count number)
// WIDTH -2 (Width of the Count)
//
// Ports :
// clk
// enable
// up
// count
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  logic [WIDTH-1:0] next_count;
  initial count = WIDTH'(0);

  always_ff @(posedge clk) if (enable) count <= next_count;

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
