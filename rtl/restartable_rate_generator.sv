// Outputs a tick after a specific number of clock cycles
// Controls tick rate
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

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);
  // Becomes high at the end of each cycle
  logic tick_qualifier;

  // state register (flip-flop)
  logic running = 1'b0;
  always_ff @(posedge clk) running <= run;

  // Output logic // tick_qualifier is determined by generate block
  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      localparam int CountWidth = $clog2(CYCLE_COUNT);

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
      );

      assign rst_count = !run;
      assign enable_count = run;

      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));

    end else begin : g_special
      assign tick_qualifier = 1'b1;
    end
  endgenerate

endmodule
