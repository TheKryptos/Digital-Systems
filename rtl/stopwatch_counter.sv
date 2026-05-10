// Minutes, seconds, centiseconds stopwatch
// Increment next corresponding count one centisecond 
// after enable goes high
//
// Parameters:
// CYCLES_PER_SECOND = 50_000_000 - 1 second
//
// Ports :
// clk
// rst
// enable
// minutes
// seconds
// centiseconds
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundreths of a seconds
);


  // Instantiate cascade_counter
  logic tick;
  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_cascade_counter (
      .clk(clk),
      .rst(rst),
      .enable(enable & tick),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

  // Instantiate restartable_rate_generator
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_restart (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );


endmodule
