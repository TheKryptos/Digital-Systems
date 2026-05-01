// Description
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

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input logic clk,
    input logic run,
    input logic tick
);
  localparam int CountWidth = $clog2(CYCLE_COUNT);
  logic tick_qualifier;
  logic running = 1'b0;

  // Flip-Flop
  always_ff @(posedge clk) running <= run;

  // Next-state logic
  generate
    if (CYCLE_COUNT > 1) begin : g_general
      // put code for the general case here
    end else begin : g_special

    end
  endgenerate

    // Instantiate mod_n_counter
    logic rst_count;
    logic enable_count;
    logic [CountWidth-1:0] count;
    mod_n_counter #(
        .N(CYCLE_COUNT),
        .WIDTH(CountWidth)
    ) u_count (
        .clk(clk),
        .rst(rst_count),
        .enable(enable_count),
        .count(count)
    )

    // Output Logic

endmodule
